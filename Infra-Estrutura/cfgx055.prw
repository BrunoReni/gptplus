#Include "FiveWin.ch"
#Include "Folder.ch"
#Include "CFGX055.ch"

/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噮o    � CFGX055  � Autor � Mauricio Pequim Jr    � Data � 24.08.98 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噮o � Configurador de Arquivos de Extrato - Padrao Febraban		  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砈intaxe   � CFGX055()                                                  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros�                                                            潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
*/
FUNCTION CFGX055(void)

// 谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
// � Define Variaveis                                            �
// 滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
Local bExec
Local oDlg
Local oRadio

Private nOpcf   :=1
Private aHeader :={{Space(15),Space(03),Space(03),Space(01),Space(60)}}
Private aLancto :={{Space(15),Space(03),Space(03),Space(01),Space(60)}}
Private aTrail  :={{Space(15),Space(03),Space(03),Space(01),Space(60)}}
Private cFile   :=""
Private cType   :=""
Private nBcoHdl :=0

/*/
谀哪哪哪哪哪哪哪哪哪哪哪哪�
� Arquivo de Com.Bancaria �
�    Remessa/Retorno      �
�                         �
� Memoria de Calculo      �     谀哪哪哪哪哪哪哪哪哪哪哪哪�
� Registro 1 - USUARIOS   �     矷dentificadores          �
� - Identif    CHR(n)   1 �     � CHR(1)   - Header       �
� - Descricao do Campo 15 �     � CHR(2)   - Saldo Inicial�
� - Posicao Inical      3 �     � CHR(3)   - Lancamento   �
� - Posicao Final       3 �     � CHR(4)   - Saldo Final  �
� - Decimais            1 �     � CHR(5)   - Trailler     �
� - Campo/Conteudo     60 �     滥哪哪哪哪哪哪哪哪哪哪哪哪�
滥哪哪哪哪哪哪哪哪哪哪哪哪�
/*/

aH := {	{OemToAnsi(STR0001),Space(03),Space(03),Space(01),Space(60)},; // "Codigo do Banco"
			{OemToAnsi(STR0004),Space(03),Space(03),Space(01),Space(60)},; // "Tipo Registro  "
			{OemToAnsi(STR0053),Space(03),Space(03),Space(01),Space(60)},; // "Vlr Sld Inicial"
			{OemToAnsi(STR0054),Space(03),Space(03),Space(01),Space(60)},; // "Dt. Sld Inicial"
			{OemToAnsi(STR0045),Space(03),Space(03),Space(01),Space(60)} } // "Saldo D/C      "

aL := {	{OemToAnsi(STR0003),Space(03),Space(03),Space(01),Space(60)},; // "Codigo Agencia "
			{OemToAnsi(STR0050),Space(03),Space(03),Space(01),Space(60)},; // "Codigo C/C     "
			{OemToAnsi(STR0005),Space(03),Space(03),Space(01),Space(60)},; // "Numero Lancam. "
			{OemToAnsi(STR0006),Space(03),Space(03),Space(01),Space(60)},; // "Data Processam."
			{OemToAnsi(STR0007),Space(03),Space(03),Space(01),Space(60)},; // "Vlr Lancamento "
			{OemToAnsi(STR0052),Space(03),Space(03),Space(01),Space(60)},; // "Categoria Lcto."
			{OemToAnsi(STR0009),Space(03),Space(03),Space(01),Space(60)},; // "Desc.Lancamento"
			{OemToAnsi(STR0004),Space(03),Space(03),Space(01),Space(60)} } // "Tipo Registro  "

aT := {	{OemToAnsi(STR0010),Space(03),Space(03),Space(01),Space(60)},; // "Dt. Saldo Final"
			{OemToAnsi(STR0011),Space(03),Space(03),Space(01),Space(60)},; // "Vlr Saldo Final"
			{OemToAnsi(STR0045),Space(03),Space(03),Space(01),Space(60)},; // "Saldo D/C      "
			{OemToAnsi(STR0004),Space(03),Space(03),Space(01),Space(60)},; // "Tipo Registro  "
			{OemToAnsi(STR0012),Space(03),Space(03),Space(01),Space(60)},; // "Total Debitos  "
			{OemToAnsi(STR0013),Space(03),Space(03),Space(01),Space(60)} } // "Total Creditos "

// 谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
// � Recupera o desenho padrao de atualizacoes                   �
// 滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
DEFINE MSDIALOG oDlg FROM  94,1 TO 243,295 TITLE OemToAnsi(STR0029) PIXEL // "Configura噭o Extrato Bancario"

@ 10,17 Say OemToAnsi(STR0015) SIZE 150,7 OF oDlg PIXEL  // "Estrutura噭o dos arquivos de LayOut utilizados"
@ 18,30 Say OemToAnsi(STR0017) SIZE 100,7 OF oDlg PIXEL  // "na comunica噭o banc爎ia (Extratos)."

@ 48, 005 Button OemToAnsi(STR0018)     SIZE 33, 11 OF oDlg PIXEL   Action(nOpcf:=1,TipoFile(),MudaArq()   ,If(!Empty(cFile),EditExtr(oDlg),nOpcf:=0))       Font oDlg:oFont // "Novo"
@ 48, 040 Button OemToAnsi(STR0019)     SIZE 33, 11 OF oDlg PIXEL   Action(nOpcf:=2,TipoFile(),MudaArq()   ,If(!Empty(cFile),RestFile(oDlg),nOpcf:=0))       Font oDlg:oFont // "Restaura"
@ 48, 075 Button OemToAnsi(STR0020)     SIZE 33, 11 OF oDlg PIXEL   Action(nOpcf:=3,TipoFile(),MudaArq()   ,If(!Empty(cFile),RestFile(oDlg,.T.),nOpcf:=0))   Font oDlg:oFont // "Excluir"
@ 48, 110 Button OemToAnsi(STR0021)     SIZE 33, 11 OF oDlg PIXEL   Action(nopcf:=4,oDlg:End())                                                                 Font oDlg:oFont // "Cancelar"

ACTIVATE MSDIALOG oDlg CENTERED


/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噮o    矼udaArq   � Autor � Mauricio Pequim Jr    � Data � 24.08.98 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噮o � Escolhe arquivo ou cria arquivo para padroniza嚻o CNAB     潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砈intaxe   � MudaArq()                                                  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros�                                                            潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
*/
Static Function MudaArq()

Local cFileChg
Local cCheck
Local cBack     := cFile

If  Empty(cType)
	cType   :=Iif(nOpcf==1,OemToAnsi(STR0022)+'SIGA.REC',OemToAnsi(STR0022)+'*.REC')   // "Retorno | "
Endif

cFileChg    :=cGetFile(cType, OemToAnsi(OemToAnsi(STR0023)+Subs(cType,1,7) ) ) // "Selecione arquivo "

If  Empty(cFileChg)
	cFile:=""
	Return
Endif

If  "."$cFileChg
	cFileChg := Substr(cFileChg,1,rat(".", cFileChg)-1)
Endif

cFileChg    := alltrim(cFileChg)
cFile       := Alltrim(cFileChg+Right(cType,4))

If  nOpcf == 1
	If  File(cFile)
		cFile:=""
		Help(" ",1,"AX023EXIST")
		Return
	Endif
Else
	cType   :="Retorno | "+cFile
Endif

Return


/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噮o    矱ditEXTR  � Autor � Marcos Patricio       � Data � 05.02.96 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噮o 矱dita LayOut do arquivo de Extratos                         潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砈intaxe   矱ditExtr(oDlg,cFile)                                        潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros硂Dlg     - Objeto pai da janela                             潮�
北�          砽Dele    - Arquivo a ser Criado/Editado                     潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso      � MATCONF                                                    潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
*/

Static Function EditEXTR(oDlg,lDele)

Local oDlgLayOut
local oGetH
Local oGetL
Local oGetT
Local oLbHeader
Local oLbLancto
Local oLbTrail
Local oBarHeader
Local oBarLancto
Local oBarTrail
Local nControl  := 0
Local aTitles   := {}
Local aPages    := {}
Local nHeader   := 0
Local nLancto   := 0
Local nTrail    := 0
Local lConfirma := .T.
Local i

lDele   :=IIF(lDele==NIL,.F.,lDele)

If  nOpcf==1
	aHeader :=  Aclone(aH)
	aLancto :=  Aclone(aL)
	aTrail  :=  Aclone(aT)
Endif

AADD(aTitles,OemToAnsi(STR0024))  // "Header"
AADD(aPages,"HEADER")
nControl++
nHeader := nControl

AADD(aTitles,OemToAnsi(STR0026)) // "Lan嘺mentos"
AADD(aPages,"DETAIL")
nControl++
nLancto := nControl

AADD(aTitles,OemToAnsi(STR0028))  // "Trailler"
AADD(aPages,"TRAIL")
nControl++
nTrail  := nControl
SETAPILHA()
DEFINE MSDIALOG oDlgLayOut TITLE OemToAnsi(STR0029)+Space(05)+cFile ; // "Configura噭o Extrato Bancario"
FROM 8.0,0 to 34.5,81 OF oMainWnd

oFolder := TFolder():New(.5,.2,aTitles, aPages,oDlgLayOut,,,, .F., .F.,315,170,)

For i:= 1 to Len(oFolder:aDialogs)
	oFolder:aDialogs[i]:oFont := oDlgLayOut:oFont
Next

oFolder:aPrompts[1] := OemToAnsi(STR0030) // "&Header"
oFolder:aPrompts[2] := OemToAnsi(STR0032) // "&Lanctos."
oFolder:aPrompts[3] := OemToAnsi(STR0034) // "&Trailler"

PUBLIC nLastKey := 0

DEFINE SBUTTON FROM 180,255.5 TYPE 1 ENABLE OF oDlgLayOut ACTION (If(lConfirma:=If(lDele,DeleFile(),SaveFile()),oDlgLayout:End(),NIL))
DEFINE SBUTTON FROM 180,285.5 TYPE 2 ENABLE OF oDlgLayOut ACTION (oDlgLayOut:End())

// 谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
// � Header				                                            �
// 滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
@ 1,.2 LISTBOX oLbHeader FIELDS HEADER	OemToAnsi(STR0035),; // "Campo"
													OemToAnsi(STR0036),; // "Pos. Inicial"
													OemToAnsi(STR0037),; // "Pos. Final"
													OemToAnsi(STR0038),; // "Decimais"
													OemToAnsi(STR0039);  // "Conteo"
		COLSIZES 50,30,30,30,30 ;
		SIZE 307,140 OF oFolder:aDialogs[nHeader] ;
		ON DBLCLICK (LineOut(oLbHeader:nAt,"H",.F.),oLbHeader:Refresh()) // Edi嚻o

oLbHeader:SetArray(aHeader)
oLbheader:bLine  := { || { aHeader[oLbHeader:nAt,1] ,;
									aHeader[oLbHeader:nAt,2] ,;
									aHeader[oLbHeader:nAt,3] ,;
									aHeader[oLbHeader:nAt,4] ,;
									aHeader[oLbHeader:nAt,5] } }


// 谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
// � Lancamentos                                                 �
// 滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
@ 1,.2 LISTBOX oLbLancto FIELDS HEADER    OemToAnsi(STR0035),; // "Campo"
														OemToAnsi(STR0036),; // "Pos. Inicial"
														OemToAnsi(STR0037),; // "Pos. Final"
														OemToAnsi(STR0038),; // "Decimais"
														OemToAnsi(STR0039);  // "Conteo"
		COLSIZES 50,30,30,30,30 ;
		SIZE 307,140 OF oFolder:aDialogs[nLancto] ;
		ON DBLCLICK (LineOut(oLbLancto:nAt,"L",.F.),oLbLancto:Refresh()) // Edi嚻o

oLbLancto:SetArray(aLancto)
oLbLancto:bLine   := { || { aLancto[oLbLancto:nAt,1]  ,;
	aLancto[oLbLancto:nAt,2]  ,;
	aLancto[oLbLancto:nAt,3]  ,;
	aLancto[oLbLancto:nAt,4]  ,;
	aLancto[oLbLancto:nAt,5]  } }


// 谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
// � Trailler                                                    �
// 滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�

@ 1,.2 LISTBOX oLbTrail FIELDS HEADER  OemToAnsi(STR0035),; // "Campo"
													OemToAnsi(STR0036),; // "Pos. Inicial"
													OemToAnsi(STR0037),; // "Pos. Final"
													OemToAnsi(STR0038),; // "Decimais"
													OemToAnsi(STR0039);  // "Conteo"
		COLSIZES 50,30,30,30,30 ;
		SIZE 370,140 OF oFolder:aDialogs[nTrail] ;
		ON DBLCLICK (LineOut(oLbTrail:nAt,"T",.F.),oLbTrail:Refresh()) // Edi嚻o

oLbTrail:SetArray(aTrail)
oLbTrail:bLine   := { || { aTrail[oLbTrail:nAt,1] ,;
									aTrail[oLbTrail:nAt,2] ,;
									aTrail[oLbTrail:nAt,3] ,;
									aTrail[oLbTrail:nAt,4] ,;
									aTrail[oLbTrail:nAt,5] } }


ACTIVATE DIALOG oDlgLayOut ON INIT(FldTool(oFolder,oLbHeader,oLbLancto,oLbTrail,nHeader,nLancto,nTrail))
SETAPILHA()
aHeader :={}
aDetail :={}
aTrail  :={}

aHeader :={{Space(15),Space(03),Space(03),Space(01),Space(60)}}
aLancto :={{Space(15),Space(03),Space(03),Space(01),Space(60)}}
aTrail  :={{Space(15),Space(03),Space(03),Space(01),Space(60)}}

/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噮o    � RestFile � Autor � Wagner Xavier         � Data �          潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噮o � Restaura arquivos de Comunicacao Bancaria ja Configurados  潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/
Static Function RestFile(oDlg,lDele)
LOCAL nTamArq,nBytes:=0,xBuffer,lSave,i

lDele:=IIF(lDele==NIL,.F.,lDele)

If !File(cFile)
	cFile:=""
	Help(" ",1,"AX023BCO")
	Return
Endif

nBcoHdl :=FOPEN(cFile,2+64)
nTamArq :=FSEEK(nBcoHdl,0,2)
FSEEK(nBcoHdl,0,0)

aHeader :={}
aLancto :={}
aTrail  :={}

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Preenche os arrays de acordo com a Identificador             �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
While nBytes < nTamArq
	xBuffer := Space(85)
	FREAD(nBcoHdl,@xBuffer,85)
	IF SubStr(xBuffer,1,1) == CHR(1)
		AADD(aHeader,{	SubStr(xBuffer,02,15) ,SubStr(xBuffer,17,03),;
			SubStr(xBuffer,20,03) ,SubStr(xBuffer,23,01),;
			SubStr(xBuffer,24,60 ) } )
	Elseif SubStr(xBuffer,1,1) == CHR(3)
		AADD(aLancto,{	SubStr(xBuffer,02,15) ,SubStr(xBuffer,17,03),;
			SubStr(xBuffer,20,03) ,SubStr(xBuffer,23,01),;
			SubStr(xBuffer,24,60) } )
	Elseif SubStr(xBuffer,1,1) == CHR(5)
		AADD(aTrail,{	SubStr(xBuffer,02,15) ,SubStr(xBuffer,17,03),;
			SubStr(xBuffer,20,03) ,SubStr(xBuffer,23,01),;
			SubStr(xBuffer,24,60) } )
	Endif
	nBytes += 85
EndDO
IF Len(aHeader)==0 .And. Len(aLancto)==0 .And. Len(aTrail)==0
	HELP(" ",1,"AX023BCO")
	Return
ENDIF
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Iguala Array Original com existente.                         �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
If Len( aHeader) < Len( aH  )
	For i:=Len(aHeader)+1 To Len(aH)
		Aadd( aHeader, { aH[i,1], Spac(3), Spac(3), Spac(3), Space(60) } )
	Next i
End

If Len( aLancto ) < Len( aL  )
	For i:=Len(aLancto)+1 To Len(aL)
		Aadd( aLancto, { aL[i,1], Spac(3), Spac(3), Spac(3), Space(60) } )
	Next i
End

If Len( aTrail ) < Len( aT  )
	For i:=Len(aTrail)+1 To Len(aT)
		Aadd( aTrail , { aT[i,1], Space(3), Space(3), Space(3), Space(60) } )
	Next i
End

If  Empty(aHeader)
	aHeader :=Aclone(aH)
Endif

If  Empty(aLancto)
	aLancto  :=Aclone(aL)
Endif

If  Empty(aTrail)
	aTrail  :=Aclone(aT)
Endif

EditExtr(oDlg,lDele)

FCLOSE(nBcoHdl)
Return


/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噮o    � SaveFile � Autor � Wagner Xavier         � Data �          潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噮o � Salva arquivos de Comunicacao Bancaria ja Configurados     潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砈intaxe   砈aveFle(cFile)                                              潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros砪File    - Arquivo a ser Criado/Editado                     潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso      � MATCONF                                                    潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Static Function SaveFile()

LOCAL cReg1
Local i
Local lCreat    :=.F.
Local cRegA
Local cFileback :=cFile

IF  nOpcf == 2
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//� Escolhe o nome do Arquivo a ser salvo                        �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
	MudaArq()
	If  Empty(cFile)
		Return .F.
	Endif
	
	If  cFile#cFileBack .AND. File(cFile)
		If  !MsgYesNo(OemToAnsi(STR0040),OemToAnsi(STR0043)) // "Arquivo LayOut j� existe grava por cima" ### "LayOut Extrato"
			cFile   :=""
			Return .F.
		Endif
	Endif
Else
	If  !MsgYesNo(OemToAnsi(STR0041),OemToAnsi(STR0043)) // "Confirma Grava噭o do arquivo LayOut" ### "LayOut Extrato"
		Return .F.
	Endif
EndIF

fClose(nBcoHdl)
nBcoHdl:=MSFCREATE(cFile,0)

FSEEK(nBcoHdl,0,0)

x055Form(aHeader,1)
x055Form(aLancto,3)
x055Form(aTrail ,5)

FCLOSE(nBcoHdl)
Return .T.

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噮o    � DeleFile � Autor � Wagner Xavier         � Data �          潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噮o � Deleta   arquivos de Comunicacao Bancaria ja Configurados  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砈intaxe   � DeleFile()                                                 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros�                                                            潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Static Function DeleFile()

If  Len(aHeader) > 0
	If MsgYesNo(OemToAnsi(STR0042),OemToAnsi(STR0043)) // "Deleta arquivo LayOut"  ### "LayOut Extrato"
		FCLOSE(nBcoHdl)
		FERASE(cFile)
	Endif
Endif
Return .T.


/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噮o    矻ineOut   � Autor � Mauricio Pequim Jr    � Data � 24.08.98 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噮o � Acepta linha do LayOut                                     潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砈intaxe   � LiOut(nItem,Folder,lProcess)                               潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� nItem    - Item do array                                   潮�
北�          � Folder   - Folder Focado                                   潮�
北�          � lProcess - Processo Inclus苚 ou Altera嚻o                  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso      � MATCONF                                                    潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�

*/
Static Function  LineOut(nItem,Folder)

Local nOpca     :=0
Local cPosBco   :=Space(15)
Local cPosIni   :=Space(03)
Local cPosFin   :=Space(03)
Local cLenDec   :=Space(01)
Local cConteudo :=Space(60)
Local oDlg

If nOpcf==3
	Return
Endif

If  Folder=="H"
	IF  Len(aHeader)==1 .AND. (Empty(aHeader[1,1]) .AND. Empty(aHeader[1,2]) .AND. Empty(aHeader[1,3]))
		MsgStop(OemToAnsi(STR0044),OemToAnsi(STR0043))  // "N刼 h� dados para altera噭o" ### "LayOut Extrato"
		Return
	Else
		cPosBco    :=OemToAnsi(aHeader[nItem,1])
		cPosIni    :=aHeader[nItem,2]
		cPosFin    :=aHeader[nItem,3]
		cLenDec    :=aHeader[nItem,4]
		cConteudo  :=OemToAnsi(aHeader[nItem,5])
	Endif
Elseif Folder =="L"
	IF  Len(aLancto)==1 .AND. (Empty(aLancto[1,1]) .AND. Empty(aLancto[1,2]) .AND. Empty(aLancto[1,3]) )
		MsgStop(OemToAnsi(STR0044),OemToAnsi(STR0043)) // "N刼 h� dados para altera噭o" ### "LayOut Extrato"
		Return
	Else
		cPosBco    :=OemToAnsi(aLancto[nItem,1])
		cPosIni    :=aLancto[nItem,2]
		cPosFin    :=aLancto[nItem,3]
		cLenDec    :=aLancto[nItem,4]
		cConteudo  :=OemToAnsi(aLancto[nItem,5])
	Endif
Else
	IF  Len(aTrail)==1 .AND. ( Empty(aTrail[1,1]) .AND. Empty(aTrail[1,2]) .AND. Empty(aTrail[1,3]) )
		MsgStop(OemToAnsi(STR0044),OemToAnsi(STR0043)) // "N刼 h� dados para altera噭o" ###  "LayOut Extrato"
		Return
	Else
		cPosBco    :=OemToAnsi(aTrail[nItem,1])
		cPosIni    :=aTrail[nItem,2]
		cPosFin    :=aTrail[nItem,3]
		cLenDec    :=aTrail[nItem,4]
		cConteudo  :=OemToAnsi(aTrail[nItem,5])
	Endif
Endif

DEFINE MSDIALOG oDlg FROM  15,6 TO 196,366 TITLE OemToAnsi(STR0043) PIXEL // "LayOut Extrato"

@ -2, 2 TO 74, 179 OF oDlg  PIXEL

@ 08,05 SAY     OemToAnsi(STR0035)      SIZE 22, 07 OF oDlg PIXEL // "Campo"
@ 07,53 MSGET   cPosBco Picture "@X"  When .F.  SIZE 70, 10 OF oDlg PIXEL

@ 21,05 SAY     OemToAnsi(STR0036) SIZE 46, 07 OF oDlg PIXEL // "Pos. Inicial"
@ 20,53 MSGET   cPosIni  Picture "999"  SIZE 21, 10 OF oDlg PIXEL

@ 34,05 SAY     OemToAnsi(STR0037)   SIZE 41, 07 OF oDlg PIXEL // "Pos. Final"
@ 33,53 MSGET   cPosFin  Picture "999"  SIZE 21, 10 OF oDlg PIXEL

@ 47,05 SAY     OemToAnsi(STR0038)   SIZE 028,07 OF oDlg PIXEL // "Decimais"
@ 46,53 MSGET   cLenDec  Picture "9"    SIZE 011,10 OF oDlg PIXEL

@ 60,05 SAY     OemToAnsi(STR0039)   SIZE 031,07 OF oDlg PIXEL // "Conteo"
@ 59,53 MSGET   cConteudo              When .F. SIZE 123,10 OF oDlg PIXEL

DEFINE SBUTTON FROM 77,124 TYPE 1 ENABLE OF oDlg ACTION ( TipoFile(),nOpca:=1,oDlg:End())
DEFINE SBUTTON FROM 77,152 TYPE 2 ENABLE OF oDlg ACTION oDlg:End()

ACTIVATE MSDIALOG oDlg CENTERED
If  nOpca == 1
	If Folder=="H"
		aHeader[nItem]   :={cPosBco,cPosIni,cPosFin,cLenDec,cConteudo}
	Elseif Folder =="L"
		aLancto[nItem]   :={cPosBco,cPosIni,cPosFin,cLenDec,cConteudo}
	Else
		aTrail[nItem]    :={cPosBco,cPosIni,cPosFin,cLenDec,cConteudo}
	Endif
Endif

Return



/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噮o    � TipoFile � Autor � Mauricio Pequim Jr    � Data � 24.08.98 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噮o � Seta o tipo de arqruivo em uso                             潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砈intaxe   � TipoFile()                                                 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros�                                                            潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso      � MATCONF                                                    潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�

*/
Static Function TipoFile()

cType   :=Iif(nOpcf==1,OemToAnsi(STR0022)+'SIGA.REC',OemToAnsi(STR0022)+'*.REC') // "Retorno | "

Return Nil


/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪目北
北矲un噮o    � FldTool  � Autor � Mauricio Pequim Jr     � Data � 05.02.96 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪拇北
北矰escri噮o � Barra de bot鋏s das pastas                                  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北砅arametros� oFld         - Objeto do Folder                             潮�
北�          � oLbHeader    - Objeto ListBox do Header                     潮�
北�          � oLbDetail    - Objeto ListBox do Detail                     潮�
北�          � oLbTrail     - Objeto ListBox do Trail                      潮�
北�          � nHeader      - Referencia da pasta do Objeto Folder         潮�
北�          � nDetail      - Referencia da pasta do Objeto Folder         潮�
北�          � nTrail       - Referencia da pasta do Objeto Folder         潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北� Uso      � MATCONF                                                     潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁北
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北

*/
Static Function FldTool(oFld,oLbHeader,oLbLancto,oLbTrail,nHeader,nLancto,nTrail)

@ .1,02 BUTTON OemToAnsi(STR0051) SIZE 25,10 OF oFld:aDialogs[nHeader] ACTION (LineOut(oLbHeader:nAt,"H"),oLbHeader:Refresh()) //"Editar"

@ .1,02 BUTTON OemToAnsi(STR0051) SIZE 25,10 OF oFld:aDialogs[nLancto] ACTION (LineOut(oLbLancto:nAt,"L"),oLbLancto:Refresh()) //"Editar"

@ .1,02 BUTTON OemToAnsi(STR0051) SIZE 25,10 OF oFld:aDialogs[nTrail] ACTION (LineOut(oLbTrail:nAt,"T"),oLbTrail:Refresh()) //"Editar"


RETURN NIL

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噮o    � X055Form � Autor � Wagner Xavier         � Data �          潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噮o � Grava um Array no Novo Arquivo de Comunicao Bancaria       潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Static Function x055Form(aComun,nIdent)

Local i
Local cReg1
Local cRegA
For i:=1 To Len(aComun)
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//� Verifica se a linha esta em branco                           �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
	
	cReg1:= aComun[i][1]+aComun[i][2]+;
		aComun[i][3]+aComun[i][4]+aComun[i][5]
	IF !Empty(cReg1)
		cRegA:= CHR(nIdent)+cReg1
		FWRITE(nBcoHdl,cRegA+CHR(13)+CHR(10),85)   //grava nova linha
	EndIF
Next i


