#INCLUDE "pcoa140.ch"
#Include "Protheus.ch"

/*/
_F_U_N_C_苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪哪勘�
北矲UNCAO    � PCOA140  � AUTOR � Paulo Carnelossi      � DATA � 26/10/2004 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪哪幢�
北矰ESCRICAO � Programa de Cadastro de Acessos aos Itens Contabeis          潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� USO      � SIGAPCO                                                      潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砡DOCUMEN_ � PCOA140                                                      潮�
北砡DESCRI_  � Programa de Cadastro de Acessos aos Itens Contabeis (PCO)    潮�
北砡FUNC_    � Esta funcao podera ser utilizada com a sua chamada normal    潮�
北�          � partir do Menu ou a partir de uma funcao pulando assim o     潮�
北�          � browse principal e executando a chamada direta da rotina     潮�
北�          � selecionada.                                                 潮�
北�          � Exemplo: PCOA140(2) - Executa a chamada da funcao de visua-  潮�
北�          �                       zacao da rotina.                       潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砡PARAMETR_� ExpN1 : Chamada direta sem passar pela mBrowse               潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Function PCOA140(nCallOpcx)

Private cCadastro	:= STR0001 //"Cadastro de Restricao de Acesso de Usuarios a Item Contabil"
Private aRotina := MenuDef()

If AMIIn(57) // AMIIn do modulo SIGAPCO ( 57 )
	If nCallOpcx <> Nil .And. ( nCallOpcx == 3 .OR. nCallOpcx == 4 )
	    If nCallOpcx == 3
	       Inclui := .T.
	    Else
	       Inclui := .F.
	    EndIf   
		PCOA140DLG("AKY",AKY->(RecNo()),nCallOpcx)
	Else
		mBrowse(6,1,22,75,"AKY")
	EndIf
EndIf

Return


/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯脱屯屯屯屯屯送屯屯屯淹屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐�
北篜rograma  砅COA140DLG篈utor  砅aulo Carnelossi    � Data �  26/10/04   罕�
北掏屯屯屯屯拓屯屯屯屯屯释屯屯屯贤屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡�
北篋esc.     砯uncao para inclusao ou alteracao de acesso aos Itens conta-罕�
北�          砨il(feito desta forma em razao validacao botao OK)          罕�
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北篣so       � AP                                                         罕�
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Function PCOA140DLG(cAlias,nReg,nOpcx)
If nOpcx == 3
	AxInclui(cAlias,nReg,nOpcx,/*aAcho*/,/*cFunc*/,/*aCpos*/,"PCOA140IC()"/*cTudoOk*/,/*lF3*/,/*cTransact*/,/*aButtons*/,/*aParam*/,/*aAuto*/,/*lVirtual*/,/*lMaximized*/)
EndIf
If nOpcx == 4
    AxAltera(cAlias,nReg,nOpcx,/*aAcho*/,/*aCpos*/,/*nColMens*/,/*cMensagem*/,"PCOA140IC()"/*cTudoOk*/,/*cTransact*/,/*cFunc*/,/*aButtons*/,/*aParam*/,/*aAuto*/,/*lVirtual*/,/*lMaximized*/)	
EndIf

Return

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯脱屯屯屯屯屯送屯屯屯淹屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐�
北篜rograma  砅COA140IC 篈utor  砅aulo Carnelossi    � Data �  26/10/04   罕�
北掏屯屯屯屯拓屯屯屯屯屯释屯屯屯贤屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡�
北篋esc.     砯uncao para inclusao ou alteracao de acesso aos itens conta-罕�
北�          砨eis                                                        罕�
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北篣so       � AP                                                         罕�
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Function PCOA140IC(lAval, cUser, cItCtbIni, cItCtbFin, lInclui, nRecAKY)
Local aAreaAKY := AKY->(GetArea())
Local cAlias   := Alias()
Local lRet := .T.
Local aFaixaIC

DEFAULT lAval := .T.
DEFAULT cUser := M->AKY_USER
DEFAULT cItCtbIni := M->AKY_IC_INI
DEFAULT cItCtbFin := M->AKY_IC_FIN
DEFAULT lInclui   := Inclui
DEFAULT nRecAKY   := If(Inclui, 0, AKY->(Recno()))

dbSelectArea("AKY")
dbSetOrder(1)
aFaixaIC := {}
If dbSeek(xFilial("AKY")+cUser)
	While ! Eof() .And. AKY_FILIAL+AKY_USER == xFilial("AKY")+cUser
	    If lInclui .OR. (!Inclui .And. Recno() <> nRecAKY)
			aAdd(aFaixaIC, {AKY_IC_INI, AKY_IC_FIN})
	    EndIf
		dbSkip()
	EndDo
	
	If Len(aFaixaIC) > 0
		lRet := AvFaixaIC(lAval, cItCtbIni, cItCtbFin, aFaixaIC)
	EndIf
	
EndIf
	
RestArea(aAreaAKY)
dbSelectArea(cAlias)

Return(lRet)


/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯脱屯屯屯屯屯送屯屯屯淹屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐�
北篜rograma  矨vFaixaIC 篈utor  砅aulo Carnelossi    � Data �  26/10/04   罕�
北掏屯屯屯屯拓屯屯屯屯屯释屯屯屯贤屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡�
北篋esc.     矨valia se elemento 1 ou 2 podem ser inseridos na Tabela de  罕�
北�          矨cessos ao Item Contabil                                    罕�
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北篣so       � AP                                                         罕�
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Static Function AvFaixaIC(lAval,cNewElem1, cNewElem2, aElemExistente)
Local cInicio, cFim, nCtd, cAnterior := Space(Len(AKY->AKY_IC_INI))
Local lRet := .T.
Local nTamCC := Len(cNewElem1)

cNewElem1 := PadL(Alltrim(cNewElem1),nTamCC)
cNewElem2 := PadL(Alltrim(cNewElem2),nTamCC)

For nCtd := 1 TO Len(aElemExistente)
    aElemExistente[nCtd][1] := PadL(Alltrim(aElemExistente[nCtd][1]),nTamCC)
    aElemExistente[nCtd][2] := PadL(Alltrim(aElemExistente[nCtd][2]),nTamCC)
Next

If lAval .And. cNewElem1 > cNewElem2
	HELP("  ",1,"PCOA1401") //Item Contabil inicial maior que final!
 	lRet := .F.
EndIf

If lRet
	For nCtd := 1 TO Len(aElemExistente)
		//avalia se todos os elementos sao numericos
		If Valtype(aElemExistente[nCtd][1]) != "C" .OR. ;
	    	Valtype(aElemExistente[nCtd][2]) != "C"
	    	HELP("  ",1,"PCOA1404") //Erro: Array (itens contabeis) enviado contem elemento nao caracter!
	   	    lRet := .F.
	    	EXIT
	   EndIf
	   // avalia se elemento inicial e maior que anterior e neste caso
	   // atribui a cAnterior o segundo elemento
	   // senao esta errado - avisa usuario e sai
	   If aElemExistente[nCtd][1] > cAnterior
			cAnterior := aElemExistente[nCtd][2]
		Else
			HELP("  ",1,"PCOA1402") //Faixa de Item Contabil ja existente nao esta integra.Verificar!
	    	lRet := .F.
	    	EXIT
		EndIf	
	Next
EndIf

If lRet
	For nCtd := 1 TO Len(aElemExistente)
		cInicio	:= aElemExistente[nCtd][1]
		cFim		:= aElemExistente[nCtd][2]
		
		If cNewElem1 > cInicio
		    //avalia elementos a Inserir
			If cNewElem1 <= cFim .OR. cNewElem2 <= cFim
				HELP("  ",1,"PCOA1403") //Faixa de Item Contabil ja existente, portanto nao pode ser incluida!
				lRet := .F.
				EXIT
			EndIf	
		Else	
			//se elemento 1 for menor que inicio avalia elemento 2
			If cNewElem2 >= cInicio
				HELP("  ",1,"PCOA1403") //Faixa de Item Contabil ja existente, portanto nao pode ser incluida!
				lRet := .F.
				EXIT
			EndIf	
		EndIf
	Next
EndIf

Return(lRet)


/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北砅rograma  矼enuDef   � Autor � Ana Paula N. Silva     � Data �10/12/06 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噮o � Utilizacao de menu Funcional                               潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砇etorno   矨rray com opcoes da rotina.                                 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros砅arametros do array a Rotina:                               潮�
北�          �1. Nome a aparecer no cabecalho                             潮�
北�          �2. Nome da Rotina associada                                 潮�
北�          �3. Reservado                                                潮�
北�          �4. Tipo de Transa噭o a ser efetuada:                        潮�
北�          �		1 - Pesquisa e Posiciona em um Banco de Dados     潮�
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
Local aRotina 	:= {	{ STR0002,		"AxPesqui" , 0 , 1, ,.F.},;    //"Pesquisar"
							{ STR0003, 	"AxVisual" , 0 , 2},;    //"Visualizar"
							{ STR0004, 		"pcoA140Dlg" , 0 , 3},;	  //"Incluir"
							{ STR0006, 		"pcoA140Dlg" , 0 , 4},; //"Alterar"
							{ STR0005, 		"AxDeleta" , 0 , 5}} //"Excluir"
						
If AMIIn(57) // AMIIn do modulo SIGAPCO ( 57 )
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//� Adiciona botoes do usuario no Browse                                   �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
	If ExistBlock( "PCOA1401" )
		//P_E谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
		//P_E� Ponto de entrada utilizado para inclusao de funcoes de usuarios no     �
		//P_E� browse da tela de Centros Orcamentarios                                            �
		//P_E� Parametros : Nenhum                                                    �
		//P_E� Retorno    : Array contendo as rotinas a serem adicionados na enchoice �
		//P_E�               Ex. :  User Function PCOA1401                            �
		//P_E�                      Return {{"Titulo", {|| U_Teste() } }}             �
		//P_E滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
		If ValType( aUsRotina := ExecBlock( "PCOA1401", .F., .F. ) ) == "A"
			AEval( aUsRotina, { |x| AAdd( aRotina, x ) } )
		EndIf
	EndIf      
EndIf	
Return(aRotina)