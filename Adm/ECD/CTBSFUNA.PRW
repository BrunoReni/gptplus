#INCLUDE "CTBSFUNA.ch"
#Include "Protheus.ch"   
#INCLUDE "ECD.CH"

//Compatibiliza豫o de fontes 30/05/2018

Static aMsg := {}

/*
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿑un豫o de cria豫o do controle de mensagens do Ecd contabil        �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
*/
Function EcdNewMsg()

EcdClrMsg()

Return

/*
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿑un豫o de limpeza do controle de mensagens do Ecd contabil        �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
*/
Function EcdClrMsg()

aMsg  := {}

Return

/*
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿑un豫o de adi豫o de mensagens do Ecd contabil                     �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
*/
Function EcdAddMsg( cMsg, cTipo ) 

Local nX 		:= 0
Local aLines 	:= {}
// cMsg --> Conteudo da mensagem a ser guardada
// cTipo --> Tipo da mensagem := 1 -> Texto normal, 2 -> Erro , 3 -> Avisos

Default cTipo := '1'

IF !Empty( cMsg )

	aLines := ECDQuebraString(cMsg, 160)
	For nX := 1 To Len(aLines)
		Aadd( aMsg, { aLines[nX], cTipo  , cUsuario , dDatabase , Time() })
	Next

Endif

Return

/*
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿑un豫o para exibir o ultimo   encontrado no Ecd contabil       �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
*/
Function EcdLastMsg( cTipo )
Local nix := Len( aMsg )

Default cTipo := '1'

If nix > 0
	MsgAlert( aMsg[ nIx ][1] + Chr(13) + STR0001 + aMsg[ nIx ][2]+ Chr(13) + STR0002 + Dtoc( aMsg[ nIx ][3] ) ) //"Usuario :"###"Data :"
Else
	Conout( STR0003 ) //'N�o h� mensagens para exibir'
Endif

Return

/*
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿑un豫o para retorno da array contendo todas as mensagens           �
//� N�o utilizar em caso de manipula豫o, somente para exibi豫o        �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
*/
Function EcdGetMsg()
LOCAL cFileLog := ""
LOCAL cPath := ""  
LOCAL nX	:= 0


If !Empty(aMsg)
	For nX := 1 To Len(aMsg)
		AutoGrLog("LOG")
		AutoGrLog("---------------")
		AutoGrLog(STR0004+Dtoc(aMsg[nX][4])) //"DATA...............: "
		AutoGrLog(STR0005+aMsg[nX][5]) //"HORA...............: "
		AutoGrLog(STR0006+aMsg[nX][3]) //"USU핾IO............: "
		AutoGrLog(STR0007+aMsg[nX][1]) //"Erro:............: 	"
	Next
	
	cFileLog := NomeAutoLog()

	If cFileLog <> ""
   		MostraErro(cPath,cFileLog)
	Endif
EndIf
 
EcdClrMsg() // limpo o controle de mensagens de erro

Return .T.    


/*
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿑un豫o utilizada para retornar o array com as menssagens de erro   �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
*/
Function EcdRetMenssag()

If Empty(aMsg)
	EcdClrMsg()
EndIf
	
return aMsg  


/*
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//쿑un豫o utilizada para quebrar a String, retornando o array com os textos    �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
*/
Static Function ECDQuebraString(cTexto, nMaxSize)
//Array com os delimitadores (modifique se quiser):
Local aDelimiters := {" ", ".", ",", "/"}

Local aLines := {}
Local cSubTexto
Local nLastSpace
Local nCount := 1
Local nI

While cTexto <> ""
	If Len(cTexto) <= nMaxSize
		aAdd(aLines, Iif(nCount <= 1, "- ", Space(5))+cTexto)
		cTexto := ""
	Else
		cSubTexto := SubStr(cTexto, 1, nMaxSize + 1)

		nLastSpace := 0
		//Procura possiveis separadores, a partir da direita
		For nI := 1 To Len(aDelimiters)
			nLastSpace := RAt(aDelimiters[nI], cSubTexto)
			If nLastSpace <> 0
				Exit
			Endif
		Next

		//Se n�o encontrou, sinto muito, a palavra vai se quebrar
		If nLastSpace == 0
			nLastSpace := nMaxSize
		Endif
    
		aAdd(aLines, Iif(nCount <= 1, "- ", Space(5))+SubStr(cTexto, 1, nLastSpace - 1))
		cTexto := LTrim(SubStr(cTexto, nLastSpace))
		nCount++
	Endif
End

Return aLines
