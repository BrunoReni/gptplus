#INCLUDE "TMSRD20.CH"
#INCLUDE "PROTHEUS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � TMSRD20  � Autor �Vitor Raspa            � Data � 11.Set.06���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Impressao de Documentos Exigidos X Motoristas              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSRD20                                                    ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Gestao de Transporte                                       ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function TMSRD20()

Local titulo   		:= STR0001 //-- "Documentos Exigidos X Motoristas"
Local cString  		:= 'DD4'
Local wnrel    		:= 'TMSRD20'
Local cDesc1   		:= STR0002 //-- "Este programa ira listar os Documentos Exigidos X Motoristas"
Local cDesc2   		:= ''
Local cDesc3   		:= ''
Local tamanho  		:= 'M'
Local nLimite  		:= 132
Local aCposProtg	:= {}
Local aCpoAccess	:= {'A2_NOME'}

Private NomeProg := 'TMSRD20'
Private aReturn  := {STR0003,1,STR0004,2, 2, 1, '',1 } //-- "Zebrado"###"Administracao"
Private cPerg    := 'TMRD20'
Private nLastKey := 0
//��������������������������������������������������������������Ŀ
//� Verifica as perguntas                                        �
//����������������������������������������������������������������
//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                         �
//� MV_PAR01        	// Periodo Inicial    	                 �
//� MV_PAR02        	// Periodo Final                         �
//� MV_PAR03        	// Do Fornecedor      	                 �
//� MV_PAR04        	// Da Loja            	                 �
//� MV_PAR05        	// Ate o Fornecedor   	                 �
//� MV_PAR06        	// Ate a Loja         	                 �
//� MV_PAR07        	// Do Motorista       	                 �
//� MV_PAR08        	// Ate o Motorista    	                 �
//� MV_PAR09        	// Situacao dos Documentos               �
//����������������������������������������������������������������

If ExistFunc('TMLGPDCpPr')
	aCposProtg := TMLGPDCpPr(aCpoAccess, "SA2")
	If ExistFunc('FWPDCanUse') .And. FWPDCanUse() .And. !Empty(aCposProtg)
		If Len(FwProtectedDataUtil():UsrAccessPDField( __CUSERID, aCposProtg )) < Len(aCposProtg)
			Help(" ",1,STR0010,,,5,11) //"LGPD - Acesso Restrito: Este usu�rio n�o possui permiss�o de acesso aos dados dessa rotina. Para mais informa��es contate o Administrador do sistema !!"
			Return
		EndIf	
	EndIf
EndIf

pergunte(cPerg,.F.)

wnrel := SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,'',,Tamanho)

If nLastKey = 27
	Set Filter To
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey = 27
	Set Filter To
	Return
Endif

RptStatus({|lEnd| TMSRD20Imp(@lEnd,wnRel,titulo,tamanho,nLimite)},titulo)

Return NIL

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TMSRD20Imp� Autor �Vitor Raspa            � Data � 11.Set.06���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Chamada do Relat�rio                                       ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � TMSRD20			                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function TMSRD20Imp(lEnd,wnRel,cTitulo,nTamanho,nLimite)
Local nLin      := 80
Local cDesc1    := ''
Local cDesc2    := ''
Local cQuebra   := ''
Local cCodMot   := ''
Local cQuery    := ''
Local cAliasQry := GetNextAlias()

Private M_Pag   := 1	

cQuery := "SELECT DD4.DD4_CODMOT, DD4.DD4_CODDOC, DD4.DD4_PRXAPR, DD0.DD0_DESDOC, DA4.DA4_COD, DA4.DA4_NOME, "
cQuery += "DA4.DA4_FORNEC, DA4.DA4_LOJA, DA4.DA4_TIPMOT  "
cQuery += "FROM " 
cQuery += RetSQLName('DD4') + " DD4, " 
cQuery += RetSQLName('DA4') + " DA4, " 
cQuery += RetSQLName('DD0') + " DD0, " 
cQuery += RetSQLName('DD2') + " DD2 "
cQuery += "WHERE "
cQuery += "DD4.DD4_FILIAL = '" + xFilial('DD4') + "' AND "
cQuery += "DA4.DA4_FILIAL = '" + xFilial('DA4') + "' AND "
cQuery += "DD0.DD0_FILIAL = '" + xFilial('DD0') + "' AND "
cQuery += "DD2.DD2_FILIAL = '" + xFilial('DD2') + "' AND "

cQuery += "DD4.DD4_PRXAPR BETWEEN '" + DtoS(MV_PAR01) + "' AND '" + DtoS(MV_PAR02) + "' AND "
cQuery += "DA4.DA4_COD = DD4.DD4_CODMOT AND "
cQuery += "DD0.DD0_CODDOC = DD4.DD4_CODDOC AND "
cQuery += "DA4.DA4_FORNEC BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR05 + "' AND "
cQuery += "DA4.DA4_LOJA BETWEEN '" + MV_PAR04 + "' AND '" + MV_PAR06 + "' AND "
cQuery += "DD4.DD4_CODMOT BETWEEN '" + MV_PAR07 + "' AND '" + MV_PAR08 + "' AND "
cQuery += "DD2.DD2_CODMOT = DD4.DD4_CODMOT AND "
If MV_PAR09 == 1
	cQuery += "DD2.DD2_STATUS = '1' AND "
ElseIf MV_PAR09 == 2
	cQuery += "(DD2.DD2_STATUS = '2' OR DD2.DD2_STATUS = '4') AND "	
EndIf
cQuery += "DD4.D_E_L_E_T_ = '' AND DA4.D_E_L_E_T_ = '' AND "
cQuery += "DD0.D_E_L_E_T_ = '' AND DD2.D_E_L_E_T_ = '' "
cQuery += "ORDER BY DA4.DA4_FORNEC, DA4.DA4_LOJA"
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)
TcSetField(cAliasQry,"DD4_PRXAPR","D",8,0)	

While !(cAliasQry)->(EoF())
	If Interrupcao(@lEnd)
		Exit
	Endif

	If nLin > 60
		nLin := Cabec( cTitulo, cDesc1, cDesc2, NomeProg, nTamanho ) + 1
	EndIf

	If cQuebra <> (cAliasQry)->(DA4_FORNEC+DA4_LOJA)
		VerLin(@nLin,1)
		@ nLin, 000 Psay __PrtThinLine()
		VerLin(@nLin,1)

		@ nLin, 000 PSay STR0005 //-- "Fornecedor"
		VerLin(@nLin,1)	

		If (cAliasQry)->DA4_TIPMOT <> '1'
			@ nLin,000 PSay (cAliasQry)->(DA4_FORNEC + '/' + DA4_LOJA)
			@ nLin,015 PSay ' - ' + Posicione('SA2',1,xFilial('SA2') + (cAliasQry)->(DA4_FORNEC+DA4_LOJA),'A2_NOME')
		Else
			@ nLin,000 PSay STR0009 //-- "Motorista Proprio"
		EndIf

		VerLin(@nLin,1)
		@ nLin, 000 PSay __PrtThinLine()
		VerLin(@nLin,1)

		@ nLin, 000 PSay STR0006 //-- "Motorista"
		@ nLin, 043 PSay STR0007 //-- "Documentos"
		@ nLin, 081 PSay STR0008 //-- "Prox. Apres."
		VerLin(@nLin,1)
		@ nLin, 000 PSay __PrtThinLine()
		VerLin(@nLin,1)

        cQuebra := (cAliasQry)->(DA4_FORNEC+DA4_LOJA)
	EndIf
	
	If cCodMot <> (cAliasQry)->DD4_CODMOT
		@ nLin, 000 PSay (cAliasQry)->(DD4_CODMOT + ' - ' + Left(DA4_NOME,30))
		cCodMot := (cAliasQry)->DD4_CODMOT
	EndIf
	@ nLin, 043 PSay (cAliasQry)->(DD4_CODDOC + ' - ' + Left(DD0_DESDOC,30))
	@ nLin, 085 PSay (cAliasQry)->DD4_PRXAPR
	VerLin(@nLin,1)
	
	(cAliasQry)->(DbSkip())
EndDo

//��������������������������������������������������������������Ŀ
//� Se em disco, desvia para Spool                               �
//����������������������������������������������������������������
If aReturn[5] == 1
	Set Printer To
	dbCommitAll()
	OurSpool(wnrel)
Endif

MS_FLUSH()

Return(.T.)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �VerLin    � Autor �Patricia A. Salomao    � Data �27.02.2002���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Soma Linha                                                 ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � VerLin(ExpN1,ExpN2)                                        ���
�������������������������������������������������������������������������Ĵ��
���Parametro � ExpN1 - No. da Linha atual                                 ���
���          � ExpN2 - No. de Linhas que devera ser somado                ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � RTMSR16			                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function VerLin(Li,nSoma)
Li+=nSoma
If Li > 70
	Li:=1
EndIf
Return