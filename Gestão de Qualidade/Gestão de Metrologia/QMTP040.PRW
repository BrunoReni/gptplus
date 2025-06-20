#include "protheus.ch"
#include "msGraphi.ch"
#include "QMTP040.CH"

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � QMTP040  � Autor � Denis Martins         � Data �05/03/2007���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Painel de Gestao - "Status de Instrumentos"                ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                 											  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �SIGAQMT                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function QMTP040()

Local aRetPanel := {} //Array com os dados que ser�o exibidos no painel
Local nX

Private aDados  := {{},{},{}}

//Geracao dos Dados para o Grafico
QMTGerGra()

aAdd(aRetPanel,GRP_BAR)
aAdd(aRetPanel,{||})
For nX := 1 To Len(aDados)
	aAdd(aRetPanel,aDados[nX])
Next nX
aAdd(aRetPanel,STR0001)//"Status de Instrumentos"

Return aRetPanel

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �QMTOGerGra� Autor � Denis Martins         � Data �10/03/2007���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Gera os dados do painel de gestao "Posicao dos Documentos"  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                 											  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �SIGAQMT                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function QMTGerGra()
Local cAliasQry := GetNextAlias()

//Selecionando as tabelas para garantir
//que elas existam antes da execucao da query
dbSelectArea("QM2")

BeginSql Alias cAliasQry
	
	SELECT QM2_STATUS, COUNT(QM2_STATUS) NSTASTS FROM %table:QM2% QM2
	WHERE QM2.QM2_FILIAL = %xfilial:QM2% AND
		  QM2.QM2_FLAG = '1' AND	
	      QM2.%NotDel%
	GROUP BY QM2_STATUS
	
EndSql

dbSelectArea(cAliasQry)
If !(cAliasQry)->(Eof())
	While !(cAliasQry)->(Eof())
		aAdd(aDados[1],&(cAliasQry+"->QM2_STATUS"))
		aAdd(aDados[3],{&(cAliasQry+"->NSTASTS")})
		(cAliasQry)->(DbSkip())
	EndDo
EndIf

If Len(aDados[1]) > 0
	aDados[2] := aClone(aDados[1])
EndIf

(cAliasQry)->(DbCloseArea())

Return