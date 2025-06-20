#Include "PROTHEUS.CH"
#Include "GPER705.CH"

/*
���������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������Ŀ��
���Fun��o    � GPER705  � Autor � Ricardo Berti	                 � Data �02/04/2013���
�����������������������������������������������������������������������������������Ĵ��
���Descri��o �Geracao de TXT sobre CREDITO FISCAL E RETENCOES DOS EMPREGADOS-BOLIVIA���
���          � 			Dados extraidos a partir do relatorio RC-IVA - GPER700      ���
���          � 		Obs.: Demais funcoes encontram-se no fonte GPER700.PRW 			���
���          � 		ATENCAO-> Sempre incluir dependencia do fonte GPER700.PRW		���
�����������������������������������������������������������������������������������Ĵ��
���Sintaxe   � GPER705()                                                            ���
�����������������������������������������������������������������������������������Ĵ��
���Parametros�                                                                      ���
�����������������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                             ���
�����������������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL                        ���
�����������������������������������������������������������������������������������Ĵ��
���Programador � Data     � CHAMADO      �  Motivo da Alteracao                     ���
�����������������������������������������������������������������������������������Ĵ��
���            �          �              �                                          ���
���Jonathan Glz�06/05/2015�    PCREQ-4256�Se elimina la funcion AjustaSx1,la cual   ���
���            �          �              �realiza la modificacion aldiccionario de  ���
���            �          �              �datos(SX1) por motivo de adecuacion  nueva���
���            �          �              �estructura de SXs para version 12         ���
������������������������������������������������������������������������������������ٱ�
���������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
*/
Function GPER705()

Local aGetArea	:= GetArea()
Local cPerg		:= "GPR705"
Local nOpca		:= 0
Local aSays		:= {}, aButtons := {} //<== arrays locais de preferencia

Private Titulo	:= STR0001 // "Gera��o do arquivo TXT - Planilha Tribut�ria"
Private cFilialDe
Private cFilialAte
Private cMesAno
Private cMes
Private cAno
Private cMatDe
Private cMatAte
Private cCustoDe
Private cCustoAte
Private cNomeDe
Private cNomeAte
Private cSit
Private cCat
Private nOrdem
Private cArqNome
Private cProcessos
Private cProcedi

Pergunte(cPerg,.F.)

AADD(aSays,STR0002)		//"Este programa gera o arquivo TXT da planilha tribut�ria - informa��es sobre"
AADD(aSays,STR0003)		//"Cr�dito Fiscal e Reten��es dos funcion�rios para uso no Sistema DAVINCI."

AADD(aButtons, { 5,.T.,{|| Pergunte(cPerg,.T. ) } } )
AADD(aButtons, { 1,.T.,{|o| nOpca := 1,IF(gpTudoOK(cPerg),FechaBatch(),nOpca:=0) }} )
AADD(aButtons, { 2,.T.,{|o| FechaBatch() }} )

FormBatch( Titulo, aSays, aButtons )

If nOpca == 1

	Processa({|lEnd| GPR705Proc(),Titulo})		// esta funcao esta' em GPER700
	
EndIf

RestArea(aGetArea)

Return Nil

/*
���������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������Ŀ��
���Fun�ao    � gpTudoOK � Autor � Ricardo Berti	                  � Data �02/04/2013���
�����������������������������������������������������������������������������������Ĵ��
���Descri�ao �Validacao dos dados antes de executar o processo						���
���          �		                                                				���
�����������������������������������������������������������������������������������Ĵ��
���Sintaxe   � gpTudoOK(ExpC1)	                                                    ���
�����������������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1: Grupo de pergunte 		                                    ���
�����������������������������������������������������������������������������������Ĵ��
��� Uso      � GPER705                                                              ���
������������������������������������������������������������������������������������ٱ�
���������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������*/
Static Function gpTudoOK(cPerg)

Local lRet	:= .T.
Local cFile	:= AllTrim(mv_par12)

Pergunte(cPerg,.F.)

If Empty(mv_par03)
	Help(" ",1,"XINVMESANO")
	lRet := .F.
EndIf

//�����������������������������������������������������������Ŀ
//�Verifica o Arquivo TXT                                     �
//�������������������������������������������������������������
If lRet .And. File(cFile) .And. !MsgYesNo(STR0004+CRLF+STR0005)	//  "El archivo existe."###"Desea sobrescribir ?"
	lRet := .F.
Endif

Return(lRet)

function fGetDirc()
Local cRet:= ""
	cRet:= cGetFile('*.*','',,,,176) + "rciva" + DTOS(DATE()) + ".txt"
	
	MV_PAR12:= cRet
return .T.