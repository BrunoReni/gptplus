#INCLUDE "FINR221.CH"
#INCLUDE "PROTHEUS.Ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ�
���Fun��o	 � Finr221	� Autor � Jos� Lucas	 		� Data � 26.09.10 ���
��������������������������������������������������������������������������Ĵ�
���Descri��o � Pagamentos   recusados pela Administradora de CC.		   ��
��������������������������������������������������������������������������Ĵ�
���Retorno	 � Nenhum       											   ��
��������������������������������������������������������������������������Ĵ�
���Parametros� Nenhum													   ��
��������������������������������������������������������������������������Ĵ��
��� ACTUALIZACIONES SUFRIDAS DESDE EL DESARROLLO.                          ���
��������������������������������������������������������������������������Ĵ��
��� PROGRAMADOR  � FECHA  � BOPS     �  MOTIVO DE LA ALTERACION            ���
��������������������������������������������������������������������������Ĵ��
���Alf. Medrano  �09/12/16�SERINN001-135�se quita la creacion de tablas tem���
���              �        �          �-porales y se asigna FWTemporaryTable���
���              �        �          �en fun ReportPrint                   ���
���Alf. Medrano  �12/01/17�          �Merge Main vs 12.1.15                ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/

Function FINR221()

Private dFinalA
Private dFinal
Private nomeprog	:= "FINR221"
Private dPeriodo0
Private oTmpTable

If TRepInUse()
	FINR221R4()
Else
	//Return FINR221R3()
EndIf

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � FINR221R4 � Autor � Jos� Lucas	 		� Data � 08.09.10 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Informe de Declaraci�n de Retenci�n de Impuesto de Rentas.  ��
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � FINR221R4												  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � SIGAFIN                                    				  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function FINR221R4()

PRIVATE cPerg := "FIN221"

//������������������������������������������������������������������������Ŀ
//�Interface de impressao                                                  �
//��������������������������������������������������������������������������
Pergunte( cPerg, .F. )
dbSelectArea("FRC")
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
Local CREPORT	:= "FINR221"
Local CTITULO	:= OemToAnsi(STR0001)				// TITULOS A RECEBER RECUSADOS
Local CDESC		:= OemToAnsi(STR0002) + ; 			//"Este programa  ir� imprimir o relat�rio de Titulos"
	   			   OemToAnsi(STR0003) + ;			//"a Receber que tiveram os pagamentos recusados pela"
	   			   OemToAnsi(STR0004) 				//"Administradora de Cart�es de Cr�dito."

Local aTamPrefix := TamSX3("FRC_PREFIX")
Local aTamTitulo := TamSX3("FRC_NUM")
Local aTamParcel := TamSX3("FRC_PARCEL")
Local aTamTipo	 := TamSX3("FRC_TIPO")
Local aTamClient := TamSX3("FRC_FORNEC")
Local aTamLoja   := TamSX3("FRC_LOJA")
Local aTamStatus := TamSX3("FRC_STATUS")
Local aTamMotivo := TamSX3("FRC_MOTIVO")
Local aTamCartao := TamSX3("FRC_NUMCAR")
Local aTamValid  := TamSX3("FRC_DATVAL")
Local aTamAdmin  := TamSX3("AE_DESC")
Local aTamValor  := TamSX3("FRC_VALOR")
Local aTamValRec := TamSX3("FRC_VALREC")

cTitulo	:= OemToAnsi(STR0001)	//Titulos a Receber Recusados

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
oSection1 := TRSection():New( oReport, STR0001, {"TRB"},, .F., .F. )
TRCell():New( oSection1, "PREFIXO"	,"",STR0005				/*Titulo*/,/*Picture*/,aTamPrefix[1]		/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
TRCell():New( oSection1, "TITULO"	,"",STR0006				/*Titulo*/,/*Picture*/,aTamTitulo[1]		/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
TRCell():New( oSection1, "PARCELA"	,"",STR0007				/*Titulo*/,/*Picture*/,aTamParcel[1]		/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
TRCell():New( oSection1, "FORNECE"	,"",STR0008				/*Titulo*/,/*Picture*/,aTamClient[1]		/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
TRCell():New( oSection1, "LOJA"		,"",STR0009				/*Titulo*/,/*Picture*/,aTamLoja[1]			/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
TRCell():New( oSection1, "STATUS"	,"",STR0010				/*Titulo*/,/*Picture*/,aTamStatus[1]		/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
TRCell():New( oSection1, "MOTIVO"	,"",STR0011				/*Titulo*/,/*Picture*/,aTamMotivo[1]		/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
TRCell():New( oSection1, "CARTAO"	,"",STR0012				/*Titulo*/,/*Picture*/,aTamCartao[1]		/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
TRCell():New( oSection1, "VALIDADE"	,"",STR0013				/*Titulo*/,/*Picture*/,aTamValid[1]			/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
TRCell():New( oSection1, "ADMINIST"	,"",STR0014				/*Titulo*/,/*Picture*/,aTamAdmin[1]			/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
TRCell():New( oSection1, "VALOR"	,"",STR0015				/*Titulo*/,/*Picture*/,aTamValor[1]+aTamValor[2]		/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"RIGHT",,"RIGHT")
TRCell():New( oSection1, "VALREC"	,"",STR0016				/*Titulo*/,/*Picture*/,aTamValRec[1]+aTamValRec[2]		/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"RIGHT",,"RIGHT")
oSection1:SetHeaderPage()
oSection1:SetTotalInLine(.F.)

oSection2 := TRSection():New( oReport, STR0001, {"TRB"},, .F., .F. )
TRCell():New( oSection2, "PREFIXO"	,"",STR0005				/*Titulo*/,/*Picture*/,aTamPrefix[1]		/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
TRCell():New( oSection2, "TITULO"	,"",STR0006				/*Titulo*/,/*Picture*/,aTamTitulo[1]		/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
TRCell():New( oSection2, "PARCELA"	,"",STR0007				/*Titulo*/,/*Picture*/,aTamParcel[1]		/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
TRCell():New( oSection2, "FORNECE"	,"",STR0008				/*Titulo*/,/*Picture*/,aTamClient[1]		/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
TRCell():New( oSection2, "LOJA"		,"",STR0009				/*Titulo*/,/*Picture*/,aTamLoja[1]			/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
TRCell():New( oSection2, "STATUS"	,"",STR0010				/*Titulo*/,/*Picture*/,aTamStatus[1]		/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
TRCell():New( oSection2, "MOTIVO"	,"",STR0011				/*Titulo*/,/*Picture*/,aTamMotivo[1]		/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
TRCell():New( oSection2, "CARTAO"	,"",STR0012				/*Titulo*/,/*Picture*/,aTamCartao[1]		/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
TRCell():New( oSection2, "VALIDADE"	,"",STR0013				/*Titulo*/,/*Picture*/,aTamValid[1]			/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
TRCell():New( oSection2, "ADMINIST"	,"",STR0014				/*Titulo*/,/*Picture*/,aTamAdmin[1]			/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
TRCell():New( oSection2, "VALOR"	,"",STR0015				/*Titulo*/,/*Picture*/,aTamValor[1]+aTamValor[2]		/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"RIGHT",,"RIGHT")
TRCell():New( oSection2, "VALREC"	,"",STR0016				/*Titulo*/,/*Picture*/,aTamValRec[1]+aTamValRec[2]		/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"RIGHT",,"RIGHT")
//oSection2:SetHeaderPage()
oSection2:SetTotalInLine(.F.)

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

Local oSection1  := oReport:Section(1)
Local oSection2  := oReport:Section(2)
Local lin 		 := 3001
Local cArqTmp    := ""
Local cPicture   := ""
Local lFirstPage := .T.
Local nTraco	 := 0
Local nSaldo     := 0
Local nTamLin	 := 2350
Local aPosCol	 := { 1740, 2045 }
Local nPosCol	 := 0
Local lTotGeral  := .F.
Local cAliasFRC  := "FRC"
Local aCampos    := {}
Local aTamPrefix := TamSX3("FRC_PREFIX")
Local aTamTitulo := TamSX3("FRC_NUM")
Local aTamParcel := TamSX3("FRC_PARCEL")
Local aTamTipo	 := TamSX3("FRC_TIPO")
Local aTamClient := TamSX3("FRC_FORNEC")
Local aTamLoja   := TamSX3("FRC_LOJA")
Local aTamStatus := TamSX3("FRC_STATUS")
Local aTamMotivo := TamSX3("FRC_MOTIVO")
Local aTamCartao := TamSX3("FRC_NUMCAR")
Local aTamValid  := TamSX3("FRC_DATVAL")
Local aTamAdmin  := TamSX3("AE_DESC")
Local aTamValor  := TamSX3("FRC_VALOR")
Local aTamValRec := TamSX3("FRC_VALREC")

Local dDataIni   := mv_par01
Local dDataFinal := mv_par02
Local cClientIni := mv_par03
Local cClientFim := mv_par04
Local cAdminIni  := mv_par05
Local cAdminFim  := mv_par06

Local nTotValor  := 0.00
Local nTotValRec := 0.00
Local aPicture   := Array(4)

aPicture[1] := PesqPict("FRC","FRC_NUMCAR", 19)
aPicture[2] := PesqPict("FRC","FRC_DATVAL", 05)
aPicture[3] := PesqPict("FRC","FRC_VALOR" , 17)
aPicture[4] := PesqPict("FRC","FRC_VALREC", 17)

AADD(aCampos,{"PREFIXO" ,"C",aTamPrefix[1],0})
AADD(aCampos,{"TITULO"  ,"C",aTamTitulo[1],0})
AADD(aCampos,{"PARCELA" ,"C",aTamParcel[1],0})
AADD(aCampos,{"TIPO"    ,"C",aTamTipo[1],0})
AADD(aCampos,{"FORNECE" ,"C",aTamClient[1],0})
AADD(aCampos,{"LOJA"    ,"C",aTamLoja[1],0})
AADD(aCampos,{"STATUS"  ,"C",aTamStatus[1],0})
AADD(aCampos,{"MOTIVO"  ,"C",aTamMotivo[1],0})
AADD(aCampos,{"CARTAO"  ,"C",aTamCartao[1],0})
AADD(aCampos,{"VALIDADE","C",aTamValid[1],0})
AADD(aCampos,{"ADMINIST","C",aTamAdmin[1],0})
AADD(aCampos,{"VALOR"   ,"N",aTamValor[1],aTamValor[2]})
AADD(aCampos,{"VALREC"  ,"N",aTamValRec[1],aTamValRec[2]})

If ! Empty(cPicture) .And. Len(Trans(0, cPicture)) > 17
	cPicture := ""
Endif

dbSelectArea("FRC")
dbSelectArea("FR0")

If Select("TRB") > 0
	TRB->(dbCloseArea())
EndIf

//����������������������������������Ŀ
//| Gera arquivo temporario          |
//������������������������������������
oTmpTable := FWTemporaryTable():New("TRB")
oTmpTable:SetFields( aCampos ) 
//crea indice
oTmpTable:AddIndex('T1ORD', {"PREFIXO","TITULO","PARCELA","TIPO","FORNECE","LOJA"})
//Creacion de la tabla
oTmpTable:Create()

//��������������������������������������������������������������Ŀ
//� Monta Arquivo Temporario para Impressao					     �
//
����������������������������������������������������������������
MsgMeter({|	oMeter, oText, oDlg, lEnd | FINR221Ger(oMeter,oText,oDlg,@lEnd,cArqTmp,dDataIni,dDataFinal,cClientIni,cClientFim,cAdminIni,cAdminFim)},STR0018, STR0001) //"Criando Arquivo Temporario..."

dbSelectArea("TRB")

TRB->(dbGoTop())

oReport:SetMeter( RecCount() )

oReport:SetPageNumber(1)

While !Eof() .And. !oReport:Cancel() //.And. Eval(bCond)

	If oReport:Cancel()
		Exit
	EndIf

	oReport:IncMeter()

	oSection1:Cell("PREFIXO" ):SetBlock( { || If(TRB->PREFIXO=="ZZZ","TOTAL:",If(TRB->PREFIXO=="ZZX","",TRB->PREFIXO)) } )
 	oSection1:Cell("TITULO"  ):SetBlock( { || TRB->TITULO   } )
	oSection1:Cell("PARCELA" ):SetBlock( { || TRB->PARCELA  } )
	oSection1:Cell("FORNECE" ):SetBlock( { || TRB->FORNECE  } )
	oSection1:Cell("LOJA"	 ):SetBlock( { || TRB->LOJA	    } )
	oSection1:Cell("STATUS"	 ):SetBlock( { || TRB->STATUS   } )
	oSection1:Cell("MOTIVO"	 ):SetBlock( { || TRB->MOTIVO   } )
	oSection1:Cell("CARTAO"	 ):SetBlock( { || Transform(TRB->CARTAO,aPicture[1])} )
	oSection1:Cell("VALIDADE"):SetBlock( { || If(Empty(TRB->VALIDADE),"",Transform(TRB->VALIDADE,aPicture[2])) } )
	oSection1:Cell("ADMINIST"):SetBlock( { || TRB->ADMINIST } )
	oSection1:Cell("VALOR"	 ):SetBlock( { || If(TRB->PREFIXO=="ZZX","",Transform(TRB->VALOR,aPicture[3])) } )
	oSection1:Cell("VALREC"	 ):SetBlock( { || If(TRB->PREFIXO=="ZZX","",Transform(TRB->VALREC,aPicture[4]))  } )

	oSection1:Init()
 	oSection1:Print()
 	oSection1:Finish()

	TRB->(dbSkip())
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
���Funcao    �FINR221Ger � Autor � Jos� Lucas	 		� Data � 26.04.10 ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Processar Query e gerar arquivo de trabalho.                ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � FINR221Ger(oMeter,oText,oDlg,lEnd,cArqTmp,dDataIni,dDataFinal)���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpO1 = Objeto oPrint                                      ���
���          � ExpC1 = Descricao da moeda sendo impressa                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGACTB                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function FINR221Ger(oMeter,oText,oDlg,lEnd,cArqTmp,dDataIni,dDataFinal,cClientIni,cClientFim,cAdminIni,cAdminFim)
Local aArea      := GetArea()
Local cQuery     := ""
Local cFiltro    := ""
Local aTamValor  := TamSX3("FRC_VALOR")
Local aTamValRec := TamSX3("FRC_VALREC")
Local nTotValor  := 0.00
Local nTotValRec := 0.00

cFiltro := ""

//Variaveis para atualizar a regua desde as rotinas de geracao do arquivo temporario
Private oMeter1 	:= oMeter
Private oText1 		:= oText

#IFDEF TOP

	If Select( "QRYFRC" ) > 0
		dbSelectArea( "QRYFRC" )
		QRYFRC->( dbCloseArea() )
	Endif

	cQuery := "SELECT DISTINCT "
	cQuery += "FRC_PREFIX, "
	cQuery += "FRC_NUM, "
	cQuery += "FRC_PARCEL, "
	cQuery += "FRC_TIPO, "
	cQuery += "FRC_FORNEC, "
	cQuery += "FRC_LOJA, "
	cQuery += "FRC_STATUS, "
	cQuery += "FRC_MOTIVO, "
	cQuery += "FRC_NUMCAR, "
	cQuery += "FRC_DATVAL, "
	cQuery += "AE_DESC, "
	cQuery += "FRC_VALOR, "
	cQuery += "FRC_VALREC "
	cQuery += " FROM "
	cQuery += RetSqlName("FRC") + " FRC, "
	cQuery += RetSqlName("SAE") + " SAE "
	cQuery += " WHERE FRC.FRC_FILIAL = '"+xFilial("FRC")+"' "
	cQuery += "  AND FRC.FRC_DATTEF BETWEEN '" + DTOS(dDataIni) + "' AND '" + DTOS(dDataFinal) + "' "
	cQuery += "  AND FRC.FRC_FORNEC BETWEEN '" + cClientIni + "' AND '" + cClientFim + "' "
	cQuery += "  AND FRC.FRC_CODADM BETWEEN '" + cAdminIni + "' AND '" + cAdminFim + "' "
	cQuery += "  AND FRC.FRC_CODADM = SAE.AE_COD "
	cQuery += "  AND FRC.FRC_STATUS IN ('03','04') "
	cQuery += "	 AND FRC.D_E_L_E_T_ <> '*' "
	//cQuery += "ORDER BY FRC_PREFIX,FRC_NUM,FRC_PARCEL,FRC_FORNEC+FRC_LOJA"

	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QRYFRC",.T.,.F.)

	TcSetField( "QRYFRC", "FRC_VALOR" 	, "N", aTamValor[1]	, aTamValor[2] )
	TcSetField( "QRYFRC", "FRC_VALREC" 	, "N", aTamValRec[1], aTamValRec[2] )

#ELSE
	cFiltro := "FRC.FRC_FILIAL == xFilial('FRC') "
	cFiltro += ".and. FRC_DATTEF >= DTOS(dDataIni) .and. FRC_DATTEF <= DTOS(dDataFinal) "
	cFiltro += ".and. FRC_FORNEC >= cClientIni .and. <= cClientFim "
	cFiltro += ".and. FRC_CODADM >= cAdminIni .and. <= cAdminFim "
	cFiltro += ".and. FRC_CODADM == SAE.AE_COD "
	cFiltro += ".and. FRC_STATUS $ '03|04' "
#ENDIF
dbSelectArea("QRYFRC")
dbGoTop()

While ! QRYFRC->(Eof())

	dbSelectArea("TRB")
	RecLock("TRB",.T.)
	TRB->PREFIXO  := QRYFRC->FRC_PREFIX
	TRB->TITULO   := QRYFRC->FRC_NUM
	TRB->PARCELA  := QRYFRC->FRC_PARCEL
	TRB->TIPO	  := QRYFRC->FRC_TIPO
	TRB->FORNECE  := QRYFRC->FRC_FORNEC
	TRB->LOJA	  := QRYFRC->FRC_LOJA
	TRB->STATUS   := QRYFRC->FRC_STATUS
	TRB->MOTIVO   := QRYFRC->FRC_MOTIVO
	TRB->CARTAO   := QRYFRC->FRC_NUMCAR
	TRB->VALIDADE := QRYFRC->FRC_DATVAL
	TRB->ADMINIST := QRYFRC->AE_DESC
	TRB->VALOR    := QRYFRC->FRC_VALOR
	TRB->VALREC   := QRYFRC->FRC_VALREC
	MsUnLock()
	nTotValor += QRYFRC->FRC_VALOR
	nTotValRec += QRYFRC->FRC_VALREC
	QRYFRC->(dbSkip())
End
If nTotValor > 0
	RecLock("TRB",.T.)
	TRB->PREFIXO  := "ZZX"
	TRB->VALOR    := 0.00
	TRB->VALREC   := 0.00
	MsUnLock()

	RecLock("TRB",.T.)
	TRB->PREFIXO  := "ZZZ"
	TRB->VALOR    := nTotValor
	TRB->VALREC   := nTotValRec
	MsUnLock()
EndIf
RestArea(aArea)
Return
