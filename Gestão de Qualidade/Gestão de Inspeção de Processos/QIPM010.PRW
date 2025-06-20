#Include "QIPM010.CH"
#Include "PROTHEUS.CH"

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� QPM010 - Variaveis utilizadas para parametros					�
//� mv_par01				// Produto Origem    					�
//� mv_par02				// Revisao Origem 						�
//� mv_par03				// Produto Destino                		�
//� mv_par04				// Revisao Destino						�
//� mv_par05				// Origem da Descricao                  �
//� mv_par06				// Descricao do Produto Destino         �
//� mv_par07				// Roteiro De       	                �
//� mv_par08				// Roteiro Ate		                    �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

Static sMvPar05 := Nil
Static sMvPar06 := Nil
Static sMvPar07 := Nil
Static sMvPar08 := Nil

/*/
Fun豫o em desuso - descontinuada no RPO
*/
Function QIPM010()
Return(Nil)

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑un뇙o	 � Qip010ExPr � Autor � Marcelo Pimentel      � Data � 19/05/98 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇙o � Verif. se Prod. est� cadastrado ou se j� existe				낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇� Sintaxe  � Qip010ExPr(ExpC1)                             				낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿛arametros� ExpC1: "O" se for Produto Origem              				낢�
굇�          � ExpC1: "D" se for Produto Destino             				낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇� Uso		 � X1_VALID (QPM010)                            				낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Function Qip010ExPr(cPerg)
	Local cChave, lRet := .T.

	PergQPM010()

	If cPerg == "O"  // Produto Origem
		If !Isdigit(mv_par02)
			//Quando acertado o pergunte, colocar help
			//informando que campo deve ser numerico.
			Return(.F.)
		EndIf
		cChave := mv_par01 + Inverte(mv_par02)
		If naovazio()
			// Verifica se existe o Produto/Revisao
			If QP6->(DbSeek(xFilial('QP6') + cChave ))
				// Sugere a descricao do Produto Origem p/ o Produto Destino

				QP010Verif(sMvPar05)

				// Sugere a proxima revisao
				mv_par04 := QA_UltRvQ(mv_par01,dDataBase,.f.,.t.)
				mv_par03 := mv_par01
				If empty(mv_par04)
				mv_par04 := "00"
				Else
				mv_par04 := Soma1(mv_par04)
				While .t.
					If !FreeForUse("QP6",xFilial("QP6")+MV_PAR01+MV_PAR04)
						mv_par04 := Soma1(mv_par04)
					Else
						Exit
					EndIf
				EndDo
				EndIF
				lRet := .T.
			Else
				MsgAlert(STR0001,STR0002)		//"Produto/Revis�o n�o cadastrado"###"Aten눯o"
			EndIf
		EndIf
	Else	// Produto Destino
		If !Isdigit(mv_par04)
			// Quando acertado o pergunte, colocar help
			// informando que campo deve ser numerico.
			Return(.F.)
		EndIf
		cChave := mv_par03 + Inverte(mv_par04)
		If naovazio()
			If mv_par01 <> mv_par03
				// Verifica se j� existe o Produto/Revisao
				If !QP6->(DbSeek(xFilial('QP6') + cChave ))
					lRet := .T.
				Else
					MsgAlert(STR0003,STR0002)		//"Produto/Revis�o j� cadastrado"###"Aten눯o"
				EndIf
			EndIf
			QP010Verif(sMvPar05)
		EndIf
	EndIf
Return(lRet)
/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑un뇙o	 � Qip010CkPr � Autor � Marcelo Pimentel      � Data � 19/05/98 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇙o � Verifica se produto est� cadastrado                          낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇� Uso		 � X1_VALID                            							낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Function Qip010CkPr(cChamada)
	Local nRec		:= 0
	Local cSeek     := ""

	Default cChamada := "M"

	PergQPM010()

	If cChamada == "M"
		mv_par03 := Upper(mv_par03)
		mv_par04 := "00"
		cSeek    := mv_par03
	Else
		mv_par01 := Upper(mv_par01)
		mv_par02 := "00"
		cSeek    := mv_par01
	EndIf

	If naovazio()
		nRec := QP6->(recno())
		QP6->(dbSetOrder(1))
		If QP6->(DbSeek(xFilial('QP6') + cSeek),.T.)
			If QP6->(!EOF())
				If cChamada == "M"
					mv_par04 := Soma1(QP6->QP6_REVI)
				Else
					mv_par02 := Soma1(QP6->QP6_REVI)
				EndIf
			EndIF
			sMvPar06 := QP010Verif()
		Endif
		If dVigRev <= QP6->QP6_DTINI
			dVigRev := (QP6->QP6_DTINI+1)
		EndIf

		QP6->(dbSetOrder(1))
		QP6->(DbGoTo(nRec))
	EndIf
Return(.T.)

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑un뇙o	 � A010UpIns  � Autor � Wanderley Gon놹lves	  � Data � 29/01/98 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇙o � Verifica se Campo Produto nao esta vazio e converte para     낢�
굇�			 � maiusculo.													낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇� Uso		 � X1_VALID                               						낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Function A010UpIns()

	Local lRet := .f.

	PergQPM010()

	If naovazio()
		mv_par01 := Upper(mv_par01)
		lRet := .t.
	EndIf

	//Preenche o parametro MV_PAR02 com a ultima revisao do produto.
	If lRet
		If Empty(MV_PAR02)
			MV_PAR02 := QA_UltRvQ(mv_par01,dDataBase,.f.,.t.)
		EndIf
		sMvPar06 := QP010Verif()
	EndIF

Return(lRet)

/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑uncao	 � QP010Verif � Autor � Cleber Souza          � Data � 25/04/05 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇙o � Verifica de onde vira a descricao do produto                 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇� Uso		 � QIPM010                                 					    낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
Static Function QP010Verif(nEscolha)
	Local aAreaSB1   := SB1->(GetArea())
	Local cDes       := Space(TamSX3("B1_DESC")[1])

	If nEscolha == NIL
		nEscolha := sMvPar05
	EndIf

	If (nEscolha == 1)
		sMvPar06 := cDes

	ElseIf (nEscolha == 2)
		DbSelectArea("SB1")
		SB1->(dbSetOrder(1))
		If SB1->(DbSeek(xFilial("SB1")+MV_PAR01))
			cDes := SB1->B1_DESC
		EndIf

	ElseIf (nEscolha == 3)
		DbSelectArea("QP6")
		QP6->(dbSetOrder(1))
		If QP6->(DbSeek(xFilial("QP6")+MV_PAR01))
			cDes := QP6->QP6_DESCPO
		EndIf

	EndIf

	RestArea(aAreaSB1)
Return(cDes)

/*/{Protheus.doc} PergQPM010 
Prote豫o Error.log Chamadas Pergunte QPM010 com dicion�rio imcompat�vel
@author brunno.costa
@since 28/02/2022
@version 1.0
/*/
Static Function PergQPM010()
	If ValType(mv_par05) == "N"
		sMvPar05 := mv_par05
		sMvPar06 := mv_par06
		sMvPar07 := mv_par07
		sMvPar08 := mv_par08
	Else
		If ValType(mv_par08) == "N"
			sMvPar05 := mv_par08
		Else
			sMvPar05 := 1
		EndIf
		sMvPar06 := mv_par05
		sMvPar07 := mv_par06
		sMvPar08 := mv_par07
	EndIf
Return
