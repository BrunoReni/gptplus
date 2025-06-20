#INCLUDE "testa04.ch"
#INCLUDE "rwmake.ch"

/*/ 
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �TESTA04   � Autor � EWERTON C TOMAZ    � Data �  24/09/01   ���
�������������������������������������������������������������������������͹��
���Descricao � cadastro de codigos de barras							  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP5 IDE                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/  

Template function TESTA04
Local oLoja

CHKTEMPLATE("DCM")

_lSai :=.T.
   
while _lSai
	_cCodPro := Space(TamSX3("B1_COD")[01])
	_cDescri := Space(TamSX3("B1_DESC")[01])
	_cCodbar := Space(TamSX3("B1_CODBAR")[01])

	Define MsDialog oLoja From 63,181 To 250,600 Title STR0001 Pixel //"Cadastro de C�digo de Barras"
	@ 003,005 Say STR0002    Size  56, 7 //"Dados do Produto:"
	@ 009,005 To 040,200
	@ 016,009 Say STR0003    Size  21, 7 //"Codigo"
	@ 015,037 Get _cCodPro   Size 115, 9 Valid(Busca(1)) F3 "SB1" //"SZR" Observa��o: N�o foi encontrada a configura��o dessa consulta "SZR"... Substitu�da pela consulta SB1.
	@ 027,009 Say STR0004    Size  32, 7 //"Descricao"
	@ 026,037 Get _cDescri   Size 145, 9 When .F.
   
	@ 045,005 Say STR0005    Size 100, 7 //"Codigo Barras:"
	@ 051,005 To 071,200
	@ 058,009 Say STR0006    Size  33, 7 //"Coletar"
	@ 057,037 Get _cCodBar   Size 115, 9
                                                                            
	Define sButton from 080,140 Type 1 Action {||Grava(),Close(oLoja)} Enable Of oLoja
	Define sButton from 080,170 Type 2 Action {||Close(oLoja),_lSai:=.F.} Enable Of oLoja
	Activate MsDialog oLoja Center
   
End
Return(.T.)  

/*/ 
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Busca	    � Autor � EWERTON C TOMAZ    � Data �  24/09/01   ���
�������������������������������������������������������������������������͹��
���Descricao �                              							  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP5 IDE                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/  

Static Function Busca(_nTipo)
_cAlias := Alias()
If _nTipo = 1
	_cX := Posicione('SB1',1,xFilial('SB1')+_cCodPro,'B1_COD')
	_cCodBar := SB1->B1_CODBAR
	_cDescri := SB1->B1_DESC
EndIf
DbSelectArea(_cAlias)
If !Empty(_cX)
Return(.T.)
Else
	msgInfo(STR0007) //"Codigo nao cadastrado."
Endif
Return(.F.)

/*/ 
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Grava	    � Autor � EWERTON C TOMAZ    � Data �  24/09/01   ���
�������������������������������������������������������������������������͹��
���Descricao �                              							  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP5 IDE                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function Grava()
DbSelectArea("SB1")
RecLock("SB1",.F.)
SB1->B1_CODBAR := _cCodbar
MsUnlock()
Return(.T.)