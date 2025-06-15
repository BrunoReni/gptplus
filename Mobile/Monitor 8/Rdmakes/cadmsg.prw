#INCLUDE "CadMsg.ch"
#INCLUDE "rwmake.ch"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �NOVO2     � Autor � Marcelo Vieira     � Data �  06/08/01   ���
�������������������������������������������������������������������������͹��
���Descricao � Codigo gerado pelo AP5 IDE.                                ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP5 IDE                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
User Function CadPlmMsg()
Local nStatusTrg := Val(GetSrvProfString("HHTriggerOn","0"))
//Chamada do cadastro de mensagens
U_BRWMSGSFA()
//Chamada da exporta��o de mensagens (quando gatilho estiver habilitado)
If nStatusTrg > 0
	POpenGrp()    // Abre Arquivo de Grupos
	While HHG->(!Eof())
		If HHG->HHG_EMPFIL == cEmpAnt + cFilAnt
			dbSelectArea("HGU")
			dbSetOrder(01)
			dbSeek(HHG->HHG_COD)
			While HGU->(!Eof()) .And. HHG->HHG_COD == HGU->HGU_GRUPO
				XEXPHMV()
				HGU->(dbSkip())
			EndDo
		EndIf
		HHG->(dbSkip())
	EndDo
EndIf
Return

User Function BRWMSGSFA()
//���������������������������������������������������������������������Ŀ
//� Declaracao de Variaveis                                             �
//�����������������������������������������������������������������������
Local cPrefix		:= ""
Private cCadastro	:= STR0001 //"Cadastro de Mensagens"

//���������������������������������������������������������������������Ŀ
//� Monta um aRotina proprio                                            �
//�����������������������������������������������������������������������

Private aRotina := {	{STR0002,"AxPesqui",0,1} ,; //"Pesquisar"
             		 	{STR0003,"AxVisual",0,2} ,; //"Visualizar"
             			{STR0004,"AxInclui",0,3} ,; //"Incluir"
             			{STR0005,"AxAltera",0,4} ,; //"Alterar"
             			{STR0006,"AxDeleta",0,5}	} //"Excluir"

//���������������������������������������������������������������������Ŀ
//� Monta array com os campos para o Browse                             �
//�����������������������������������������������������������������������
Private cString := GetMv("MV_TBLMSG",,"")
Private aCampos := {}
Private cDelFunc := ".T." // Validacao para a exclusao. Pode-se utilizar ExecBlock

If Empty(cString)
	MsgAlert(STR0007) //"Verifique o parametro MV_TBLMSG, alias de mensagens nao configurado"
	Return .T.
Endif

cPrefix := Right(cString, 2) + "_"
aCampos := { {STR0008,cPrefix + "CODMSG","@!"} ,; //"Cod Mensagem"
                   {STR0009,cPrefix+"CODVEND","@!"} ,; //"Vendedor"
                   {STR0010,cPrefix+"DATAMSG","@!"} ,; //"Data"
                   {STR0011,cPrefix+"DATAVIG","@!"} ,; //"Vigencia"
                   {STR0012,cPrefix+"ORIMSG","@!"} ,; //"Origem"
                   {STR0013,cPrefix+"MENSAGE","@!"} } //"Mensagem"

dbSelectArea(cString)
dbSetOrder(1)
dbSelectArea(cString)
mBrowse( 6,1,22,75,cString,aCampos,)

Return
