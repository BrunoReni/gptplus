#INCLUDE "AE_MUNIC.ch"
#INCLUDE "Protheus.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AE_MUNIC  � Autor � Itamar Oliveira    � Data �  23/05/05   ���
�������������������������������������������������������������������������͹��
���Descricao �Cadastro de Municipios									  ���
�������������������������������������������������������������������������͹��
���Uso       �Template CDV - Controle de Despesas de Viagens              ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Template Function AE_MUNIC
Local cVldAlt := ".T." // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
Local cVldExc := "T_VldExcMun()" // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.

Private cString := "LDY"

ChkTemplate("CDV")

dbSelectArea("LDY")
LDY->(dbSetOrder(1))

AxCadastro(cString,STR0001,cVldExc,cVldAlt) //"Cadastro de Municipios"

Return

//***********************************************************************************************************/
//Validacao da Exclusao da Cidade - Se estiver relacionada com alguma solicitacao nao sera apagada
//***********************************************************************************************************/
Template Function VldExcMun()
Local lRet := .T., _aArea := GetArea()

DbSelectArea("LHP")
LHP->(DbSetOrder(1))
If (DbSeek(xFilial() + LDY->LDY_CODIGO))
	MsgInfo(STR0002) //'Este municipio n�o poder� ser excluido por estar relacionado a solicita��es de viagens.'
	lRet := .F.
EndIf
RestArea(_aArea)

Return lRet
