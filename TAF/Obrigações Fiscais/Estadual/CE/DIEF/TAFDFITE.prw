#Include 'Protheus.ch'

#Define Base_ICMS 1
#Define Valor_ICMS 2
#Define Base_ST 3
#Define Valor_ST 4
#Define Base_IPI 5
#Define Vl_IsenIPI 6
#Define Vl_OutIPI 7
#Define Valor_IPI 8
#Define ID_CSTICMS 9
#Define Aliq_ICMS 10
#Define RedBc_ICMS 11
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFDFITE
Gera o registro ITE da DIEF-CE 
Registro tipo ITE - Registros referentes aos itens dos documentos fiscais. 
Um bloco de documento pode possuir nenhum ou v�rios registros, dependendo de
legisla��o ou termo de acordo.

@author David Costa
@since  01/12/2015
@version 1.0
				
/*/
//-------------------------------------------------------------------
Function TAFDFITE( nHandle, cAliasQry, lCupom )

Local aICMSItem	:= {}
Local cNomeReg	:= "ITE"
Local cStrReg		:= ""
Local oLastError	:= ErrorBlock({|e| AddLogDIEF("N�o foi poss�vel montar o registro ITE, erro: " + CRLF + e:Description + Chr( 10 )+ e:ErrorStack)})
Local cTabela		:= ""
Local cFiltroTbl	:= ""
Local cFiltroQry	:= ""
Local lError		:= .F.

Begin Sequence
	
	If( lCupom )
		cTabela := "C6J"
		cFiltroQry := "C6I_ID+C6I_DTMOV+C6I_CMOD+C6I_CODSIT+C6I_NUMDOC+C6I_DTEMIS"
		cFiltroTbl := "C6J_ID+DTOS(C6J_DTMOV)+C6J_CMOD+C6J_CODSIT+C6J_NUMDOC+DTOS(C6J_DTEMIS)"
	Else
		cTabela := "C30"
		cFiltroQry := "C20_CHVNF"
		cFiltroTbl := "C30_CHVNF"
	EndIf

	DbSelectArea(cTabela)
	(cTabela)->( DbSetOrder( 1 ) )
	
	If((cTabela)->(MsSeek(xFilial(cTabela) + (cAliasQry)->&(cFiltroQry) )))
	
		While (cTabela)->(!Eof()) .And. (cAliasQry)->&(cFiltroQry) == (cTabela)->&(cFiltroTbl)
			
			GetICMSIte( @aICMSItem, cTabela, lCupom );
			
			cStrReg	:= cNomeReg
			cStrReg	+= GetNumSeq( lCupom )										//N�mero seq�encial  do item do documento 
			cStrReg	+= GetCodPrd( lCupom )										//C�digo do produto ou servi�o do item.
			cStrReg	+= GetQtd( lCupom )											//Quantidade
			cStrReg	+= GetVlUn( lCupom )											//Valor unit�rio
			cStrReg	+= GetCST( aICMSItem, lCupom, cAliasQry )					//C�digo Situa��o Tribut�ria
			cStrReg	+= TAFDecimal(aICMSItem[Base_ICMS], 13, 2, Nil)			//Valor da base de c�lculo do ICMS normal.
			cStrReg	+= TAFDecimal(aICMSItem[Valor_ICMS], 13, 2, Nil)			//Valor do ICMS Normal.
			cStrReg	+= TAFDecimal(aICMSItem[Base_ST], 13, 2, Nil)				//Valor da base de c�lculo referente a ST
			cStrReg	+= TAFDecimal(aICMSItem[Valor_ST], 13, 2, Nil)			//Valor ICMS ST.
			cStrReg	+= GetCVF( cAliasQry, aICMSItem, lCupom )					//C�digo Valor Fiscal do ICMS
			cStrReg	+= TAFDecimal(aICMSItem[Base_IPI], 13, 2, Nil)			//Valor da base de c�lculo do IPI
			cStrReg	+= TAFDecimal(aICMSItem[Vl_IsenIPI], 13, 2, Nil)			//Valor de isentas referente ao IPI
			cStrReg	+= TAFDecimal(aICMSItem[Vl_OutIPI], 13, 2, Nil)			//Valor de Outras referente ao IPI
			cStrReg	+= TAFDecimal(aICMSItem[Valor_IPI], 13, 2, Nil)			//Valor do IPI
			cStrReg	+= GetCVFI( cAliasQry, aICMSItem, lCupom )				//C�digo do valor fiscal do IP
			cStrReg	+= GetDesc( lCupom )											//Valor de descontos aplicados no item
			cStrReg	+= GetAcre( lCupom )											//Valor de acr�scimos aplicados no item
			cStrReg	+= CRLF
			
			(cTabela)->(DbSkip())
			
			AddLinDIEF( )
			
			WrtStrTxt( nHandle, cStrReg )
		
		EndDo
	EndIf
	
	DbCloseArea(cTabela)

Recover
	lError := .T.

End Sequence

ErrorBlock(oLastError)

Return( lError )

//-------------------------------------------------------------------
/*/{Protheus.doc} GetICMSIte             
Seleciona os dados dos tributos do Item

@author David Costa
@since  01/12/2015
@version 1.0
				
/*/
//-------------------------------------------------------------------
Static Function GetICMSIte( aICMSItem, cTabelaITE, lCupom )

Local cTabelaTRB	:= ""
Local cFiltroITE	:= ""
Local cFiltroTRB	:= ""
Local cFiltroC3S	:= ""
Local cBaseTrib	:= ""
Local cValorTrib	:= ""
Local cCST			:= ""
Local cIsento		:= ""
Local cOutros		:= ""
Local cAliqICMS	:= ""
Local cRedBcICMS	:= ""

aICMSItem		:= {0,0,0,0,0,0,0,0,"",0,0}

If( lCupom )
	cTabelaTRB	:= "C6K"
	cFiltroTRB	:= "C6K_ID + DTOS(C6K_DTMOV) + C6K_CMOD + C6K_CODSIT + C6K_NUMDOC + DTOS(C6K_DTEMIS) + C6K_ITEMNF + C6K_IT"
	cFiltroITE	:= "C6J_ID + DTOS(C6J_DTMOV) + C6J_CMOD + C6J_CODSIT + C6J_NUMDOC + DTOS(C6J_DTEMIS) + C6J_ITEMNF + C6J_IT"
	cFiltroC3S	:= "C6K_CODTRI"
	cBaseTrib 	:= "C6K_VLRBC"
	cValorTrib	:= "C6K_VLRTRB"
	cCST		:= "C6K_CST"
	cIsento	:= "C6K_VLISEN"
	cOutros	:= "C6K_VLOUT"
	cAliqICMS	:= "C6K_ALQPRD"
	cRedBcICMS	:= "C6K_REDBC"
Else
	cTabelaTRB	:= "C35"
	cFiltroTRB	:= "C35_CHVNF+C35_NUMITE"
	cFiltroITE	:= "C30_CHVNF+C30_NUMITE"
	cFiltroC3S	:= "C35_CODTRI"
	cBaseTrib 	:= "C35_BASE"
	cValorTrib	:= "C35_VALOR"
	cCST		:= "C35_CST"
	cIsento	:= "C35_VLISEN"
	cOutros	:= "C35_VLOUTR"
	cAliqICMS	:= "C35_ALIQ"
	cRedBcICMS	:= "C35_REDBC"
EndIf

DbSelectArea(cTabelaTRB)
(cTabelaTRB)->( DbSetOrder( 1 ) )

If((cTabelaTRB)->(MsSeek(xFilial(cTabelaTRB) + (cTabelaITE)->&(cFiltroITE))))
	While (cTabelaTRB)->(!Eof()) .And. (cTabelaITE)->&(cFiltroITE) == (cTabelaTRB)->&(cFiltroTRB)
		
		DbSelectArea('C3S')
		DbSetOrder(3)
		
		If(C3S->(MsSeek(xFilial("C3S")+(cTabelaTRB)->&(cFiltroC3S))))
			Do Case
			//ICMS
			Case C3S->C3S_CODIGO $ ("|02|03|")
				aICMSItem[Base_ICMS] += (cTabelaTRB)->&(cBaseTrib)
				aICMSItem[Valor_ICMS] += (cTabelaTRB)->&(cValorTrib)
				aICMSItem[ID_CSTICMS] += (cTabelaTRB)->&(cCST)
				aICMSItem[Aliq_ICMS] += (cTabelaTRB)->&(cAliqICMS)
				aICMSItem[RedBc_ICMS] += (cTabelaTRB)->&(cRedBcICMS)
			//ICMSST
			Case C3S->C3S_CODIGO $ ("|05|")
				aICMSItem[Base_ST] += (cTabelaTRB)->&(cBaseTrib)
				aICMSItem[Valor_ST] += (cTabelaTRB)->&(cValorTrib)
			//IPI
			Case C3S->C3S_CODIGO $ ("|04|")
				aICMSItem[Base_IPI] += (cTabelaTRB)->&(cBaseTrib)
				aICMSItem[Vl_IsenIPI] += (cTabelaTRB)->&(cIsento)
				aICMSItem[Vl_OutIPI] += (cTabelaTRB)->&(cOutros)
				aICMSItem[Valor_IPI] += (cTabelaTRB)->&(cValorTrib)
			EndCase
		EndIf
		
		DbCloseArea("C3S")
		
		(cTabelaTRB)->(DbSkip())
	EndDo 
EndIf

DbCloseArea(cTabelaTRB)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GetCodPrd             
C�digo do produto ou servi�o do item. Dever� estar relacionado  no registro PRD.

@author David Costa
@since  01/12/2015
@version 1.0
				
/*/
//-------------------------------------------------------------------
Static Function GetCodPrd( lCupom )

Local cCodPrd	:= ""

DbSelectArea("C1L")
DbSetOrder(3)

If( lCupom .And. C1L->(MsSeek(xFilial("C1L")+C6J->C6J_IT)))
	cCodPrd := AllTrim(C1L->C1L_CODIGO)
ElseIf(!lCupom .And. C1L->(MsSeek(xFilial("C1L")+C30->C30_CODITE)))
	cCodPrd := AllTrim(C1L->C1L_CODIGO)
Else
	cCodPrd := Space(1)	
EndIF

DbCloseArea("C1L")

cCodPrd := PadR(cCodPrd,30)

Return( cCodPrd )

//-------------------------------------------------------------------
/*/{Protheus.doc} GetCST             
C�digo Situa��o Tribut�ria  para os documentos  fiscais de sa�das. Combina��o das tabelas 16 e 17, 
exceto no caso do documento  fiscal ser cupom, quando deve ser preenchido,  vide tabela 18.

16- TABELA C�DIGO DE SITUA��O TRIBUT�RIA - A

0	Nacional
1	Estrangeira � importa��o direta
2	Estrangeira � adquirida no mercado interno

17- TABELA C�DIGO DE SITUA��O TRIBUT�RIA - B

00	Tributada integralmente
10	Tributada e com cobran�a de ICMS de Substitui��o Tribut�ria
20	Tributada com redu��o de base de c�lculo
30	Isenta ou n�o tributada e com cobran�a do ICMS de Substitui��o Tribut�ria
40	Isenta
41	N�o tributada
50	Suspens�o
51	Diferimento
60	ICMS cobrado anteriormente por substitui��o tribut�ria
70	Com redu��o de base de c�lculo e cobran�a do ICMS por Substitui��o Tribut�ria
90	Outras

18- TABELA C�DIGO DE SITUA��O TRIBUT�RIA P/ CUPOM FISCAL

T17	Tributada integralmente com 17%
T07	Tributada com redu��o de base de c�lculo de 58,82% eq�ivalendo a uma al�quota efetiva de 7%
T12	Tributada integralmente com al�quota de 12%
T25	Tributada integralmente com al�quota de 25%
TR	Tributa��o com redu��o de base de c�lculo
I	Isenta ou n�o tributada
F	ICMS Substitui��o
N	N�o Incid�ncia
T19	Tributada integralmente com 19%
T27	Tributada integralmente com 27%

@author David Costa
@since  01/12/2015
@version 1.0
				
/*/
//-------------------------------------------------------------------
Static Function GetCST( aICMSItem, lCupom, cAliasQry )

Local cCST	:= ""

If( !lCupom .And. (cAliasQry)->C20_INDOPE == "1" )
	//Primeiro Digito-------------------------
	DbSelectArea("C03")
	DbSetOrder(3)
	
	If(C03->(MsSeek(xFilial("C03")+C30->C30_ORIGEM)))
		Do Case
		Case C03->C03_CODIGO $ ("|0|3|4|5|8|")
			cCST:= "0"
		Case C03->C03_CODIGO $ ("|6|")
			cCST:= "1"
		Case C03->C03_CODIGO $ ("|2|7|")
			cCST:= "2"
		EndCase
	EndIF
	
	DbCloseArea("C03")
	
	//Demais Digitos----------------------------
	DbSelectArea("C14")
	DbSetOrder(3)
	  
	If(C14->(MsSeek(xFilial("C14") + aICMSItem[ID_CSTICMS])))
		Do Case
		Case C14->C14_CODIGO $ ("|00|101|102|")
			cCST += "00"
		Case C14->C14_CODIGO $ ("|10|201|202|")
			cCST += "10"
		Case C14->C14_CODIGO $ ("|30|203|")
			cCST += "30"
		Case C14->C14_CODIGO $ ("|40|103|")
			cCST += "40"
		Case C14->C14_CODIGO $ ("|41|400|")
			cCST += "41"
		Case C14->C14_CODIGO $ ("|60|500|")
			cCST += "60"
		Case C14->C14_CODIGO $ ("|90|900|")
			cCST += "90"
		OtherWise
			cCST += AllTrim(C14->C14_CODIGO)
		EndCase
	EndIF
	
	DbCloseArea("C14")
//Cupom
ElseIf( lCupom )
	DbSelectArea("C14")
	DbSetOrder(3)
	  
	If(C14->(MsSeek(xFilial("C14") + aICMSItem[ID_CSTICMS])))
		Do Case
		Case AllTrim(C14->C14_CODIGO) $ ("|30|40|41")
			cCST += "I"
		Case AllTrim(C14->C14_CODIGO) $ ("|90|")
			cCST += "F"
		Case aICMSItem[Aliq_ICMS] == 17
			cCST += "T17"
		Case aICMSItem[Aliq_ICMS] == 7 .And. aICMSItem[RedBc_ICMS] == 58.82
			cCST += "T07"
		Case aICMSItem[Aliq_ICMS] == 12
			cCST += "T12"
		Case aICMSItem[Aliq_ICMS] == 25
			cCST += "T25"
		Case aICMSItem[Aliq_ICMS] == 19
			cCST += "T19"
		Case aICMSItem[Aliq_ICMS] == 27
			cCST += "T27"
		Case aICMSItem[RedBc_ICMS] > 0
			cCST += "TR"	
		EndCase
	Else
		cCST += "N"
	EndIf
	
	DbCloseArea("C14")
EndIf

cCST := PadR(cCST, 3)

Return( cCST )

//-------------------------------------------------------------------
/*/{Protheus.doc} GetCVF             
C�digo Valor Fiscal do ICMS, vide tabela 15. Apenas nos documentos
fiscais de entrada.

15- TABELA CODIGO VALOR FISCAL

1	Opera��es com cr�dito do imposto
2	Opera��es sem cr�dito do imposto � Isentas ou n�o tributadas
3	Opera��es sem cr�dito do imposto � Outras


@author David Costa
@since  01/12/2015
@version 1.0
				
/*/
//-------------------------------------------------------------------
Static Function GetCVF( cAliasQry, aICMSItem, lCupom )

Local cCVF	:="00"

If( !lCupom .And. (cAliasQry)->C20_INDOPE == "0")
	DbSelectArea("C14")
	DbSetOrder(3)
	  
	If(C14->(MsSeek(xFilial("C14") + aICMSItem[ID_CSTICMS])))
		Do Case
		Case C14->C14_CODIGO $ ("|30|40|41|50|51|103|203|300|400|")
			cCVF := "02"
		Case C14->C14_CODIGO $ ("|60|90|500|900|")
			cCVF := "03"
		OtherWise
			cCVF := "01"
		EndCase
	EndIf
	
	DbCloseArea("C14")
EndIf

Return( cCVF )

//-------------------------------------------------------------------
/*/{Protheus.doc} GetCVFI            
C�digo do valor fiscal do IPI referente �s entradas vide tabela 15. 
Apenas nos Documentos Fiscais de Entrada

15- TABELA CODIGO VALOR FISCAL

1	Opera��es com cr�dito do imposto
2	Opera��es sem cr�dito do imposto � Isentas ou n�o tributadas
3	Opera��es sem cr�dito do imposto � Outras


@author David Costa
@since  01/12/2015
@version 1.0
				
/*/
//-------------------------------------------------------------------
Static Function GetCVFI( cAliasQry, aICMSItem, lCupom )

Local cCVFI	:="00"

If( !lCupom .And. (cAliasQry)->C20_INDOPE == "0")
	DbSelectArea("C14")
	DbSetOrder(3)
	
	If(C14->(MsSeek(xFilial("C14") + aICMSItem[ID_CSTICMS])))
		Do Case
		Case C14->C14_CODIGO $ ("|02|03|04|52|53|54|")
			cCVFI := "02"
		Case C14->C14_CODIGO $ ("|01|05|49|51|55|99|")
			cCVFI := "03"
		OtherWise
			cCVFI := "01"
		EndCase
	EndIF
	
	DbCloseArea("C14")
EndIf

Return( cCVFI )

//-------------------------------------------------------------------
/*/{Protheus.doc} GetNumSeq            
Retorna N�mero seq�encial do item do documento fiscal iniciado por 0001.

@author David Costa
@since  10/12/2015
@version 1.0
				
/*/
//-------------------------------------------------------------------
Static Function GetNumSeq( lCupom )

Local cNSeq	:= ""

If( lCupom)
	cNSeq := StrZero(Val(C6J->C6J_ITEMNF), 4)
Else
	cNSeq := StrZero(Val(C30->C30_NUMITE), 4)
EndIf

Return( cNSeq )

//-------------------------------------------------------------------
/*/{Protheus.doc} GetQTD            
Quantidade  do produto considerando a unidade informada  no registro PRD.

@author David Costa
@since  10/12/2015
@version 1.0
				
/*/
//-------------------------------------------------------------------
Static Function GetQTD( lCupom )

Local cQTD	:= ""

If( lCupom )
	cQTD := TAFDecimal(C6J->C6J_QTDE, 17, 8, Nil)
Else
	cQTD := TAFDecimal(C30->C30_QUANT, 17, 8, Nil)
EndIf

Return( cQTD )

//-------------------------------------------------------------------
/*/{Protheus.doc} GetVlUn            
Valor unit�rio do item, considerando a unidade informada  no registro PRD.

@author David Costa
@since  10/12/2015
@version 1.0
				
/*/
//-------------------------------------------------------------------
Static Function GetVlUn( lCupom )

Local cVlUn	:= ""

If( lCupom )
	cVlUn := TAFDecimal(C6J->C6J_VLRITE, 15, 6, Nil)
Else
	cVlUn := TAFDecimal(C30->C30_VLRITE, 15, 6, Nil)
EndIf

Return( cVlUn )

//-------------------------------------------------------------------
/*/{Protheus.doc} GetDesc            
Valor de descontos  aplicados  no item

@author David Costa
@since  10/12/2015
@version 1.0
				
/*/
//-------------------------------------------------------------------
Static Function GetDesc( lCupom )

Local cVlDesc	:= ""

If( lCupom )
	cVlDesc := TAFDecimal(C6J->C6J_VLDESC, 15, 6, Nil)
Else
	cVlDesc := TAFDecimal(C30->C30_VLDESC, 15, 6, Nil)
EndIf

Return( cVlDesc )

//-------------------------------------------------------------------
/*/{Protheus.doc} GetAcre            
Valor de acr�scimos  aplicados  no item

@author David Costa
@since  10/12/2015
@version 1.0
				
/*/
//-------------------------------------------------------------------
Static Function GetAcre( lCupom )

Local cVlAcre	:= ""

If( lCupom )
	cVlAcre := TAFDecimal(C6J->C6J_VLRACR, 15, 6, Nil)
Else
	cVlAcre := TAFDecimal(C30->C30_VLACRE, 15, 6, Nil)
EndIf

Return( cVlAcre )