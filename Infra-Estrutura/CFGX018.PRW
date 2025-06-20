/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � CFGx018  � Autor � Vinicius Barreira     � Data � 06.02.96 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Configurador da Impress�o de Boletos                       ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � CFGx018(void)                                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Sem Argumentos                                             ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Configurador   � Fun��o Relacionada � Entrada Dados (Todos)���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
#include "FiveWin.ch"
#include "cfgx018.ch"

Function Cfgx018()

LOCAL lJaCarregou := .F.
LOCAL nLaco := 0
LOCAL oDlg,oCbx,oGet

PRIVATE cL2:=cL3:=cL4:=cL6:="   "
PRIVATE cL1:=cL5:=cL7:=cL8:=cL9:=cL10:=cL11:=cL12:=cL13:="   "
PRIVATE cC2:=cC3:=cC4:=cC6:="   "
PRIVATE cC1:=cC5:=cC7:=cC8:=cC9:=cC10:=cC11:=cC12:=cC13:="   "
PRIVATE cC14:=cC15:="   "
PRIVATE cL14:=cL15:="   " 
PRIVATE cSal:="   "
PRIVATE cCol:=" "
PRIVATE cPas:="   "
PRIVATE cEqu:=" "
PRIVATE cSex:=" "
PRIVATE cMsg1 := cMsg2 := cMsg3 := space(80)
PRIVATE cbanco := ""
PRIVATE aBancos := {}
PRIVATE nOpc := 0
PRIVATE aObjGet := Array(38)

//����������������������������������������������������������������Ŀ
//� Carrega o Array usado pelo ComboBox de escolha dos Bancos      �
//������������������������������������������������������������������
dbSelectArea("SA6")
dbSeek( cFilial )
While SA6->A6_FILIAL == cFilial .And. !Eof()
    
    lJaCarregou := .F.
    For nLaco := 1 to Len( aBancos )
        If Left( aBancos[nLaco] , Len(SA6->A6_COD) ) == SA6->A6_COD
            lJaCarregou := .T.
            Exit
        Endif    
    EndFor
    If .NOT. lJaCarregou 
        AADD( aBancos, SA6->A6_COD + " " + SA6->A6_NREDUZ  )
    Endif
    dbSkip()
End
If Len( aBancos ) > 0
    cBanco := aBancos[1]
    RestConf( .F. )
Endif        
For nLaco := 1 to Len( aObjGet )
    aObjGet[nLaco] := oGet
EndFor

nOpc := 0
DEFINE MSDIALOG oDlg FROM 36,1 TO 375,600 TITLE OemToAnsi(STR0001) PIXEL	// "Configura��o da Impress�o de Boletos"
    
@ 015, 004 TO 169, 124 LABEL OemToAnsi(STR0002) OF oDlg  PIXEL  // "Conte�do do Boleto"
@ 019, 068 TO 165,  95 LABEL OemToAnsi(STR0003) OF oDlg  PIXEL // "Lin"
@ 019,  96 TO 165, 122 LABEL OemToAnsi(STR0004) OF oDlg  PIXEL // "Col"
@ 02, 128 TO 046, 262 LABEL ""    OF oDlg  PIXEL
@ 002, 206 TO 045, 232 LABEL OemToAnsi(STR0003) OF oDlg  PIXEL // "Lin"
@ 002, 234 TO 045, 259.5 LABEL OemToAnsi(STR0004) OF oDlg  PIXEL // "Col"
@ 048, 128 TO 119, 299 LABEL OemToAnsi(STR0005) OF oDlg  PIXEL // "Formata��o do Boleto"
@ 054, 248 TO 117, 276 LABEL ""    OF oDlg  PIXEL
@ 120, 128 TO 169, 299 LABEL OemToAnsi(STR0006) OF oDlg  PIXEL // "Mensagem"
@ 02, 264 TO 046, 299 LABEL ""    OF oDlg  PIXEL     
    
@ 003, 004 COMBOBOX oCbx Var cBanco ITEMS aBancos SIZE 120, 12 OF oDlg PIXEL ON CHANGE RESTCONF(.T.)
@ 025, 008 SAY OemToAnsi(STR0007)      SIZE 70, 07 OF oDlg PIXEL 		// "Local de Pagamento"
@ 025, 071 MSGET aObjget[01] Var cL1   SIZE 12, 8 OF oDlg PIXEL Picture "999"
@ 025,  98 MSGET aObjget[02] Var cC1   SIZE 12, 8 OF oDlg PIXEL Picture "999"
@ 037, 008 SAY OemToAnsi(STR0008)      SIZE 70, 07 OF oDlg PIXEL 		// "Vencimento"
@ 036, 071 MSGET aObjget[03] Var cL2   SIZE 12, 8 OF oDlg PIXEL Picture "999"
@ 036,  98 MSGET aObjget[04] Var cC2   SIZE 12, 8 OF oDlg PIXEL Picture "999"
@ 048, 008 SAY OemToAnsi(STR0009)      SIZE 70, 07 OF oDlg PIXEL 		// "Data Documento"
@ 048, 071 MSGET aObjget[05] Var cL3   SIZE 12, 8 OF oDlg PIXEL Picture "999"
@ 048,  98 MSGET aObjget[06] Var cC3   SIZE 12, 8 OF oDlg PIXEL Picture "999"
@ 060, 008 SAY OemToAnsi(STR0010)  	 SIZE 70, 07 OF oDlg PIXEL				// "N�mero do Documento"
@ 059, 071 MSGET aObjget[07] Var cL4   SIZE 12, 8 OF oDlg PIXEL Picture "999"
@ 059,  98 MSGET aObjget[08] Var cC4   SIZE 12, 8 OF oDlg PIXEL Picture "999"
@ 071, 008 SAY OemToAnsi(STR0011) 		 SIZE 70, 07 OF oDlg PIXEL				// "Esp�cie do Documento"
@ 070, 071 MSGET aObjget[09] Var cL5   SIZE 12, 8 OF oDlg PIXEL Picture "999"
@ 070,  98 MSGET aObjget[10] Var cC5   SIZE 12, 8 OF oDlg PIXEL Picture "999"
@ 082, 008 SAY OemToAnsi(STR0012)      SIZE 69, 07 OF oDlg PIXEL     		// "Aceite"
@ 082, 071 MSGET aObjget[11] Var cL6   SIZE 12, 8 OF oDlg PIXEL Picture "999"
@ 082,  98 MSGET aObjget[12] Var cC6   SIZE 12, 8 OF oDlg PIXEL Picture "999"
@ 094, 008 SAY OemToAnsi(STR0013)      SIZE 70, 07 OF oDlg PIXEL      		//"Valor em R$"
@ 093, 071 MSGET aObjget[13] Var cL7   SIZE 12, 8 OF oDlg PIXEL Picture "999"
@ 093,  98 MSGET aObjget[14] Var cC7   SIZE 12, 8 OF oDlg PIXEL Picture "999"
@ 105, 008 SAY OemToAnsi(STR0014)  SIZE 68, 07 OF oDlg PIXEL  				// "Valor em Outra Moeda"     
@ 105, 071 MSGET aObjget[15] Var cL8   SIZE 12, 8 OF oDlg PIXEL Picture "999"
@ 105,  98 MSGET aObjget[16] Var cC8   SIZE 12, 8 OF oDlg PIXEL Picture "999"
@ 117, 008 SAY OemToAnsi(STR0015)      SIZE 69, 07 OF oDlg PIXEL      		 //"Sacado"     
@ 116, 071 MSGET aObjget[17] Var cL9   SIZE 12, 8 OF oDlg PIXEL Picture "999"
@ 116,  98 MSGET aObjget[18] Var cC9   SIZE 12, 8 OF oDlg PIXEL Picture "999"
@ 128, 008 SAY OemToAnsi(STR0016)     SIZE 70, 07 OF oDlg PIXEL     		 // "Endere�o / Bairro"    
@ 128, 071 MSGET aObjget[19] Var cL10  SIZE 12, 8 OF oDlg PIXEL Picture "999"
@ 128,  98 MSGET aObjget[20] Var cC10  SIZE 12, 8 OF oDlg PIXEL Picture "999"
@ 140, 008 SAY OemToAnsi(STR0017) SIZE 69, 07 OF oDlg PIXEL					// "Data do Processamento"	
@ 139, 071 MSGET aObjget[21] Var cL14  SIZE 12, 8 OF oDlg PIXEL Picture "999"
@ 139,  98 MSGET aObjget[22] Var cC14  SIZE 12, 8 OF oDlg PIXEL Picture "999"
@ 151, 008 SAY OemToAnsi(STR0018)  SIZE 69, 07 OF oDlg PIXEL					// "Munic�pio/Estado/Cep"	
@ 150, 071 MSGET aObjget[23] Var cL11  SIZE 12, 8 OF oDlg PIXEL Picture "999"
@ 150,  98 MSGET aObjget[24] Var cC11  SIZE 12, 8 OF oDlg PIXEL Picture "999"

@ 011, 138 SAY OemToAnsi(STR0019)    SIZE 70, 07 OF oDlg PIXEL 				//"In�cio da Mensagem"	
@ 009, 208 MSGET aObjget[25] Var cL12  SIZE 12, 8 OF oDlg PIXEL Picture "999"
@ 009, 236 MSGET aObjget[26] Var cC12  SIZE 12, 8 OF oDlg PIXEL Picture "999"
@ 022, 138 SAY OemToAnsi(STR0020)  SIZE 70, 07 OF oDlg PIXEL					// "Esp�cie do Numer�rio"		
@ 020, 208 MSGET aObjget[27] Var cL13  SIZE 12, 8 OF oDlg PIXEL Picture "999"
@ 020, 236 MSGET aObjget[28] Var cC13  SIZE 12, 8 OF oDlg PIXEL Picture "999"
@ 033, 138 SAY OemToAnsi(STR0021)              SIZE 70, 07 OF oDlg PIXEL 	//"Carteira"				
@ 032, 208 MSGET aObjget[29] Var cL15  SIZE 12, 8 OF oDlg PIXEL Picture "999"
@ 032, 236 MSGET aObjget[30] Var cC15  SIZE 12, 8 OF oDlg PIXEL Picture "999"
  
@ 060, 138 SAY OemToAnsi(STR0022)  SIZE 78, 7 OF oDlg PIXEL  // "Medidas em 1/6 ou 1/8 (6/8)"
@ 058, 251 MSGET aObjget[31] Var cSex  SIZE 24, 8 OF oDlg PIXEL Picture "9"   Valid cSex $ "68"
@ 071, 138 SAY OemToAnsi(STR0023)   SIZE 78, 07 OF oDlg PIXEL    // "Salto Entre Boletos"
@ 069, 251 MSGET aObjget[32] Var cSal  SIZE 24, 8 OF oDlg PIXEL Picture "999"
@ 082, 138 SAY OemToAnsi(STR0024) SIZE 78, 07 OF oDlg PIXEL   // "Colunas do Formul�rio"
@ 081, 251 MSGET aObjget[33] Var cCol  SIZE 24, 8 OF oDlg PIXEL Picture "9"   Valid cCol $ "12"
@ 094, 138 SAY OemToAnsi(STR0025)   SIZE 78, 7 OF oDlg PIXEL   // "Dist�ncia entre Colunas"
@ 092, 251 MSGET aObjget[34] Var cPas  SIZE 24, 8 OF oDlg PIXEL Picture "999" When cCol == "2"
@ 105, 138 SAY OemToAnsi(STR0026) SIZE 78, 7 OF oDlg PIXEL    // "2a.Coluna � C�pia da 1a.?"
@ 104, 251 MSGET aObjget[35] Var cEqu  SIZE 24, 8 OF oDlg PIXEL Picture "!"   Valid cEqu $ "SN"  When cCol == "2"
    
@ 129, 137 MSGET aObjget[36] Var cMsg1 SIZE 156,8 OF oDlg PIXEL Picture "@S31" valid cfgx018Bug()
@ 141, 137 MSGET aObjget[37] Var cMsg2 SIZE 156,8 OF oDlg PIXEL Picture "@S31" valid cfgx018Bug()
@ 153, 137 MSGET aObjget[38] Var cMsg3 SIZE 156,8 OF oDlg PIXEL Picture "@S31" valid cfgx018Bug()
    
DEFINE SBUTTON FROM 09, 268 TYPE 1 ENABLE OF oDlg Action (nOpc:=1,oDlg:End())
DEFINE SBUTTON FROM 27, 268 TYPE 2 ENABLE OF oDlg Action (nOpc:=0,oDlg:End())
    
ACTIVATE MSDIALOG oDlg Centered          
    
*��������������������������������������������������������������Ŀ
*� Recebe as coordenadas para impress�o do boleto.              �
*����������������������������������������������������������������
    
/*  ��������������������������������������������������������������Ŀ
    � COORDENADAS DO CAMPO A6_BOLETO                               �
    � 001 = Linha do Local de Pagamento                            �
    � 004 = Coluna do Local de Pagamento                           �
    � 007 = Linha do Vencimento                                    �
    � 010 = Coluna do Vencimento                                   �
    � 013 = Linha da Data do Documento                             �
    � 016 = Coluna da Data do Documento                            �
    � 019 = Linha do Numero do Documento                           �
    � 022 = Coluna do Numero do Documento                          �
    � 025 = Linha da Especie do Documento                          �
    � 028 = Coluna da Especie do Documento                         �
    � 031 = Linha do Aceite                                        �
    � 034 = Coluna do Aceite                                       �
    � 037 = Linha do Valor em moeda vigente no pais                �
    � 040 = Coluna do Valor em moeda vigente no pais               �
    � 043 = Linha do Valor em outra moeda                          �
    � 046 = Coluna do Valor em outra moeda                         �
    � 049 = Linha do Sacado                                        �
    � 052 = Coluna do Sacado                                       �
    � 055 = Linha do Endereco / Bairro                             �
    � 058 = Coluna do Endereco / Bairro                            �
    � 061 = Linha do Municipio / Estado / CEP                      �
    � 064 = Coluna do Municipio / Estado / CEP                     �
    � 067 = Linha do Inicio da Mensagem                            �
    � 070 = Coluna do Inicio da Mensagem                           �
    � 073 = Salto entre Boletos                                    �
    � 076 = Colunas do Formulario (1/2)                            �
    � 077 = Distancia entre colunas                                �
    � 080 = Segunda Coluna e copia da primeira?                    �
    � 081 = Linha da Especie de Numerario                          �
    � 084 = Coluna da Especie de Numerario                         �
    � 087 = Medidas em 1/6" ou 1/8" (6/8)                          �
    � 088 = Linha da Data de Processamento                         �
    � 091 = Coluna da Data de Processamento                        �
    � 094 = Linha da Carteira                                      �
    � 097 = Coluna da Carteira                                     �
    ����������������������������������������������������������������*/
    
If cCol == "1"
   cPas := Space( 3 )
	cEqu := " "
Endif   
    
IF nOpc == 1
	cBoleto := cL1+cC1+cL2+cC2+cL3+cC3+cL4+cC4+cL5+cC5+cL6+cC6+cL7+cC7+cL8+cC8+cL9+cC9+cL10+cC10+cL11+cC11+cL12+cC12+cSal+cCol+cPas+cEqu+cL13+cC13+cSex+cL14+cC14+cL15+cC15
   cMensag := cMsg1+cMsg2+cMsg3
   dbGoTop()
   Begin Transaction
	   While !Eof()
	   	IF SA6->A6_COD == Left(cBanco,Len( SA6->A6_COD) )
	      	RecLock("SA6")
	         SA6->A6_BOLETO := cBoleto
	         SA6->A6_MENSAGE:= cMensag
	    	EndIF
	      dbSkip( )
	   EndDO
   End Transaction 
Endif

#IFNDEF ACER
    dbSelectArea( "SA6" )
    dbCloseArea( )
    dbSelectArea( "SA1" )
    dbCloseArea( )
    dbSelectArea( "SE1" )
    dbCloseArea( )
    dbSelectArea ("SM4" )
    dbCloseArea( )
#EndIF

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �RestConfig� Autor � Vinicius Barreira     � Data � 06.02.96 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Verifica as op��es j� configuradas ou cria default          ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e �RestConf()                                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Sem Argumentos                                             ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Configurador   � Fun��o Relacionada � Entrada Dados (Todos)���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static FuncTion RestConf( lRefresh )
Local nLaco := 0

If SA6->( dbSeek(  xFilial("SA6") + Left( cbanco, Len(SA6->A6_COD) ) ) ) .and. !Empty( SA6->A6_BOLETO )
    cL1  := SubStr( SA6->A6_BOLETO, 1,3 )
    cC1  := SubStr( SA6->A6_BOLETO, 4,3 )
    cL2  := SubStr( SA6->A6_BOLETO, 7,3 )
    cC2  := SubStr( SA6->A6_BOLETO,10,3 )
    cL3  := SubStr( SA6->A6_BOLETO,13,3 )
    cC3  := SubStr( SA6->A6_BOLETO,16,3 )
    cL4  := SubStr( SA6->A6_BOLETO,19,3 )
    cC4  := SubStr( SA6->A6_BOLETO,22,3 )
    cL5  := SubStr( SA6->A6_BOLETO,25,3 )
    cC5  := SubStr( SA6->A6_BOLETO,28,3 )
    cL6  := SubStr( SA6->A6_BOLETO,31,3 )
    cC6  := SubStr( SA6->A6_BOLETO,34,3 )
    cL7  := SubStr( SA6->A6_BOLETO,37,3 )
    cC7  := SubStr( SA6->A6_BOLETO,40,3 )
    cL8  := SubStr( SA6->A6_BOLETO,43,3 )
    cC8  := SubStr( SA6->A6_BOLETO,46,3 )
    cL9  := SubStr( SA6->A6_BOLETO,49,3 )
    cC9  := SubStr( SA6->A6_BOLETO,52,3 )
    cL10 := SubStr( SA6->A6_BOLETO,55,3 )
    cC10 := SubStr( SA6->A6_BOLETO,58,3 )
    cL11 := SubStr( SA6->A6_BOLETO,61,3 )
    cC11 := SubStr( SA6->A6_BOLETO,64,3 )
    cL12 := SubStr( SA6->A6_BOLETO,67,3 )
    cC12 := SubStr( SA6->A6_BOLETO,70,3 )
    cL13 := SubStr( SA6->A6_BOLETO,81,3 )
    cC13 := SubStr( SA6->A6_BOLETO,84,3 )
    cSal := SubStr( SA6->A6_BOLETO,73,3 )
    cCol := SubStr( SA6->A6_BOLETO,76,1 )
    cPas := SubStr( SA6->A6_BOLETO,77,3 )
    cEqu := SubStr( SA6->A6_BOLETO,80,1 ) 
    cSex := SubStr( SA6->A6_BOLETO,87,1 )
    cL14 := SubStr( SA6->A6_BOLETO,88,3 )
    cC14 := SubStr( SA6->A6_BOLETO,91,3 )
    cL15 := SubStr( SA6->A6_BOLETO,94,3 )
    cC15 := SubStr( SA6->A6_BOLETO,97,3 )
    
    IF !Empty(SA6->A6_MENSAGE)
        cMsg1 := SubStr(SA6->A6_MENSAGE,001,080)
        cMsg2 := SubStr(SA6->A6_MENSAGE,081,080)
        cMsg3 := SubStr(SA6->A6_MENSAGE,161,080)
    Endif
    
Else
    cL2:=cL3:=cL4:=cL6:="   "
    cL1:=cL5:=cL7:=cL8:=cL9:=cL10:=cL11:=cL12:=cL13:="   "
    cC2:=cC3:=cC4:=cC6:="   "
    cC1:=cC5:=cC7:=cC8:=cC9:=cC10:=cC11:=cC12:=cC13:="   "
    cC14:=cC15:="   "
    cL14:=cL15:="   " 
    cSal:="   "
    cCol:=" "
    cPas:="   "
    cEqu:=" "
    cSex:=" "
    cMsg1 := cMsg2 := cMsg3 := space(80)
EndIF

If lRefresh
   For nlaco := 1 to len( aObjGet )
       aObjGet[nLaco]:Refresh()   
   EndFOr
Endif

Return .T.


/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � CA010Form� Autor � Claudinei M. Benzi    � Data � 10/11/92 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Rotina verificadora da formula digitada                    ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CFGX018                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
FUNCTION cfgx018Bug(void)
LOCAL xResult,cForm:=&(ReadVar())
LOCAL bBlock:=ErrorBlock()
PRIVATE lRet:=.T.

IF Empty(cForm)
    Return .T.
Endif

BEGIN SEQUENCE
xResult := &cForm
END SEQUENCE

ErrorBlock(bBlock)
Return lRet

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � ChekBug  � Autor � Claudinei M. Benzi    � Data � 10/11/92 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Rotina analizadora do erro                                 ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CFGX018                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Chekbug(e)
IF e:gencode > 0
    HELP(" ",1,"ERR_MSG",,e:Description,1,1)
    lRet:=.F.
Endif
Break
