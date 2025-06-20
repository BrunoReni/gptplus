#INCLUDE "TMSRD30.CH"
#INCLUDE "PROTHEUS.CH"

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    � TMSRD30  � Autor �Vitor Raspa            � Data � 11.Set.06 ���
��������������������������������������������������������������������������Ĵ��
���Descri��o �Impressao de Fornecedores X Periodo de Atividade/Inatividade ���
��������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSRD30                                                     ���
��������������������������������������������������������������������������Ĵ��
���Parametros�                                                             ���
��������������������������������������������������������������������������Ĵ��
��� Uso      � Gestao de Transporte                                        ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Function TMSRD30()
Local titulo   		:= STR0001 //-- "Fornecedores X Periodo de Atividade/Inatividade"
Local cString  		:= 'DD1'
Local wnrel    		:= 'TMSRD30'
Local cDesc1   		:= STR0002 //-- "Este programa ira listar os Fornecedores X Periodo de Atividade/Inatividade"
Local cDesc2   		:= ''
Local cDesc3   		:= ''
Local tamanho  		:= 'M'
Local nLimite  		:= 132
Local aCposProtg	:= {}
Local aCpoAccess	:= {'A2_NOME'}


Private NomeProg := 'TMSRD30'
Private aReturn  := {STR0003,1,STR0004,2, 2, 1, '',1 } //-- "Zebrado"###"Administracao"
Private cPerg    := 'TMRD30'
Private nLastKey := 0
//��������������������������������������������������������������Ŀ
//� Verifica as perguntas                                        �
//����������������������������������������������������������������
//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                         �
//� MV_PAR01        	// Do Fornecedor      	                 �
//� MV_PAR02        	// Da Loja            	                 �
//� MV_PAR03        	// Ate o Fornecedor   	                 �
//� MV_PAR04        	// Ate a Loja         	                 �
//� MV_PAR05        	// Periodo Inicial    	                 �
//� MV_PAR06        	// Periodo Final                         �
//� MV_PAR07        	// Situacao: Ativos / Inativos / Ambos   �
//����������������������������������������������������������������

If ExistFunc('TMLGPDCpPr')
	aCposProtg := TMLGPDCpPr(aCpoAccess, "SA2")
	If ExistFunc('FWPDCanUse') .And. FWPDCanUse() .And. !Empty(aCposProtg)
		If Len(FwProtectedDataUtil():UsrAccessPDField( __CUSERID, aCposProtg )) < Len(aCposProtg)
			Help(" ",1,STR0008,,,5,11) //"LGPD - Acesso Restrito: Este usu�rio n�o possui permiss�o de acesso aos dados dessa rotina. Para mais informa��es contate o Administrador do sistema !!"
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

RptStatus({|lEnd| TMSRD30Imp(@lEnd,wnRel,titulo,tamanho,nLimite)},titulo)

Return NIL

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TMSRD30Imp� Autor �Vitor Raspa            � Data � 11.Set.06���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Chamada do Relat�rio                                       ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � TMSRD30			                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function TMSRD30Imp(lEnd,wnRel,cTitulo,nTamanho,nLimite)
Local nLin      := 80
Local cDesc1    := STR0005 //-- "Fornecedor                                            Data      Periodo      Data     Qtde."
Local cDesc2    := STR0006 //-- "Codigo          Razao Social                        Limite  Afastamento   Retorno  Liberac."
Local aSX3Box   := {}

Private M_Pag   := 1	

DD1->(DbSetOrder(1))
DD1->(MsSeek(xFilial('DD1') + MV_PAR01 + MV_PAR02,.T.))
While !DD1->(EoF()) .And. DD1->(DD1_CODFOR+DD1_LOJFOR) <= MV_PAR03+MV_PAR04
	If Interrupcao(@lEnd)
		Exit
	Endif

	If DD1->DD1_DTCALC >= MV_PAR05 .And. DD1->DD1_DTCALC <= MV_PAR06
		If nLin > 60
			nLin := Cabec( cTitulo, cDesc1, cDesc2, NomeProg, nTamanho ) + 1
		EndIf
	
		SA2->(DbSetOrder(1))
		If SA2->(MsSeek(xFilial('SA2') + DD1->(DD1_CODFOR + DD1_LOJFOR)))
			If SA2->A2_TIPO == 'F'
				@ nLin, 000 PSay DD1->(DD1_CODFOR + '/' + DD1_LOJFOR)
				@ nLin, 017 PSay Left(SA2->A2_NOME,30)
				@ nLin, 051 PSay DD1->DD1_DTAAFA
				@ nLin, 064 PSay Transform(DD1->DD1_DIAAFA, '999') + ' ' + STR0007 //-- "Dias"
				@ nLin, 074 PSay DD1->DD1_DTARET
				@ nLin, 090 PSay DD1->DD1_NUMLIB
				aSX3Box := RetSx3Box( Posicione("SX3", 2, "DD1_CTRLIB", "X3CBox()" ),,, 1 )	
				@ nLin,094 PSay PadC( AllTrim( aSx3Box[Ascan( aSX3Box, { |aBox| aBox[2] = DD1->DD1_CTRLIB } )][3] ), 	10)
				VerLin(@nLin,1)
			EndIf
		EndIf
	EndIf
	DD1->(Dbskip())
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