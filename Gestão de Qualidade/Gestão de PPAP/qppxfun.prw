#INCLUDE "QPPXFUN.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE 'FILEIO.CH'
#DEFINE Confirma 1
#DEFINE Redigita 2
#DEFINE Abandona 3 

// Funcoes renomeadas trazidas do QAXFUN, exclusiva para o modulo PPAP
// Robson Ramiro A. Oliveira 27/07/01
                                
/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噭o	 砆O_TEXTO	� Autor � Vera / Wanderley 	    � Data � 01.12.97 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噭o � Trata textos - VERSAO DOS/WINDOWS						  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砈intaxe	 � QO_TEXTO(ExpC1,ExpC2,ExpN1,ExpC3,ExpC4,ExpA1,ExpN2,ExpC5,; 潮�
北�			 � 			ExpL1,ExpC6)									  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� ExpC1 = Chave do Texto (j� convertida) 					  潮�
北�			 � ExpC2 = Especie do Texto									  潮�
北�			 � ExpN1 = Tamanho da linha do texto						  潮�
北�			 � ExpC3 = Titulo do Texto: somente informativo na tela		  潮�
北�			 � ExpC4 = Codigo do Titulo: somente informativo na tela 	  潮�
北�			 � ExpA1 = Array contendo os textos a serem editados		  潮�
北�			 � ExpN2 = Linha do vetor axTextos							  潮�
北�			 � ExpC5 = Cabecalho da tela de Texto						  潮�
北�			 � ExpL1 = Edita ou n苚 o texto. 							  潮�
北�			 � ExpC6 = Alias do arquivo para gravar o texto 			  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砋so		 � Generico 												  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砄bs		 � O vetor axTextos deve ser criado no programa chamador, como潮�
北�			 � private, e passado via parametro, como referencia (@).	  潮�
北�			 � O vetor axTextos deve ser inicializado apos cada funcao de 潮�
北�			 � inclusao,alteracao e exclusao.							  潮�
北媚哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     潮�
北媚哪哪哪哪哪哪穆哪哪哪哪履哪哪穆哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� PROGRAMADOR  � DATA   � BOPS �  MOTIVO DA ALTERACAO                   潮�
北媚哪哪哪哪哪哪呐哪哪哪哪拍哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Robson Ramir �02.08.01�------� Alteracao no size da var Memo para ser 潮�
北�              �        �      � calculado com base no nTamLin          潮�
北� Robson Ramir �06.12.02�------� Acerto do tamanho do dialogo devido a  潮�
北�              �        �      � troca da fonte                         潮�
北滥哪哪哪哪哪哪牧哪哪哪哪聊哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/

Function QO_TEXTO(cChave,cEspecie,nTamLin,cTit,cCod,axTextos,nLi,cCab,;
	lEdita,cAliasQKO)

Local oFontMet   	:= TFont():New("Courier New",6,0)
Local oFontDialog	:= TFont():New("Arial",6,15,,.T.)
Local oDlg
Local oTexto
Local cAlias		:= iif(cAliasQKO == Nil,"QKO",cAliasQKO)
Local cTexto
Local cDescricao
Local nOpcA 		:= 0
Local nPasso		:= 0
Local nLinTotal		:= 0
Local nPos			:= 0
Local nTamPix		:= Iif(nTamlin == 75, 2.6756, 2.79)

cAliasQKO := iif(cAliasQKO == Nil,"QKO",cAliasQKO)

Private lEdit := Iif(lEdita == NIL, .T., lEdita)

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� Recupera Texto ja' existente (nLi e' a linha atual da getdados)     �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
cTexto := QO_RecTxt( cChave, cEspecie, nLi, nTamLin, cAliasQKO, axtextos)

DEFINE MSDIALOG oDlg FROM	62,100 TO 320,610 TITLE cCab PIXEL FONT oFontDialog

@ 003, 004 TO 027, 250 LABEL cTit OF oDlg PIXEL
@ 040, 004 TO 110, 250			   OF oDlg PIXEL

@ 013, 010 MSGET cCod WHEN .F. SIZE 185, 010 OF oDlg PIXEL

If lEdit  // Obs. Cada caracter Courier New 06 tem aproximadamente 2.6756 pixels num dialogo assim.
	@ 050, 010 GET oTexto VAR cTexto MEMO NO VSCROLL SIZE (nTamLin*nTamPix), 051 OF oDlg PIXEL
Else
	@ 050, 010 GET oTexto VAR cTexto MEMO READONLY NO VSCROLL SIZE (nTamLin*nTamPix), 051 OF oDlg PIXEL
Endif

oTexto:SetFont(oFontMet)

DEFINE SBUTTON FROM 115,190 TYPE 1 ACTION (nOpca := 1,oDlg:End()) ENABLE OF oDlg
DEFINE SBUTTON FROM 115,220 TYPE 2 ACTION (nOpca := 2,oDlg:End()) ENABLE OF oDlg

ACTIVATE MSDIALOG oDlg CENTERED

If nOpca = Confirma
	// Confirma
	lGrava	  := .T.
	nPos := ascan(axTextos, {|x| x[1] == nLi })
	If nPos == 0
		Aadd(axTextos, { nLi, cTexto } )
	Else
		axTextos[nPos][2] := cTexto
	Endif
EndIf

Return If(nOpca==Confirma,.T.,.F.)


/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噭o	 砆O_Rectxt � Autor � Vera / Wanderley 	    � Data � 02.12.97 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噭o � Recupera um texto do arquivo de textos 					  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砈intaxe	 � QO_RecTxt(ExpC1,ExpC2,ExpN1,ExpN2,ExpC3,ExpA1)			  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� ExpC1 = Chave do Texto (ja' convertida)                    潮�
北�			 � ExpC2 = Especie do Texto									  潮�
北�			 � ExpN1 = Linha da GetDados que esta posicionada	    	  潮�
北�			 � ExpN2 = Tamanho da linha do texto						  潮�
北�			 � ExpC3 = Alias do arquivo para leitura (QKO ou tempor.)	  潮�
北�			 �  Obs.:  Se for arq. temp., deve ter a mesma estrut. do QKO.潮�
北�			 � ExpA1 = Array contendo o texto a ser recuperado 			  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso		 � QO_TEXTO 												  潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Function QO_Rectxt(cChave,cEspecie,nX,nTamLin,cAliasQKO,axTextos,lQuebra)
Local nPos	:= 0
Local cTexto:= ""
Local cAlias:= Iif(cAliasQKO == NIL,"QKO",cAliasQKO)
Local cQuebra:= Chr(13)+Chr(10)
Local nRec   := &(cAlias+"->(Recno())")
Local nOrd   := &(cAlias+"->(IndexOrd(IndexKey()))")

Default nX       := 1
Default nTamLin  := TamSx3("QKO_TEXTO")[1]
Default axTextos := {}
Default lQuebra  := .T.

If Len(axTextos) > 0
	nPos := ascan(axTextos,{ |x| x[1] == nX })
	If nPos <> 0
		cTexto:= axTextos[nPos][2]
	EndIf
EndIf

If nPos == 0
	dbSelectArea( cAlias )
	dbSetOrder(If(cAlias=="QKO",1,IndexOrd()))
	If dbSeek( xFilial(cAlias) + cEspecie + cChave )
		If Alltrim(cAlias) == "QKO" 
			While !Eof() .and. QKO->QKO_FILIAL+QKO->QKO_ESPEC+QKO->QKO_CHAVE == xFilial(cAlias)+cEspecie+cChave
				If At("\13\10",QKO->QKO_TEXTO) > 0
					cTexto+= SubStr(QKO->QKO_TEXTO,1,At("\13\10",QKO->QKO_TEXTO) - 1) + If(lQuebra,cQuebra,Space(1))
				Else
					// Para tratamento de postgress x linux
					If At("",QKO->QKO_TEXTO) > 0
						cTexto+= SubStr(QKO->QKO_TEXTO,1,At("",QKO->QKO_TEXTO) - 1) + cQuebra	
					Else
						cTexto+= RTrim(QKO->QKO_TEXTO)
					Endif	
				EndIf            
				QKO->(DbSkip())
			Enddo
		Endif
	EndIf
EndIf

&(cAlias+"->(dbGoTo("+Alltrim(Str(nRec))+"))")
&(cAlias+"->(dbSetOrder("+Alltrim(Str(nOrd))+"))")

Return(cTexto)

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噭o	 砆O_GrvTxt � Autor � Vera / Wanderley 	    � Data � 02.12.97 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噭o � Grava o texto editado com QO_TEXTO, a partir do axTextos   潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砈intaxe	 � QO_GrvTxt(ExpC1,ExpC2,ExpN1,ExpA1,ExpC3)				      潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� ExpC1 = Chave do Texto (j� convertida) 					  潮�
北�			 � ExpC2 = Especie do Texto									  潮�
北�			 � ExpN1 = Linha da Getdados que esta posicionado			  潮�
北�			 � ExpA1 = Vetor axTextos, que contem os textos digitados	  潮�
北�			 � ExpC3 = Alias do arquivo para gravacao (QKO ou tempor.)	  潮�
北�			 �  Obs.:  Se for arq. temp., deve ter a mesma estrut. do QKO.潮�
北�			 � ExpN2 = Tamanho da linha na tela - Default 75 Carct.		  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso		 � Generico 												  潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Function QO_GrvTxt(cChave,cEspecie,nX,axTextos,cAliasQKO,nTamLin)

Local cOldAlias	:= Select()
Local cTexto		:= ""
Local nI 			:= 0
Local nLinhas		:= {}
Local nPos			:= 0
Local nChr			:= 0
Local cAlias

Local cCampo 		:= "" // Auxiliar na grava嚻o, para gerar macro do campo

Default nTamLin		:= 75
Default cAlias 		:= "QKO"
Default axTextos	:= {}
Default cAliasQKO	:= "QKO"

If len(axTextos) > 0

	cTexto    := axTextos[1,2]
	nTamLin   := If(nTamLin >= Len(QKO->QKO_TEXTO),nTamLin-6,nTamLin)

	While !Empty(cTexto)
		cLine := Subs(cTexto,1,nTamLin)
		nTexto:= At(Chr(13),cLine)
		If nTexto > 0
			cLine := Subs(cLine,1,nTexto-1)+"\13\10"
			nTexto+= 2
		Else
			If !Empty(cLine)
				nTexto := nTamLin+1
			    nLen1 := Len(cLine)
				nLen2 := Len(Trim(cLine))
				
				//verifica se tem espaco no final da linha para colocar no inicio do proximo registro
				If nLen1 <> nLen2
					cLine := Trim(cLine)
					nTexto -= (nLen1 - nLen2)
				EndIf
			Else
				If Len(cTexto) > nTamLin
					nTexto := nTamLin+1
				Endif
			EndIf
		EndIf
		cTexto := Subs(cTexto,nTexto)
		aadd(nLinhas,cLine)
	EndDo
	
	dbSelectArea(cAliasQKO)
	dbSetOrder(1)
	dbseek(xFilial(cAliasQKO) + cEspecie + cChave)
	For nI := 1 to len(nLinhas)
		If Alltrim(cAliasQKO) == "QKO" 
			If !Eof() .and. QKO_FILIAL+QKO_ESPEC+QKO_CHAVE == xFilial(cAliasQKO)+cEspecie+cChave
				RecLock(cAliasQKO, .f.) // Lock
			Else
				RecLock(cAliasQKO, .t.) // Append
				cCampo  := cAliasQKO+"->"+cAliasQKO+"_FILIAL"
				&cCampo := xFilial(cAliasQKO)
				cCampo  := cAliasQKO+"->"+cAliasQKO+"_CHAVE"
				&cCampo := cChave
				cCampo  := cAliasQKO+"->"+cAliasQKO+"_ESPEC"
				&cCampo := cEspecie
			EndIf
			cCampo  := cAliasQKO+"->QKO_SEQ"
			&cCampo := StrZero(nI,3)
			cCampo  := cAliasQKO+"->"+cAliasQKO+"_TEXTO" 
			&cCampo := nLinhas[nI]
			MsUnlock()
		Endif
		dbSkip()
	Next nI

	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//� Deleta as linhas anteriores se texto digitado for menor 	�
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	If Alltrim(cAliasQKO) == "QKO" 	
		While QKO->(!Eof()) .And. QKO_FILIAL+QKO_ESPEC+QKO_CHAVE == xFilial('QKO')+cEspecie+cChave
			RecLock(cAliasQKO)
			dbDelete()
			MsUnlock()
			QKO->(dbSkip())
		Enddo
	Endif
Else
	cTexto    := "\13\10"
	dbSelectArea(cAliasQKO)
	dbseek(xFilial(cAliasQKO) + cEspecie + cChave)
	If Alltrim(cAliasQKO) == "QKO" 
		If !Eof() .and. QKO_FILIAL+QKO_ESPEC+QKO_CHAVE == xFilial(cAliasQKO)+cEspecie+cChave
			RecLock(cAliasQKO, .f.) // Lock
		Else
			RecLock(cAliasQKO, .t.) // Append
			cCampo  := cAliasQKO+"->"+cAliasQKO+"_FILIAL"
			&cCampo := xFilial(cAliasQKO)
			cCampo  := cAliasQKO+"->"+cAliasQKO+"_CHAVE"
			&cCampo := cChave
			cCampo  := cAliasQKO+"->"+cAliasQKO+"_ESPEC"
			&cCampo := cEspecie
		EndIf
		cCampo  := cAliasQKO+"->QKO_SEQ"
		&cCampo := "001"
		cCampo  := cAliasQKO+"->"+cAliasQKO+"_TEXTO" 
		&cCampo := cTexto
		MsUnlock()
	Endif
EndIf

dbSelectArea(cOldAlias)

Return NIl


/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噭o	 砆O_DelTxt � Autor � Vera / Wanderley 	    � Data � 04.12.97 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噭o � Deleta o texto editado com QO_TEXTO, a partir do axTextos. 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砈intaxe	 � QO_DelTxt(ExpC1,ExpC2,ExpN1,ExpC3)						  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� ExpC1 = Chave do Texto (j� convertida) 					  潮�
北�			 � ExpC2 = Especie do Texto									  潮�
北�			 � ExpC3 = Alias do arquivo para leitura (QKO ou tempor.)	  潮�
北�			 �  Obs.:  Se for arq. temp., deve ter a mesma estrut. do QKO.潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso		 � Generico 												  潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Function QO_DelTxt(cChave,cEspecie,cAliasQKO)

Local cOldAlias := Select()
Local cAlias

cAlias := Iif(cAliasQKO == NIL,"QKO",cAliasQKO)

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� Deleta o texto no QKO ou arq. temporario 				    �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
dbSelectArea(cAlias)
dbseek(xFilial(cAlias) + cEspecie + cChave)
While !Eof() .and. QKO_FILIAL+QKO_ESPEC+QKO_CHAVE == xFilial(cAlias)+cEspecie+cChave
	RecLock(cAlias, .f.) 
	dbDelete()        
	MsUnlock()
	dbSkip()
Enddo
FKCOMMIT()

dbSelectArea(cOldAlias)
Return

/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲uncao	 砆PP_CRONO � Autor � Robson Ramiro A Olivei� Data � 06.09.01 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噭o � Atualiza Cronograma                                        潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砈intaxe	 � QPP_CRONO(ExpC1,ExpC2,ExpC3)			        			  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� ExpC1 = Peca                           					  潮�
北�			 � ExpC2 = Revisao          								  潮�
北�			 � ExpC3 = ID da Atividade				                	  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso		 � SIGAPPAP 												  潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/

Function QPP_CRONO(cPeca,cRev,cID)

Local aArea 	:= {}
Local aUsrMat	:= {}

aArea 	:= GetArea()
aUsrMat	:= QA_USUARIO()

DbSelectArea("QKZ")
DbSetOrder(3)
If DbSeek(xFilial("QKZ") + cID)

	DbSelectArea("QKP")
	DbSetOrder(3)

	If DbSeek(xFilial("QKP")+ cPeca + cRev + QKZ->QKZ_COD)
		RecLock("QKP",.F.)

		If Empty(QKP->QKP_MAT)
			QKP->QKP_FILMAT	:= aUsrMat[2]
			QKP->QKP_MAT 	:= aUsrMat[3]
		Endif
	
		If Empty(QKP->QKP_DTINI)
			QKP->QKP_DTINI := dDataBase
		Endif

		If Empty(QKP->QKP_DTPRA)  
			QKP->QKP_DTPRA := dDataBase
		Endif

		QKP->QKP_DTFIM  := dDataBase
		QKP->QKP_PCOMP  := "4"
		QKP->QKP_LEGEND := "BR_CINZA"

		MsUnlock()
	Endif
Endif

DbSelectArea("QKP")
DbSetOrder(1)
 
RestArea(aArea)

Return


/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲uncao	 砆PPVldAlt � Autor � Robson Ramiro A Olivei� Data � 22.10.02 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escricao � Verifica se o processo pode ser alterado                   潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砈intaxe	 � QPPVldAlt(ExpC1,ExpC2) 			        			      潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� ExpC1 = Peca                           					  潮�
北�			 � ExpC2 = Revisao          								  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso		 � SIGAPPAP 												  潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/

Function QPPVldAlt(cPeca,cRev,cAprov)

Local aArea 	:= {}
Local lReturn	:= .T.
Local cRotina	:= Funname()

aArea 	:= GetArea()

DbSelectArea("QK1")
DbSetOrder(1)
DbSeek(xFilial("QK1")+ cPeca + cRev)

If QK1->QK1_STATUS <> "1"
	Alert(STR0001) //"O processo deve estar em aberto para ser alterado !"
	lReturn := .F.
Endif
If cRotina $ "QPPA120/QPPA130/QPPA131/QPPA150/QPPA160/QPPA170/QPPA180/QPPA190/QPPA200/QPPA210/QPPA340/QPPA350/QPPA360"
   	If !Empty(cAprov)
		If ALLTRIM(UPPER(cAprov)) <> ALLTRIM(UPPER(cUserName))
			DbSelectArea("QAA")
			DbSetOrder(6)
			If DbSeek(UPPER(cAprov))
				If QA_SitFolh()
					messagedlg(STR0002) //"O usu醨io logado n鉶 � o aprovador/respons醰el, para altera玢o dever� estar logado com o usu醨io aprovador"
					lReturn:= .F. 
				Else
					DbSelectArea("QAA")
					DbSetOrder(6)
					If DbSeek(UPPER(cUserName)) 
						messagedlg(STR0003) //"O usu醨io logado n鉶 � o aprovador, mas o usu醨io aprovador est� inativo,ser� permitida a altera玢o por outro usu醨io"
					
						lReturn:= .T.
					Else
						messagedlg(STR0004)//"O usu醨io logado n鉶 est� cadastrado no cadastro de usu醨ios do m骴ulo, portanto n鉶 poder� ser o aprovador")
					    lReturn:= .F.
					Endif
				Endif
			Endif
		Endif		    
	Endif 	
Endif

RestArea(aArea)

Return lReturn

/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲uncao	 砆PPTAMGET � Autor � Robson Ramiro A Olivei� Data � 09.05.03 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噭o � Retorna o tamanho limite da GetDados                       潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砈intaxe	 � QPPTAMGET(ExpC1, ExpN1)                        			  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� ExpC1 = Campo a ser avaliado           					  潮�
北�          � ExpN1 = Tipo do retorno                					  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso		 � SIGAPPAP 												  潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/

Function QPPTAMGET(cCampo,nTipo)

Local nTam := 0
Local cTam := ""
Local nReturn

nTam := TamSx3(cCampo)[1]

cTam := Replicate('9',nTam)

If nTipo == 1
	nReturn := Val(cTam)
Elseif nTipo == 2
	nReturn := nTam
Endif

Return nReturn

/*/
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲uncao    � PPAPVld      � Autor � Robson Ramiro A. Olive� Data � 26.08.03 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escricao � Validacao da digitacao, devido ao FreeForUse()                 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砈intaxe   � PPAPVld()                                                      潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� ExpC1 = Alias para validacao ExistChav                         潮�
北�          � ExpC2 = Chave de pesquisa                                      潮�
北�          � ExpN1 = Ordem                                                  潮�
北�          � ExpC3 = Alias para validacao ExistCpo                          潮�
北�          � ExpN2 = Ordem                                                  潮�
北�          � ExpN3 = Tipo de verificacao                                    潮�
北�          � ExpN4 = Numero de caracteres finais a excluir                  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砋so       � PPAP                                                           潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
/*/

Function PPAPVld(cAlias, cChave, nOrd, cAlias2, nOrd2, nTipo, nSizeCut)
Local lRetorno := .F.
Local cChaveX

Default cAlias2	 := "QK1"
Default nOrd	 := 1
Default nOrd2	 := 1
Default nTipo 	 := 1
Default nSizeCut := 3

If nTipo == 1
	cChaveX := cChave
Elseif nTipo == 2
	cChaveX := Subst(cChave,1,Len(cChave)-nSizeCut)
Endif

If ExistChav(cAlias,cChave,nOrd) .and. ExistCpo(cAlias2,cChaveX,nOrd2) .and. !Empty(cChave);
	.and. FreeForUse(cAlias, cChave)
	lRetorno := .T.
Endif

Return lRetorno


/*/{Protheus.doc} PPALOADEXEC
    Chamada das funcoes necessarias para inicializacao e valida珲es do modulo SIGAPPA
	Execu玢o antes das fun珲es do Modulo SIGAPPA                   	
    @type  Function
	@author Jamer N. Pedroso 
	@since 30/06/2023
	@version 1.0
/*/

Function PPALOADEXEC()

QA_TRAVUSR()  //Verificacao de Usuario Ativo

Return(NIL)


/*/
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲uncao    � PPALOAD      � Autor � Robson Ramiro A. Olive� Data � 06.01.04 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escricao � Funcao criada para substituir o X2_ROTINA()                    潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砈intaxe   � PPALoad()                                                      潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� Void                                                           潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砋so       � PPAP                                                           潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
/*/

Function PPALOAD()

QPP110Email()	// Dispara email
QPPC010(.T.)	// Checa pendencias

If GetMv("MV_QALOGIX") == "1" //Caso haja integracao com o Logix e exista alias QNB - verifica se tem inconsistencias nos WebServices
	If ChkFile("QNB")
		If GetMV("MV_QMLOGIX",.T.,"1") == "1" //Define se mostra a tela de inconsistencia 
		QXMSLOGIX()
		Endif
	Endif	
Endif	

Return Nil    

/*/
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲uncao    � PPALOAD      � Autor � Robson Ramiro A. Olive� Data � 06.01.04 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escricao � Funcao criada para substituir o X2_ROTINA()                    潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砈intaxe   � PPALoad()                                                      潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� Void                                                           潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砋so       � PPAP                                                           潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
/*/

Function PPAPLOAD()

/*
VISANDO MANTER  COMPATIBILIDADE COM OS OUTROS RELEASES DESTA VERSAO FOI DETERMINADO QUE A FUNCAO
PPAPLOAD CHAMARA A PPALOAD DESTA  FORMA CASO ESTA FUNCAO PRECISE DE ATUALIZACOES ESTAS NAO IRAO
PREJUDICAR O FUNCIONAMENTO DO MODULO EM OUTROS RELEASES.
ATENTAR PARA O FATO QUE AS ALTERACOES  DEVEM SER  FEITAS NA  FUNCAO ACIMA
*/
PPALOAD()

Return Nil

/*/
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲uncao    � PPAPBMP      � Autor � Robson Ramiro A. Olive� Data � 30.03.04 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escricao � Retira o BMP do RPO e salva em local especifico e retorn T ou F潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砈intaxe   � PPAPBMP()                                                      潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� ExpC1 = Nome do BMP no RPO                                     潮�
北�          � ExpC2 = Path para salvar o arquivo                             潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砋so       � Quality                                                        潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
/*/

Function PPAPBMP(cNome, cPath)

Local lReturn := .F.

cNome := Upper(cNome)

If !File(cPath+cNome,0) // 0 Default, 1 Server, 2 Remote
	lReturn := Resource2File(cNome, cPath+cNome)
Endif

Return lReturn


/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯脱屯屯屯屯屯送屯屯屯淹屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐�
北篜rograma  砆PPXFUN   篈utor  砇enata Cavalcante   � Data �  05/25/07   罕�
北掏屯屯屯屯拓屯屯屯屯屯释屯屯屯贤屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡�
北篋esc.     �  Valida玢o da exclus鉶                                     罕�
北�          �                                                            罕�
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北篣so       � Valida se a opera玢o pode ser executada                    罕�
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Function QPPVldExc(cRev,cAprov)

Local aArea 	:= {}
Local lReturn	:= .T.
Local cRotina	:= Funname()

aArea 	:= GetArea()

If cRotina $ "QPPA120/QPPA130/QPPA150/QPPA160/QPPA170/QPPA180/QPPA190/QPPA200/QPPA210/QPPA340/QPPA350/QPPA360"
   	If !Empty(cAprov)
		If ALLTRIM(UPPER(cAprov)) <> ALLTRIM(UPPER(cUserName))
			DbSelectArea("QAA")
			DbSetOrder(6)
			If DbSeek(UPPER(cAprov))
				If QA_SitFolh()
					messagedlg(STR0005) //"O usu醨io logado n鉶 � o aprovador/respons醰el, para exclus鉶 dever� estar logado com o usu醨io aprovador"
					lReturn:= .F. 
				Else
					DbSelectArea("QAA")
					DbSetOrder(6)
					If DbSeek(UPPER(cUserName)) 
						messagedlg(STR0006) //"O usu醨io logado n鉶 � o aprovador, mas o usu醨io aprovador est� inativo,ser� permitida a exclus鉶 por outro usu醨io"
					
						lReturn:= .T.
					Else
						messagedlg(STR0007)//"O usu醨io logado n鉶 est� cadastrado no cadastro de usu醨ios do m骴ulo, portanto n鉶 poder� ser o aprovador")
					    lReturn:= .F.
					Endif
				Endif
			Endif
		Endif		    
	Endif 	
Endif

RestArea(aArea)

Return lReturn
