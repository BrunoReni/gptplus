#INCLUDE "FINR085L.CH"
#INCLUDE "PROTHEUS.Ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � Finr085L � Autor � Jos� Lucas             � Data � 08.09.10���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Informe de Declaraci�n de Retenci�n de Impuesto de Rentas. ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nenhum                                                     ���
�������������������������������������������������������������������������ĳ��
���Parametros� Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador �Data    � BOPS     � Motivo da Alteracao                  ���
�������������������������������������������������������������������������Ĵ��
���Alf. Medrano�06/12/16�SERINN001-126�se quita la creacion de tablas tem ���
���            �        �          �-porales y se asigna FWTemporaryTable ���
���            �        �          �en fun ReportPrint                    ���
���Alf. Medrano�26/01/17�SERINN001-126�Merge Main vs 12.1.15              ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function FINR085L()

Private dFinalA
Private dFinal
Private nomeprog	:= "FINR085L"
Private dPeriodo0

If TRepInUse()
	FINR085LR4()
Else
	//Return FINR085LR3()
EndIf

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � FINR085LR4 � Autor � Jos� Lucas	 		� Data � 08.09.10 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Informe de Declaraci�n de Retenci�n de Impuesto de Rentas.  ��
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � FINR085LR4												  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � SIGAFIN                                    				  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function FINR085LR4()

PRIVATE cPerg := "FIN85L"

//������������������������������������������������������������������������Ŀ
//�Interface de impressao                                                  �
//��������������������������������������������������������������������������
Pergunte( cPerg, .F. )

oReport := ReportDef()

If VALTYPE( oReport ) == "O"
	oReport :PrintDialog()
EndIf

oReport := nil

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportDef  � Autor � Jos� Lucas	 		� Data � 08.09.10 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Esta funcao tem como objetivo definir as secoes, celulas,   ���
���          �totalizadores do relatorio que poderao ser configurados     ���
���          �pelo relatorio.                                             ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � SIGACTB                                    				  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportDef()

Local aArea	   	:= GetArea()
Local CREPORT	:= "FINR085L"
Local CTITULO	:= OemToAnsi(STR0001)				// DECLARA��O DE RETEN��ES
Local CDESC		:= OemToAnsi(STR0002) + ; 			//"Este programa ir� imprimir a Declara��o de Reten��es "
	   			   OemToAnsi(STR0003) 				//"de acordo com os par�metros informados pelo usu�rio."

Local aTamNuCert := TamSX3("FE_NROCERT")
Local aTamEmissa := TamSX3("FE_EMISSAO")
Local aTamNFisca := TamSX3("FE_NFISCAL")
Local aTamOdPago := TamSX3("FE_ORDPAGO")
Local aTamFornec := TamSX3("FE_FORNECE")
Local aTamConcep := TamSX3("FE_CONCEPT")
Local aTamValBru := TamSX3("F1_VALBRUT")
Local aTamValBas := TamSX3("FE_VALBASE")
Local aTamValImp := TamSX3("FE_VALIMP")
Local aTamPorcRe := TamSX3("FE_ALIQ")
Local aTamRetenc := TamSX3("FE_RETENC")

cTitulo	:= OemToAnsi(STR0005)						// Declara��o de Reten��es

//������������������������������������������������������������������������Ŀ
//�Criacao do componente de impressao                                      �
//�                                                                        �
//�TReport():New                                                           �
//�ExpC1 : Nome do relatorio                                               �
//�ExpC2 : Titulo                                                          �
//�ExpC3 : Pergunte                                                        �
//�ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  �
//�ExpC5 : Descricao                                                       �
//��������������������������������������������������������������������������
oReport	:= TReport():New( cReport,cTitulo,cPerg, { |oReport| Pergunte(cPerg , .F. ), If(! ReportPrint( oReport )  , oReport:CancelPrint(), .T. ) }, cDesc )

oReport:SetCustomText( {|| CtCGCCabTR(,,,,,dDataBase,ctitulo,,,,,oReport) } )

//������������������������������������������������������������������������Ŀ
//�Criacao da secao utilizada pelo relatorio                               �
//�                                                                        �
//�TRSection():New                                                         �
//�ExpO1 : Objeto TReport que a secao pertence                             �
//�ExpC2 : Descricao da se�ao                                              �
//�ExpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela   �
//�        sera considerada como principal para a se��o.                   �
//�ExpA4 : Array com as Ordens do relat�rio                                �
//�ExpL5 : Carrega campos do SX3 como celulas                              �
//�        Default : False                                                 �
//�ExpL6 : Carrega ordens do Sindex                                        �
//�        Default : False                                                 �
//�                                                                        �
//��������������������������������������������������������������������������
oSection1 := TRSection():New( oReport, STR0005, {"TRB"},, .F., .F. )
TRCell():New( oSection1, "EMISSAO"	,"",STR0008				/*Titulo*/,"@D 99/99/9999"/*Picture*/,20		/*aTamEmissa[1]+2Tamanho*/,/*lPixel*/,/*CodeBlock*/)
TRCell():New( oSection1, "NUMCERT"	,"",STR0009				/*Titulo*/,"@!"/*Picture*/,aTamNuCert[1]+10		/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
TRCell():New( oSection1, "FACTURA"	,"",STR0010				/*Titulo*/,/*Picture*/,aTamNFisca[1]+10		/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
TRCell():New( oSection1, "ORDPAGO"	,"",STR0011				/*Titulo*/,/*Picture*/,aTamOdPago[1]+10		/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
TRCell():New( oSection1, "FORNECE"	,"",STR0012				/*Titulo*/,/*Picture*/,aTamFornec[1]+40		/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
TRCell():New( oSection1, "CONCEPT"	,"",STR0013				/*Titulo*/,/*Picture*/,aTamConcep[1]+40		/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
TRCell():New( oSection1, "VALBRUT"	,"",STR0014				/*Titulo*/,"@E 999,999,999.99"				/*Picture*/,aTamValBru[1]+aTamValBru[2]		/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"RIGHT",,"RIGHT")
TRCell():New( oSection1, "VALBASE"	,"",STR0015				/*Titulo*/,"@E 999,999,999.99"				/*Picture*/,aTamValBas[1]+aTamValBas[2]		/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"RIGHT",,"RIGHT")
TRCell():New( oSection1, "VALIMP"	,"",STR0016				/*Titulo*/,"@E 999,999,999.99"				/*Picture*/,aTamValImp[1]+aTamValImp[2]		/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"RIGHT",,"RIGHT")
TRCell():New( oSection1, "PORCRET"	,"",STR0017				/*Titulo*/,"@E 999.99"						/*Picture*/,aTamPorcRe[1]+aTamPorcRe[2]		/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"RIGHT",,"RIGHT")
TRCell():New( oSection1, "RETENC"	,"",STR0018				/*Titulo*/,"@E 999,999,999.99"				/*Picture*/,aTamRetenc[1]+aTamRetenc[2]		/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"RIGHT",,"RIGHT")

oSection1:SetHeaderPage()
oSection1:SetTotalInLine(.F.)

Return(oReport)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportPrint � Autor � Jos� Lucas	 		� Data � 08.09.10 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Imprime o relatorio definido pelo usuario de acordo com as  ���
���          �secoes/celulas criadas na funcao ReportDef definida acima.  ���
���          �Nesta funcao deve ser criada a query das secoes se SQL ou   ���
���          �definido o relacionamento e filtros das tabelas em CodeBase.���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ReportPrint(oReport)                                       ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �EXPO1: Objeto do relat�rio                                  ���
��������������������������������������������������������������������������ٱ�

�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ReportPrint( oReport )

Local oSection1 	:= oReport:Section(1)
Local oSection2     := oReport:Section(2)
Local lin 			:= 3001
Local cArqTmp
Local cPicture
Local lFirstPage	:= .T.
Local nTraco		:= 0
Local nSaldo        := 0
Local nTamLin		:= 2350
Local aPosCol		:= { 1740, 2045 }
Local nPosCol		:= 0
Local lTotGeral     := .F.
Local cAliasCTR     := "SFE"
Local aCampos       := {}
Local aTamEmissa := TamSX3("FE_EMISSAO")
Local aTamNuCert := TamSX3("FE_NROCERT")
Local aTamNFisca := TamSX3("FE_NFISCAL")
Local aTamOdPago := TamSX3("FE_ORDPAGO")
Local aTamFornec := TamSX3("FE_FORNECE")
Local aTamConcep := TamSX3("FE_CONCEPT")
Local aTamValBru := TamSX3("F1_VALBRUT")
Local aTamValBas := TamSX3("FE_VALBASE")
Local aTamValImp := TamSX3("FE_VALIMP")
Local aTamPorcRe := TamSX3("FE_ALIQ")
Local aTamRetenc := TamSX3("FE_RETENC")
Local dDataIni   := mv_par01
Local dDataFinal := mv_par02
Local nTotalBruto:= 0.00
Local nTotalBase := 0.00
Local nTotalImp  := 0.00
Local nTotalRet  := 0.00
Local nTotalRec  := 0
Local cRec       := "0"
Private oTmpTable

AADD(aCampos,{"EMISSAO","D",aTamEmissa[1],0})
AADD(aCampos,{"NUMCERT","C",aTamNuCert[1],0})
AADD(aCampos,{"NFISCAL","C",aTamNFisca[1],0})
AADD(aCampos,{"ORDPAGO","C",aTamOdPago[1],0})
AADD(aCampos,{"FORNECE","C",aTamFornec[1]+40,0})
AADD(aCampos,{"CONCEPT","C",aTamConcep[1]+40,0})
AADD(aCampos,{"VALBRUT","N",aTamValBru[1],aTamValBru[2]})
AADD(aCampos,{"VALBASE","N",aTamValBas[1],aTamValBas[2]})
AADD(aCampos,{"VALIMP" ,"N",aTamValImp[1],aTamValImp[2]})
AADD(aCampos,{"PORCRET","N",aTamPorcRe[1],aTamPorcRe[2]})
AADD(aCampos,{"RETENC" ,"N",aTamRetenc[1],aTamRetenc[2]})

If ! Empty(cPicture) .And. Len(Trans(0, cPicture)) > 17
	cPicture := ""
Endif

dbSelectArea("SEF")
dbSelectArea("CCR")

If Select("TRB") > 0
	TRB->(dbCloseArea())
EndIf

//����������������������������������Ŀ
//| Gera arquivo temporario          |
//������������������������������������
oTmpTable := FWTemporaryTable():New("TRB")
oTmpTable:SetFields( aCampos ) 
//crea indice
oTmpTable:AddIndex('T1ORD', {"EMISSAO","NUMCERT"})
//Creacion de la tabla
oTmpTable:Create()
//��������������������������������������������������������������Ŀ
//� Monta Arquivo Temporario para Impressao					     �
//
����������������������������������������������������������������
MsgMeter({|	oMeter, oText, oDlg, lEnd | FINR085LGer(oMeter,oText,oDlg,@lEnd,cArqTmp,dDataIni,dDataFinal)},STR0006, STR0001) //"Criando Arquivo Temporario..."

dbSelectArea("TRB")
dbSetOrder(1)
dbGoTop()

oReport:SetMeter( RecCount() )

oReport:SetPageNumber(1)

While !Eof() .And. !oReport:Cancel() //.And. Eval(bCond)

	If oReport:Cancel()
		Exit
	EndIf

	oReport:IncMeter()

	oSection1:Cell("EMISSAO"):SetBlock( { || TRB->EMISSAO } )
	oSection1:Cell("NUMCERT"):SetBlock( { || TRB->NUMCERT } )
	oSection1:Cell("FACTURA"):SetBlock( { || TRB->NFISCAL } )
	oSection1:Cell("ORDPAGO"):SetBlock( { || TRB->ORDPAGO } )
	oSection1:Cell("FORNECE"):SetBlock( { || TRB->FORNECE } )
	oSection1:Cell("CONCEPT"):SetBlock( { || TRB->CONCEPT } )
	oSection1:Cell("VALBRUT"):SetBlock( { || TRB->VALBRUT } )
	oSection1:Cell("VALBASE"):SetBlock( { || TRB->VALBASE } )
	oSection1:Cell("VALIMP" ):SetBlock( { || If(Empty(TRB->VALIMP),TRB->RETENC,TRB->VALIMP) } )
	oSection1:Cell("PORCRET"):SetBlock( { || If(Empty(TRB->PORCRET),100.00,TRB->PORCRET) } )
	oSection1:Cell("RETENC" ):SetBlock( { || TRB->RETENC  } )

	cRec := Soma1(cRec)

	oSection1:Init()
 	oSection1:Print()
 	oSection1:Finish()

End

DbSelectArea("TRB")
Set Filter To
dbCloseArea()

If oTmpTable <> Nil  
	oTmpTable:Delete() 
	oTmpTable := Nil 
Endif

Return(.T.)


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �FINR085LGer � Autor � Jos� Lucas	 		� Data � 26.04.10 ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Processar Query e gerar arquivo de trabalho.                ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � FINR085LGer(oMeter,oText,oDlg,lEnd,cArqTmp,dDataIni,dDataFinal)���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpO1 = Objeto oPrint                                      ���
���          � ExpC1 = Descricao da moeda sendo impressa                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGACTB                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function FINR085LGer(oMeter,oText,oDlg,lEnd,cArqTmp,dDataIni,dDataFinal)
Local aArea         := GetArea()
Local cQuery        := ""
Local aTamVlr1		:= TamSX3("F1_VALBRUT")
Local aTamVlr2 		:= TamSX3("FE_VALBASE")
Local aTamVlr3   	:= TamSX3("FE_VALIMP")
Local aTamVlr4 		:= TamSX3("FE_ALIQ")
Local aTamVlr5 		:= TamSX3("FE_RETENC")

//Variaveis para atualizar a regua desde as rotinas de geracao do arquivo temporario
Private oMeter1 	:= oMeter
Private oText1 		:= oText

If Select( "QRYSFE" ) > 0
	dbSelectArea( "QRYSFE" )
	QRYSFE->( dbCloseArea() )
Endif

cQuery := "SELECT DISTINCT "
cQuery += "FE_EMISSAO, "
cQuery += "FE_NROCERT, "
cQuery += "FE_NFISCAL, "
cQuery += "FE_SERIE, "
cQuery += "FE_ORDPAGO, "
cQuery += "FE_FORNECE, "
cQuery += "FE_LOJA, "
cQuery += "FE_CONCEPT, "
cQuery += "FE_VALBASE, "
cQuery += "FE_VALIMP, "
cQuery += "FE_ALIQ, "
cQuery += "FE_RETENC "
cQuery += " FROM "
cQuery += RetSqlName("SFE") + " SFE"
cQuery += " WHERE FE_FILIAL = '"+xFilial("SFE")+"' "
cQuery += "  AND FE_EMISSAO BETWEEN '" + DTOS(dDataIni) + "' AND '" + DTOS(dDataFinal) + "' "
cQuery += "  AND FE_TIPO = 'R' "
cQuery += "	 AND D_E_L_E_T_ <> '*' "
cQuery += "ORDER BY FE_EMISSAO"

cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QRYSFE",.T.,.F.)

TcSetField( "QRYSFE", "FE_EMISSAO", "D", 08, 0 )
TcSetField( "QRYSFE", "FE_VALBRUT", "N", aTamVlr1[1], aTamVlr1[2] )
TcSetField( "QRYSFE", "FE_VALBASE", "N", aTamVlr2[1], aTamVlr2[2] )
TcSetField( "QRYSFE", "FE_VALIMP" , "N", aTamVlr3[1], aTamVlr3[2] )
TcSetField( "QRYSFE", "FE_ALIQ", "N", aTamVlr4[1], aTamVlr4[2] )
TcSetField( "QRYSFE", "FE_RETENC" , "N", aTamVlr5[1], aTamVlr5[2] )

dbSelectArea("QRYSFE")
dbGoTop()

While ! QRYSFE->(Eof())

	SA2->(dbSetOrder(1))
	SA2->(dbSeek(xFilial("SA2")+QRYSFE->FE_FORNECE+QRYSFE->FE_LOJA))

	SF1->(dbSetOrder(1))
	SF1->(dbSeek(xFilial("SF1")+QRYSFE->FE_NFISCAL+QRYSFE->FE_SERIE+QRYSFE->FE_FORNECE+QRYSFE->FE_LOJA))

	CCR->(dbSetOrder(1))
	CCR->(dbSeek(xFilial("CCR")+QRYSFE->FE_CONCEPT))

	dbSelectArea("TRB")
	RecLock("TRB",.T.)
	EMISSAO := QRYSFE->FE_EMISSAO
	NUMCERT := QRYSFE->FE_NROCERT
	NFISCAL := QRYSFE->FE_NFISCAL
	ORDPAGO := QRYSFE->FE_ORDPAGO
	FORNECE := QRYSFE->FE_FORNECE+"-"+QRYSFE->FE_LOJA+" "+SA2->A2_NOME
	LOJA    := QRYSFE->FE_LOJA
	CONCEPT := AllTrim(QRYSFE->FE_CONCEPT)+"-"+CCR->CCR_DESCR
	VALBRUT := SF1->F1_VALBRUT
	VALBASE	:= QRYSFE->FE_VALBASE
	VALIMP  := QRYSFE->FE_VALIMP
	PORCRET := QRYSFE->FE_ALIQ
	RETENC  := QRYSFE->FE_RETENC
	MsUnLock()
	QRYSFE->(dbSkip())
End
RestArea(aArea)
Return
