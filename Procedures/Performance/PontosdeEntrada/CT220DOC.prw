#INCLUDE "RWMAKE.CH"
#Include "PROTHEUS.Ch"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CT220DOC  �Autor  �Microsiga           � Data �  10/01/01   ���
�������������������������������������������������������������������������͹��
���Desc.     �Ex de rdmake para gerar linhas sempre diferentes no CT2.    ���
�������������������������������������������������������������������������͹��
���Uso       � AP5                                                        ���
�������������������������������������������������������������������������͹��
���Obs       �   O campo que deverah ser alterado para que a linha gerada ���
���          �seja unica deve ser um dos tres: CT2_LOTE, CT2_SBLOTE ou    ���
���          �CT2_DOC.                                                    ���
���          �   Este RdMake vai criar uma PROCEDURE no banco que farah   ���
���          �os ajustes de geracao de linhas unicas e sera chamado pelo  ���
���          �processo de Consolidacao Geral de empresas. Apos a execucao ���
���          �do processo a Procedure criada pelo Rdmake e a da Consolida-���
���          �cao serao excluidas do Banco pelo proprio sistema.          ���
���          �   O exemplo abaixo grava no campo CT2_DOC dois caracteres, ���
���          �mais a empresa e a dilail origem dos lancamentos.           ���
���          �   A funcao MsParse faz a conversao para os bancos.         ���
���          �   O pto de entrada retorna .T. se executado com sucesso.   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function CT220DOC()
#IFDEF TOP
Local _cEmpAtu    := ParamIxb[1]
Local _cQueryExec
Local _lRet := .F., _cRet

_cQueryExec := "CREATE PROCEDURE CT220DOC_"+_cEmpAtu+CRLF
_cQueryExec +="  (@IN_FILIAL_COR  Char(02),"+CRLF
_cQueryExec +="   @IN_CT2_DATA    Char(08),"+CRLF
_cQueryExec +="   @IN_CT2_LINHA   Char(03),"+CRLF
_cQueryExec +="   @IN_CT2_TPSALD  Char(01),"+CRLF
_cQueryExec +="   @IN_CT2_EMPORI  Char(02),"+CRLF
_cQueryExec +="   @IN_CT2_FILORI  Char(02),"+CRLF
_cQueryExec +="   @IN_CT2_MOEDLC  Char(02),"+CRLF
_cQueryExec +="   @IN_CT2_LOTE    Char(06),"+CRLF
_cQueryExec +="   @IN_CT2_SBLOTE  Char(03),"+CRLF
_cQueryExec +="   @IN_CT2_DOC     Char(06),"+CRLF
_cQueryExec +="   @OUT_CT2_LOTE   Char(06) OutPut,"+CRLF
_cQueryExec +="   @OUT_CT2_SBLOTE Char(06) OutPut,"+CRLF
_cQueryExec +="   @OUT_CT2_DOC    Char(06) OutPut"+CRLF
_cQueryExec +=" )"+CRLF
_cQueryExec +="AS"+CRLF
_cQueryExec +="Declare @cCT2_LOTE     Char(06)"+CRLF
_cQueryExec +="Declare @cCT2_SBLOTE   Char(03)"+CRLF
_cQueryExec +="Declare @cCT2_DOC      Char(06)"+CRLF
_cQueryExec +="BEGIN"+CRLF
_cQueryExec +="   Select @cCT2_LOTE   = @IN_CT2_LOTE"+CRLF
_cQueryExec +="   Select @cCT2_SBLOTE = @IN_CT2_SBLOTE"+CRLF
_cQueryExec +="   Select @cCT2_DOC    = @IN_CT2_DOC"+CRLF
_cQueryExec +="   Select @cCT2_DOC = 'LT'||@IN_CT2_EMPORI||@IN_CT2_FILORI   "+CRLF // monta como quiser
_cQueryExec +="   Select @OUT_CT2_LOTE   = @cCT2_LOTE"+CRLF
_cQueryExec +="   Select @OUT_CT2_SBLOTE = @cCT2_SBLOTE"+CRLF
_cQueryExec +="   Select @OUT_CT2_DOC    = @cCT2_DOC"+CRLF
_cQueryExec +="END"+CRLF

_cQueryExec := MsParse(_cQueryExec,Alltrim(TcGetDB()))
_cRet := TcSqlExec(_cQueryExec)
If _cRet = 0
	_lRet := .T.
Endif
#ENDIF
Return(_lRet)
