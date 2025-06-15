#INCLUDE "protheus.ch" 
#INCLUDE "gemr110.ch"

#DEFINE CHRCOMP If(aReturn[4]==1,15,18)

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Programa  �GEMR110   � Autor � Daniel Tadashi Batori � Data � 12/09/2007 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Impressao das Correcoes Monetarias                            ���
���������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                        ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Template Function GEMR110()
Local oReport

// Valida se tem licen�as para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
ChkTemplate("LOT")

Ajusta()

If FindFunction("TRepInUse") .And. TRepInUse()
	oReport := ReportDef()
	oReport:PrintDialog()
Else
	Return GEMR110R3() // Executa vers�o anterior do fonte
EndIf

Return( .T. )

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �ReportDef �Autor  �Daniel Tadashi Batori� Data �  12/09/2007 ���
��������������������������������������������������������������������������͹��
���Descri��o �Correcoes Monetarias                                         ���
��������������������������������������������������������������������������͹��
���Uso       � AP                                                          ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Static Function ReportDef()
Local oReport
Local oDtCorrecao
Local cPerg := "GER110"
Local nTam  := TamSX3("LIW_PREFIX")[1] + TamSX3("LIW_NUM")[1] + TamSX3("LIW_PARCEL")[1] + 2
Local cPict := PesqPict("LIW","LIW_BASAMO")
Local nTamContr := TamSX3("LIX_NCONTR")[1] + 5

oReport := TReport():New("GEMR110",STR0001,cPerg,;
				{|oReport| ReportPrint(oReport)},STR0002)
//STR0001 "Corre��es Monet�rias"
//STR0002 "Este relat�rio lista os valores das corre��es monet�rias dos t�tulos com vencimento dentro do pe'riodo solicitado"

pergunte("GER110",.F.)
//������������������������������������������������������������������������Ŀ
//� PARAMETROS                                                             �
//� MV_PAR01 : Corre��o monet�ria de                                       �
//� MV_PAR02 : Corre��o monet�ria at�                                      �
//� MV_PAR03 : Contrato de                                                 �
//� MV_PAR04 : Contrato ate                                                �
//� MV_PAR05 : Cliente de                                                  �
//� MV_PAR06 : Cliente ate                                                 �
//� MV_PAR07 : Status do t�tulo 										   �
//� MV_PAR08 : Ordenar po												   �
//��������������������������������������������������������������������������

oDtCorrecao := TRSection():New(oReport, STR0003, {"LIX"}, , .F., .F.) //"Data da CM"
TRCell():New(oDtCorrecao, "LIW_DTREF","LIW",STR0007/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,) //"Mes/Ano CM"
oDtCorrecao:SetLinesBefore(2)

oTitulo := TRSection():New(oDtCorrecao, STR0004, {"LIX","LIW","SA1"}, , .F., .F.) //"Corre��es das Parcelas"
TRCell():New(oTitulo, "LIX_NCONTR" ,"LIX",/*Titulo*/,/*Picture*/,nTamContr,/*lPixel*/,{||LIX_NCONTR},,,"LEFT")
TRCell():New(oTitulo, "A1_LOJA"    ,"SA1",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oTitulo, "A1_COD"     ,"SA1",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oTitulo, "A1_NOME"    ,"SA1",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oTitulo, "TITULO"     ,     ,STR0005/*Titulo*/,/*Picture*/,nTam/*Tamanho*/,/*lPixel*/,{|| LIW->(AllTrim(LIW_PREFIX)+'/'+LIW_NUM+'/'+LIW_PARCEL)},,,"RIGHT") //"Pref./T�t./Parc."
TRCell():New(oTitulo, "LJO_TPDESC" ,"LJO",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/,,,"RIGHT")
TRCell():New(oTitulo, "LIW_TAXA"   ,"LIW",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/,,,"RIGHT")
TRCell():New(oTitulo, "LIW_INDICE" ,"LIW",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oTitulo, "LIW_BASAMO" ,"LIW",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| LIW->(LIW_BASAMO+LIW_BASJUR) })
TRCell():New(oTitulo, "LIW_VLRAMO" ,"LIW",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| LIW->(LIW_VLRAMO+LIW_VLRJUR) })
TRCell():New(oTitulo, "VALOR_ATUAL","LIW",STR0006/*Titulo*/,cPict/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| LIW->(LIW_BASAMO+LIW_VLRAMO+LIW_BASJUR+LIW_VLRJUR) }) //"Valor corrigido"
oTitulo:SetLeftMargin(5)
TRFunction():New(oTitulo:Cell("LIW_BASAMO") ,,"SUM",,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.T./*lEndReport*/,.F./*lEndPage*/)
TRFunction():New(oTitulo:Cell("LIW_VLRAMO") ,,"SUM",,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.T./*lEndReport*/,.F./*lEndPage*/)
TRFunction():New(oTitulo:Cell("VALOR_ATUAL"),,"SUM",,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.T./*lEndReport*/,.F./*lEndPage*/)
oTitulo:SetTotalInLine(.F.)

oReport:SetTotalInLine(.F.)

Return oReport

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Programa  �ReportPrint� Autor �Daniel Batori          � Data �12/09/2007���
��������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao estatica ReportDef devera ser criada para todos os  ���
���          �relatorios que poderao ser agendados pelo usuario.           ���
��������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                       ���
��������������������������������������������������������������������������Ĵ��
���Parametros�ExpO1: Objeto Report do Relat�rio                            ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Static Function ReportPrint(oReport)
Local oDtCorrecao := oReport:Section(1)
Local oTitulo     := oReport:Section(1):Section(1)
Local cFiltro := ""
Local cFilLIW := xFilial("LIW")
Local cFilLJO := xFilial("LJO")
Local cFilSA1 := xFilial("SA1")  
Local cDB 	  := ""
#IFDEF TOP
	Local cAliasQry := GetNextAlias()
#ELSE
	Local cFilLIX := xFilial("LIX")
	Local cFilLIT := xFilial("LIT")
#ENDIF

//Valida perguntas
If !Valida()
	Return
EndIf

#IFDEF TOP

	cFiltro := " AND LIX_DTVENC BETWEEN '" + SubStr(Mv_Par01,4,4) + SubStr(Mv_Par01,1,2) + "01' AND '" + ;
					SubStr(Mv_Par02,4,4) + SubStr(Mv_Par02,1,2) + "31' "

   If !Empty(Mv_Par03)
   	cFiltro += " AND LIX_NCONTR >= '" + Mv_Par03 + "' "
   EndIf
	If !(Upper(Mv_Par04)==Replicate("Z",Len(Mv_Par04)))
		cFiltro += " AND LIX_NCONTR <= '" + Mv_Par04 + "' "
	EndIf
   If !Empty(Mv_Par05)
   	cFiltro += " AND LIT_CLIENT >= '" + Mv_Par05 + "' "
   EndIf
	If !(Upper(Mv_Par06)==Replicate("Z",Len(Mv_Par06)))
		cFiltro += " AND LIT_CLIENT <= '" + Mv_Par06 + "' "
	EndIf
	If Mv_Par07==1     //titulos em aberto
		cFiltro += " AND E1_SALDO > 0 "
	ElseIf Mv_Par07==2 //titulos baixados
		cFiltro += " AND E1_SALDO = 0 "
	EndIf
	If Mv_Par08==1     //titulos em aberto
		cFiltro += " ORDER BY LIX_DTVENC, LIX_NUM, LIX_PARCEL"
	ElseIf Mv_Par08==2 //titulos baixados
		cFiltro += " ORDER BY DTVENCTO , LIX_NCONTR, LIX_NUM, LIX_PARCEL "
	EndIf
	
	cFiltro := "% " + cFiltro + " %"

	oDtCorrecao:BeginQuery()	
	BeginSql Alias cAliasQry
		SELECT SUBSTRING(LIX_DTVENC,1,6) DTVENCTO, LIX_DTVENC, LIX_NCONTR, LIX_PREFIX, LIX_NUM, LIX_PARCEL, LIX_TIPO, LIX_ITCND, LIT_CLIENT, LIT_LOJA
		FROM %table:LIX% LIX
				JOIN %table:LIT% LIT	ON LIX_NCONTR=LIT_NCONTR
				JOIN %table:SE1% SE1	ON LIX_PREFIX=E1_PREFIXO AND LIX_NUM=E1_NUM AND LIX_PARCEL=E1_PARCELA AND LIX_TIPO=E1_TIPO
		WHERE LIX_FILIAL = %xFilial:LIX% AND
				LIT_FILIAL = %xFilial:LIT% AND
				E1_FILIAL  = %xFilial:SE1% AND
				LIX.%NotDel% AND
				LIT.%NotDel% AND
				SE1.%NotDel%
				%Exp:cFiltro%
	EndSQL              

	oDtCorrecao:EndQuery()

	oTitulo:SetParentQuery()
	oTitulo:SetParentFilter({|cParam| SubStr(DtoS((cAliasQry)->LIX_DTVENC),1,6) == cParam},{|| SubStr(DtoS((cAliasQry)->LIX_DTVENC),1,6) })

	TRPosition():New(oTitulo, "LJO", 1, {|| cFilLJO + (cAliasQry)->(LIX_NCONTR+LIX_ITCND) })
	TRPosition():New(oTitulo, "SA1", 1, {|| cFilSA1 + (cAliasQry)->(LIT_CLIENT+LIT_LOJA) })
	
	LIW->(DbSetOrder(1))	
	oDtCorrecao:SetLineCondition({|| LIW->(DbSeek(cFilLIW+(cAliasQry)->(LIX_PREFIX+LIX_NUM+LIX_PARCEL+LIX_TIPO+SubStr(DtoS(LIX_DTVENC),1,6)))) })
	oTitulo:SetLineCondition({|| Imprime(cAliasQry) })
	
	oDtCorrecao:Cell("LIW_DTREF"):SetBlock({|| SubStr(DtoS((cAliasQry)->LIX_DTVENC),5,2)+"/"+SubStr(DtoS((cAliasQry)->LIX_DTVENC),1,4)})
	
#ELSE

	cFiltro := "LIX_FILIAL=='"+cFilLIX+"' .And. "+;
					"DTOS(LIX_DTVENC)>='" + SubStr(Mv_Par01,4,4)+SubStr(Mv_Par01,1,2)+"01' .And. "+;
					"DTOS(LIX_DTVENC)<='" + SubStr(Mv_Par02,4,4)+SubStr(Mv_Par02,1,2)+"31' "

   If !Empty(Mv_Par03)
   	cFiltro += " .And. LIX_NCONTR >= '" + Mv_Par03 + "' "
   EndIf
	If !(Upper(Mv_Par04)==Replicate("Z",Len(Mv_Par04)))
		cFiltro += " .And. LIX_NCONTR <= '" + Mv_Par04 + "' "
	EndIf

	oDtCorrecao:SetFilter(cFiltro,"LIX_FILIAL+LEFT(DTOS(LIX_DTVENC),6)+LIX_NCONTR")
	oTitulo:SetParentFilter({|cParam| LEFT(DTOS(LIX->LIX_DTVENC),6) == cParam},{|| LEFT(DTOS(LIX->LIX_DTVENC),6)})

	TRPosition():New(oTitulo, "LJO", 1, {|| cFilLJO + LIX->(LIX_NCONTR+LIX_ITCND) })
	TRPosition():New(oTitulo, "LIT", 2, {|| cFilLIT + LIX->LIX_NCONTR })
	TRPosition():New(oTitulo, "SA1", 1, {|| cFilSA1 + LIT->(LIT_CLIENT+LIT_LOJA) })
	
	LIW->(DbSetOrder(1))	
	oDtCorrecao:SetLineCondition({|| LIW->(DbSeek(cFilLIW+LIX->(LIX_PREFIX+LIX_NUM+LIX_PARCEL+LIX_TIPO+SubStr(DtoS(LIX_DTVENC),1,6)))) })
	oTitulo:SetLineCondition({|| Imprime("LIX") })
	
	oDtCorrecao:Cell("LIW_DTREF"):SetBlock({|| SubStr(DtoS(LIX->LIX_DTVENC),5,2)+"/"+SubStr(DtoS(LIX->LIX_DTVENC),1,4)})

#ENDIF

oDtCorrecao:Print()
	
Return (.T.)

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Programa  �Imprime    � Autor �Daniel Batori          � Data �25/10/2007���
��������������������������������������������������������������������������Ĵ��
���Descri��o �Verifica se deve imprimir a linha do TReport.                ���
��������������������������������������������������������������������������Ĵ��
���Retorno   �.T. para imprimir a linha                                    ���
���          �.F. para nao imprimir a linha                                ���
��������������������������������������������������������������������������Ĵ��
���Parametros�cAlias : alias da tabela(DBF) ou do select(TOP)              ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Static Function Imprime(cAlias)
Local lRet := .F.

lRet := LIW->(DbSeek(xFilial("LIW")+(cAlias)->(LIX_PREFIX+LIX_NUM+LIX_PARCEL+LIX_TIPO+SubStr(DtoS(LIX_DTVENC),1,6))))

If lRet .And. !(Mv_Par07==3)
	SE1->(DbSetOrder(1)) //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
	If SE1->(DbSeek(xFilial("SE1")+(cAlias)->(LIX_PREFIX+LIX_NUM+LIX_PARCEL+LIX_TIPO)))
		If (SE1->E1_SALDO=0 .And. Mv_Par07==1) .Or.; //titulos em aberto
			(SE1->E1_SALDO>0 .And. Mv_Par07==2)       //titulos baixados
			lRet := .F.
		EndIf
	EndIf
EndIf

Return lRet






//----------------------------RELEASE 3-------------------------------------//







/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � GEMR110R3� Autor � Daniel Tadashi Batori � Data � 17.09.07 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Impressao das Correcoes Monetarias                          ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function GEMR110R3()
Local cDesc1   := STR0002 //"Este relat�rio lista os valores das corre��es monet�rias dos t�tulos com vencimento dentro do pe'riodo solicitado"
Local cDesc2   := "" 
Local cDesc3   := ""
Local cString  := "LIX"
Local lDic     := .F.
Local lComp    := .T.
Local lFiltro  := .F.
Local wnrel    := "gemr110"

Private NomeProg:= "gemr110"
Private Titulo  := STR0001 //"Corre��es Monet�rias dos Contratos"
Private Tamanho := "M"     // P/M/G
Private Cabec1  := STR0011 //"Contrato        Lj Codigo Nome                      Pref/Tit/Parc  Desc.Parc. Taxa     Indice      Vlr.Base CM.Amort. Vlr.Corrigido"
Private Cabec2  := ""
Private Limite  := 132   // 80/132/220
Private nLi     := 100   // Contador de Linhas
Private cPerg   := "GER110"  // Pergunta do Relatorio
Private aReturn := { STR0009, 1, STR0010, 1, 2, 1, ,1 } //"Zebrado"###"Administracao"
						//[1] Reservado para Formulario
						//[2] Reservado para N� de Vias
						//[3] Destinatario
						//[4] Formato => 1-Comprimido 2-Normal
						//[5] Midia   => 1-Disco 2-Impressora
						//[6] Porta ou Arquivo 1-LPT1... 4-COM1...
						//[7] Expressao do Filtro
						//[8] Ordem a ser selecionada
						//[9]..[10]..[n] Campos a Processar (se houver)

Private lEnd    := .F.// Controle de cancelamento do relatorio
Private m_pag   := 1  // Contador de Paginas                                                                                             	
Private nLastKey:= 0  // Controla o cancelamento da SetPrint e SetDefault

//������������������������������������������������������������������������Ŀ
//� PARAMETROS                                                             �
//� MV_PAR01 : Corre��o monet�ria de                                       �
//� MV_PAR02 : Corre��o monet�ria at�                                      �
//� MV_PAR03 : Contrato de                                                 �
//� MV_PAR04 : Contrato ate                                                �
//� MV_PAR05 : Cliente de                                                  �
//� MV_PAR06 : Cliente ate                                                 �
//� MV_PAR07 : Status do t�tulo	                                           �
//� MV_PAR08 : Ordenar Por      	                                       �
//��������������������������������������������������������������������������
Pergunte(cPerg,.F.)

wnrel:=SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,lDic,"",lComp,Tamanho,lFiltro)

If ( nLastKey==27 )
	dbSelectArea(cString)
	dbSetOrder(1)
	dbClearFilter() //Set Filter to
	Return
Endif

SetDefault(aReturn,cString)

RptStatus( {|lEnd| gemr110Proc(@lEnd,wnRel,cString,nomeprog,Titulo)},Titulo)

Set Device To Screen

If ( aReturn[5] = 1 )
	dbCommitAll()
	Set Printer To
	OurSpool(wnrel)
Endif

MS_FLUSH()

Return(.T.)

/*
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
���������������������������������������������������������������������������������Ŀ��
���Programa  �gemr110Proc� Autor � Daniel Tadashi Batori        � Data �17.09.2007���
���������������������������������������������������������������������������������Ĵ��
���Descricao �Executa o processamento do relatorio.                               ���
����������������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
*/
Function gemr110Proc(lEnd,wnRel,cString,nomeprog,Titulo)
Local aArea   := GetArea()
Local cFilLIW := xFilial("LIW")
Local cFilLJO := xFilial("LJO")
Local cFilSA1 := xFilial("SA1")
Local aDados  := {}
Local nTam    := TamSX3("LIW_PREFIX")[1] + TamSX3("LIW_NUM")[1] + TamSX3("LIW_PARCEL")[1] + 2
Local nX      := 0
Local cDtAnt  := ""
Local nSubBas := 0
Local nSubAmo := 0
Local nTotBas := 0
Local nTotAmo := 0
Local nLinMax := 58
#IFDEF TOP
	Local cFiltro := ""
	Local cAliasQry := GetNextAlias()
#ELSE
	Local cFilLIX := xFilial("LIX")
	Local cFilLIT := xFilial("LIT")
	Local lContinua := .F.
#ENDIF

//Valida perguntas
If !Valida()
	Return
EndIf

#IFDEF TOP
	cFiltro := " AND LIX_DTVENC BETWEEN '" + SubStr(Mv_Par01,4,4) + SubStr(Mv_Par01,1,2) + "01' AND '" + ;
					SubStr(Mv_Par02,4,4) + SubStr(Mv_Par02,1,2) + "31' "

   If !Empty(Mv_Par03)
   	cFiltro += " AND LIX_NCONTR >= '" + Mv_Par03 + "' "
   EndIf
	If !(Upper(Mv_Par04)==Replicate("Z",Len(Mv_Par04)))
		cFiltro += " AND LIX_NCONTR <= '" + Mv_Par04 + "' "
	EndIf
   If !Empty(Mv_Par05)
   	cFiltro += " AND LIT_CLIENT >= '" + Mv_Par05 + "' "
   EndIf
	If !(Upper(Mv_Par06)==Replicate("Z",Len(Mv_Par06)))
		cFiltro += " AND LIT_CLIENT <= '" + Mv_Par06 + "' "
	EndIf
	If Mv_Par07==1     //titulos em aberto
		cFiltro += " AND E1_SALDO > 0 "
	ElseIf Mv_Par07==2 //titulos baixados
		cFiltro += " AND E1_SALDO = 0 "
	EndIf
   	If Mv_Par08==1     //titulos em aberto
		cFiltro += " ORDER BY LIX_DTVENC, LIX_NUM, LIX_PARCEL "
	ElseIf Mv_Par08==2 //titulos baixados
		cFiltro += " ORDER BY DTVENCTO, LIX_NCONTR, LIX_NUM, LIX_PARCEL  "
	EndIf  


	cFiltro := "% " + cFiltro + " %"

	BeginSql Alias cAliasQry
		SELECT SUBSTRING(LIX_DTVENC,1,6) DTVENCTO, LIX_DTVENC, LIX_NCONTR, LIX_PREFIX, LIX_NUM, LIX_PARCEL, LIX_TIPO, LIX_ITCND, LIT_CLIENT, LIT_LOJA
		FROM %table:LIX% LIX
				JOIN %table:LIT% LIT	ON LIX_NCONTR=LIT_NCONTR
				JOIN %table:SE1% SE1	ON LIX_PREFIX=E1_PREFIXO AND LIX_NUM=E1_NUM AND LIX_PARCEL=E1_PARCELA AND LIX_TIPO=E1_TIPO
		WHERE LIX_FILIAL = %xFilial:LIX% AND
				LIT_FILIAL = %xFilial:LIT% AND
				E1_FILIAL  = %xFilial:SE1% AND
				LIX.%NotDel% AND
				LIT.%NotDel% AND
				SE1.%NotDel%
				%Exp:cFiltro%
	EndSQL

	(cAliasQry)->(DbGotop())
	LIW->(DbSetOrder(1)) //LIW_FILIAL+LIW_PREFIX+LIW_NUM+LIW_PARCEL+LIW_TIPO+LIW_DTREF
	LJO->(DbSetOrder(1)) //LJO_FILIAL+LJO_NCONTR+LJO_ITEM
	SA1->(DbSetOrder(1)) //A1_FILIAL+A1_COD+A1_LOJA
	
	While !(cAliasQry)->(Eof())

		If LIW->(DbSeek(cFilLIW+(cAliasQry)->(LIX_PREFIX+LIX_NUM+LIX_PARCEL+LIX_TIPO+SubStr(LIX_DTVENC,1,6) )))
			
			LJO->(DbSeek(cFilLJO + (cAliasQry)->(LIX_NCONTR+LIX_ITCND) ))
			SA1->(DbSeek(cFilSA1 + (cAliasQry)->(LIT_CLIENT+LIT_LOJA) ))
			
			aAdd(aDados,{LIW->LIW_DTREF,;
							(cAliasQry)->LIX_NCONTR,;
							SA1->A1_LOJA,;
							SA1->A1_COD,;
							SA1->A1_NOME,;
							Padl( LIW->(AllTrim(LIW_PREFIX)+'/'+LIW_NUM+'/'+LIW_PARCEL), nTam),;
							LJO->LJO_TPDESC,;
							LIW->LIW_TAXA,;
							LIW->LIW_INDICE,;
							LIW->(LIW_BASAMO+LIW_BASJUR),;
							LIW->(LIW_VLRAMO+LIW_VLRJUR),;
							LIW->(LIW_BASAMO+LIW_VLRAMO+LIW_BASJUR+LIW_VLRJUR);
							})

		EndIf
		(cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->(DbCloseArea())

#ELSE

	SA1->(DbSetOrder(1)) //A1_FILIAL+A1_COD+A1_LOJA
	LIT->(DbSetOrder(2)) //LIT_FILIAL+LIT_NCONTR
	LIW->(DbSetOrder(1)) //LIW_FILIAL+LIW_PREFIX+LIW_NUM+LIW_PARCEL+LIW_TIPO+LIW_DTREF
	LJO->(DbSetOrder(1)) //LJO_FILIAL+LJO_NCONTR+LJO_ITEM
	LIX->(DbSetOrder(3)) //LIX_FILIAL+LIX_NCONTR+LIX_PREFIX+LIX_NUM+LIX_PARCEL+LIX_TIPO
	SE1->(DbSetOrder(1)) //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
	LIX->(DbSeek(cFilLIX+Mv_Par03,.T.))
	
	While !(LIX->(Eof())) .And. LIX->(LIX_FILIAL+LIX_NCONTR) <= cFilLIX+Mv_Par04

		If DTOS(LIX->LIX_DTVENC) >= (SubStr(Mv_Par01,4,4)+SubStr(Mv_Par01,1,2)+"01") .And.;
			DTOS(LIX->LIX_DTVENC) <= (SubStr(Mv_Par02,4,4)+SubStr(Mv_Par02,1,2)+"31")
	
			If LIT->(DbSeek(cFilLIT+LIX->LIX_NCONTR)) .And.;
				LIT->LIT_CLIENT >= Mv_Par05 .And. LIT->LIT_CLIENT <= Mv_Par06

				If LIW->(DbSeek(cFilLIW+LIX->(LIX_PREFIX+LIX_NUM+LIX_PARCEL+LIX_TIPO+SubStr(DTOS(LIX_DTVENC),1,6) )))
				
					SA1->(DbSeek(cFilSA1 + LIT->(LIT_CLIENT+LIT_LOJA) ))
					LJO->(DbSeek(cFilLJO + LIX->(LIX_NCONTR+LIX_ITCND)))

					lContinua := .T.
					If !(Mv_Par07==3) //titulos todos
						If SE1->(DbSeek(xFilial("SE1")+LIX->(LIX_PREFIX+LIX_NUM+LIX_PARCEL+LIX_TIPO)))
							If (SE1->E1_SALDO=0 .And. Mv_Par07==1) .Or.; //titulos em aberto
								(SE1->E1_SALDO>0 .And. Mv_Par07==2)       //titulos baixados
								lContinua := .F.
							EndIf
						EndIf
					EndIf

		         If lContinua
						aAdd(aDados,{LIW->LIW_DTREF,;
									LIX->LIX_NCONTR,;
									SA1->A1_LOJA,;
									SA1->A1_COD,;
									SA1->A1_NOME,;
									Padl( LIW->(AllTrim(LIW_PREFIX)+'/'+LIW_NUM+'/'+LIW_PARCEL), nTam),;
									LJO->LJO_TPDESC,;
									LIW->LIW_TAXA,;
									LIW->LIW_INDICE,;
									LIW->(LIW_BASAMO+LIW_BASJUR),;
									LIW->(LIW_VLRAMO+LIW_VLRJUR),;
									LIW->(LIW_BASAMO+LIW_VLRAMO+LIW_BASJUR+LIW_VLRJUR);
									})
					EndIf
					
				EndIf
			EndIf
		EndIf
		
		LIX->(DbSkip())
	EndDo

#ENDIF

//ordem por pref+titulo+parcel
//aSort(aDados,,,{|x,y| x[1]+x[6] < y[1]+y[6] })

For nX := 1 to Len(aDados)
	QuebrPag(aDados[nX,1],cDtAnt,nLinMax)
	
	If !(aDados[nX,1]==cDtAnt)
		nLi++
		@ nLi, 000 PSay STR0007 + " : " + SubStr(aDados[nX,1],5,2)+"/"+SubStr(aDados[nX,1],1,4) //"Mes/Ano CM"
		nLi++
		nLi++
		cDtAnt := aDados[nX,1]
		QuebrPag(aDados[nX,1],cDtAnt,nLinMax)
	EndIf

	@ nLi, 000 PSay aDados[nX,2]         //contrato
	@ nLi, 016 PSay aDados[nX,3]         //loja do cliente
	@ nLi, 019 PSay aDados[nX,4]         //codigo do cliente
	@ nLi, 026 PSay PadL(aDados[nX,5],25)//nome do cliente
	@ nLi, 051 PSay Alltrim(aDados[nX,6])         //prefix/numero/parc do titulo
	@ nLi, 068 PSay Alltrim(aDados[nX,7])         //descricao do tipo de parcela
	@ nLi, 078 PSay aDados[nX,8]         //cod da taxa
	@ nLi, 085 PSay Transform( aDados[nX,9], "@E 999.9999")       //indice da taxa aplicada na CM
	@ nLi, 094 PSay Transform( aDados[nX,10], "@E 99,999,999.99") //valor base a ser aplicada a CM
	@ nLi, 108 PSay Transform( aDados[nX,11], "@E 99,999.99")     //valor da CM (amortizacao)
	@ nLi, 118 PSay Transform( aDados[nX,12], "@E 99,999,999.99") //valor do titulo com a CM

	nSubBas += aDados[nX,10]
	nSubAmo += aDados[nX,11]

	If nX == Len(aDados) .Or. !(aDados[nX+1,1]==cDtAnt)
		nLi++
		QuebrPag(aDados[nX,1],cDtAnt,nLinMax)

		@ nLi, 000 PSAY __PrtThinLine()
		nLi++
		QuebrPag(aDados[nX,1],cDtAnt,nLinMax)
		@ nLi, 000 PSay STR0012 //"Subtotal"
		@ nLi, 094 PSay Transform( nSubBas, "@E 99,999,999.99")         //subtotal do valor base a ser aplicada a CM
		@ nLi, 108 PSay Transform( nSubAmo, "@E 99,999.99")             //subtotal do valor da CM (amortizacao)
		@ nLi, 118 PSay Transform( nSubBas+nSubAmo, "@E 99,999,999.99") //subtotal do valor do titulo com a CM

		nTotBas += nSubBas
		nTotAmo += nSubAmo
		nSubBas := 0
		nSubAmo := 0
	EndIf

	nLi++
Next nX

nLi++
QuebrPag(cDtAnt,cDtAnt,nLinMax)
@ nLi, 000 PSAY __PrtThinLine()
nLi++
@ nLi, 000 PSay STR0013 //"Total"
@ nLi, 094 PSay Transform( nTotBas, "@E 99,999,999.99")         //total do valor base a ser aplicada a CM
@ nLi, 108 PSay Transform( nTotAmo, "@E 99,999.99")             //total do valor da CM (amortizacao)
@ nLi, 118 PSay Transform( nTotBas+nTotAmo, "@E 99,999,999.99") //total do valor do titulo com a CM

Roda(0,"",Tamanho)
RestArea(aArea)				
Return

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Programa  � QuebrPag �Autor  �Daniel Tadashi Batori � Data �12/09/2007   ���
���������������������������������������������������������������������������͹��
���Desc.     � Verifica a quebra de pagina                                  ���
���������������������������������������������������������������������������͹��
���Uso       � gemr110                                                      ���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Static Function QuebrPag(cDtAtu,cDtAnt,nLinMax)
If nLi >= nLinMax
	nLi := 0
	nLi := Cabec(Titulo,Cabec1,Cabec2,nomeprog,Tamanho,CHRCOMP)
	If cDtAtu==cDtAnt
		nLi++
	EndIf
EndIf
Return

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Programa  �Valida    �Autor  �Daniel Tadashi Batori � Data �12/09/2007   ���
���������������������������������������������������������������������������͹��
���Desc.     �Valida as perguntas do usuario                                ���
���������������������������������������������������������������������������͹��
���Uso       � gemr110                                                      ���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Static Function Valida()
Local lOk := .T.
Local cAuxMv1 := SubStr(Mv_Par01,4,4) + SubStr(Mv_Par01,1,2)
Local cAuxMv2 := SubStr(Mv_Par02,4,4) + SubStr(Mv_Par02,1,2)

If cAuxMv1  > cAuxMv2  .Or.;
	Mv_Par03 > Mv_Par04 .Or.;
	Mv_Par05 > Mv_Par06
	lOk := .F.
	Alert(STR0008) //"Verifique os par�metros do relat�rio!"
EndIf

Return lOk

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Programa  �Ajusta    �Autor  �Daniel Tadashi Batori � Data �12/09/2007   ���
���������������������������������������������������������������������������͹��
���Desc.     �Insere novas perguntas ao sx1                                 ���
���������������������������������������������������������������������������͹��
���Uso       � gemr110                                                      ���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Static Function Ajusta()
Local aHelpPor	:= {}
Local aHelpEng	:= {}
Local aHelpSpa	:= {}
Local aPergs   := {}

Aadd( aHelpPor, 'Range da corre��o monet�ria a ser       ' )
Aadd( aHelpPor, 'exibido no relat�rio (MM/AAAA).         ' )
Aadd( aHelpSpa, 'Range da corre��o monet�ria a ser       ' )
Aadd( aHelpSpa, 'exibido no relat�rio (MM/AAAA).         ' )
Aadd( aHelpEng, 'Range da corre��o monet�ria a ser       ' )
Aadd( aHelpEng, 'exibido no relat�rio (MM/AAAA).         ' )
Aadd(aPergs,{"Corre��o monet�ria de ?","Corre��o monet�ria de ?","Corre��o monet�ria de ?","mv_ch1","C",7,0,0,"G","NaoVazio()","mv_par01","","",;
				"","","","","","","","","","","","","","","","","","","","","","","","","S","","@E 99/9999",aHelpPor,aHelpEng,aHelpSpa})
Aadd(aPergs,{"Corre��o monet�ria at� ?","Corre��o monet�ria at� ?","Corre��o monet�ria at� ?","mv_ch2","C",7,0,0,"G","NaoVazio()","mv_par02","","",;
				"","","","","","","","","","","","","","","","","","","","","","","","","S","","@E 99/9999",aHelpPor,aHelpEng,aHelpSpa})

aHelpPor	:= {}
aHelpEng	:= {}
aHelpSpa	:= {}
Aadd( aHelpPor, 'Range do contrato a ser exibido no      ' )
Aadd( aHelpPor, 'relat�rio.                              ' )
Aadd( aHelpSpa, 'Range do contrato a ser exibido no      ' )
Aadd( aHelpSpa, 'relat�rio.                              ' )
Aadd( aHelpEng, 'Range do contrato a ser exibido no      ' )
Aadd( aHelpEng, 'relat�rio.                              ' )
Aadd(aPergs,{"Contrato de ?","Contrato de ?","Contrato de ?","mv_ch3","C",15,0,0,"G","","mv_par03","","",;
				"","","","","","","","","","","","","","","","","","","","","","","LIT","","S","","",aHelpPor,aHelpEng,aHelpSpa})
Aadd(aPergs,{"Contrato at� ?","Contrato at� ?","Contrato at� ?","mv_ch4","C",15,0,0,"G","NaoVazio()","mv_par04","","",;
				"","ZZZZZZZZZZZZZZZ","","","","","","","","","","","","","","","","","","","","","LIT","","S","","",aHelpPor,aHelpEng,aHelpSpa})

aHelpPor	:= {}
aHelpEng	:= {}
aHelpSpa	:= {}
Aadd( aHelpPor, 'Range do cliente a ser exibido no       ' )
Aadd( aHelpPor, 'relat�rio.                              ' )
Aadd( aHelpSpa, 'Range do cliente a ser exibido no       ' )
Aadd( aHelpSpa, 'relat�rio.                              ' )
Aadd( aHelpEng, 'Range do cliente a ser exibido no       ' )
Aadd( aHelpEng, 'relat�rio.                              ' )
Aadd(aPergs,{"Cliente de ?","Cliente de ?","Cliente de ?","mv_ch5","C",6,0,0,"G","","mv_par05","","",;
				"","","","","","","","","","","","","","","","","","","","","","","SA1","","S","","",aHelpPor,aHelpEng,aHelpSpa})
Aadd(aPergs,{"Cliente at� ?","Cliente at� ?","Cliente at� ?","mv_ch6","C",6,0,0,"G","NaoVazio()","mv_par06","","",;
				"","ZZZZZZ","","","","","","","","","","","","","","","","","","","","","SA1","","S","","",aHelpPor,aHelpEng,aHelpSpa})

aHelpPor	:= {}
aHelpEng	:= {}
aHelpSpa	:= {}
Aadd( aHelpPor, 'Visualizar titulos "em aberto",         ' )
Aadd( aHelpPor, '"baixados" ou "todos".                  ' )
Aadd( aHelpSpa, 'Visualizar titulos "em aberto",         ' )
Aadd( aHelpSpa, '"baixados" ou "todos".                  ' )
Aadd( aHelpEng, 'Visualizar titulos "em aberto",         ' )
Aadd( aHelpEng, '"baixados" ou "todos".                  ' )
Aadd(aPergs,{"Status do t�tulo ?","Status do t�tulo ?","Status do t�tulo ?","mv_ch7","N",1,0,1,"C","","mv_par07","em aberto","",;
				"","","","baixados","","","","","todos","","","","","","","","","","","","","","","","S","","",aHelpPor,aHelpEng,aHelpSpa})

aHelpPor	:= {}
aHelpEng	:= {}
aHelpSpa	:= {}
Aadd( aHelpPor, 'Ordena��o da impressao do relatorio.	 ' )
Aadd( aHelpPor, '                                        ' )
Aadd( aHelpSpa, 'Ordena��o da impressao do relatorio.    ' )
Aadd( aHelpSpa, '                                        ' )
Aadd( aHelpEng, 'Ordena��o da impressao do relatorio.    ' )
Aadd( aHelpEng, '                                        ' )
Aadd(aPergs,{"Ordenar  por :         ","Ordenar por :          ","Ordenar por :          ","mv_ch8","N",1,0,1,"C","","mv_par08","Vencto/Num/Parcela","",;
				"","","","Contrato","","","","","","","","","","","","","","","","","","","","","S","","",aHelpPor,aHelpEng,aHelpSpa})


AjustaSX1("GER110",aPergs)

Return
