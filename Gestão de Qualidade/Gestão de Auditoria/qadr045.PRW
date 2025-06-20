#INCLUDE "QADR045.CH"
#INCLUDE "PROTHEUS.CH"
#DEFINE CRLF CHR(13)+CHR(10)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � QADR045  � Autor � Leandro S. Sabino     � Data � 17/05/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Relacao de Emails Associados   			                  ���
�������������������������������������������������������������������������Ĵ��
���Obs:      � (Versao Relatorio Personalizavel) 		                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QADR045	                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
/*/
Function QADR045()
Local cDesc := STR0002 + CRLF + STR0003 + CRLF + STR0004
Local aOrd  := {OemToAnsi(STR0008),OemToAnsi(STR0009)}  //" Usuario + Sobrenome "###" Sobrenome + Usuario "

If TRepInUse()
	MPReport("QADR045","QU5",STR0001,cDesc,aOrd)  // "Lista de e-mails Asociados  "
Else
	QADR045R3() //Executa vers�o anterior do fonte
EndIf

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � QADR045  � Autor � Robson Ramiro A. Olive� Data � 11.04.01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Emiss�o da Rela��o de E-Mails Associados                    ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QADR045(void)                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
��� ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ���
�������������������������������������������������������������������������Ĵ��
��� PROGRAMADOR  � DATA   � BOPS �  MOTIVO DA ALTERACAO                   ���
�������������������������������������������������������������������������Ĵ��
���Robson Ramiro �15/05/02� Meta �Alteracao do alias da familia QU para QA���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function QADR045R3()
//��������������������������������������������������������������Ŀ
//� Define Variaveis                                             �
//����������������������������������������������������������������
LOCAL CbCont,cabec1,cabec2,cabec3,wnrel
LOCAL tamanho := "M"
LOCAL limite  := 132
LOCAL titulo  := OemToAnsi(STR0001)  //"Relacao de Emails Associados"
LOCAL cDesc1  := OemToAnsi(STR0002)  //"Emissao do Cadastro de Emails Associados"
LOCAL cDesc2  := OemToAnsi(STR0003)  //"Ira imprimir os dados dos Emails Associados"
LOCAL cDesc3  := OemToAnsi(STR0004)  //"de acordo com a configuracao do usuario."
LOCAL aOrd    := {}

PRIVATE aReturn  := { OemToAnsi(STR0005), 1,OemToAnsi(STR0006), 2, 2, 1, "",1 }  //"Zebrado"###"Administracao"
PRIVATE aLinha   := { }
PRIVATE nomeprog := "QADR045", nLastKey := 0

//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para Impressao do Cabecalho e Rodape    �
//����������������������������������������������������������������

cbcont   := 0
cabec1   := OemToAnsi(STR0007)  //"RELACAO COMPLETA DO CADASTRO DE EMAILS ASSOCIADOS"
cabec2   := Replicate("-",limite)
cabec3   := " "
cString  := "QU5"

aOrd     := {OemToAnsi(STR0008),OemToAnsi(STR0009)}  //" Usuario + Sobrenome "###" Sobrenome + Usuario "

wnrel    := "QADR045"

Private AParDef := {}

wnrel := SetPrint(cString,wnrel,"ParamDef(cAlias)",@Titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,,tamanho)

If nLastKey = 27
	Set Filter To
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey = 27
	Set Filter To
	Return
Endif

RptStatus({|lEnd| R045Imp(@lEnd,Cabec1,Cabec2,Cabec3,limite,tamanho,cbCont,wnrel)},Titulo)

Return
 
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � R040IMP  � Autor � Robson Ramiro A. Olive� Data � 11.04.01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Chamada do Relatorio                                       ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QADR045                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function R045Imp(lEnd,Cabec1,Cabec2,Cabec3,limite,tamanho,cbCont,wnrel)

li    := 80
m_pag := 1
cbtxt := SPACE(10)

//��������������������������������������������������������������Ŀ
//� Monta Array para identificacao dos campos dos arquivos       �
//����������������������������������������������������������������

If Len(aReturn) > 8
	Mont_Dic(cString)
Else
	Mont_Array(cString)
Endif

ImpCadast(Cabec1,Cabec2,Cabec3,NomeProg,Tamanho,Limite,cString,@lEnd)

If li != 80
	Roda(cbcont,cbtxt,"M")
Endif

DbSelectArea("QU5")
Set Filter To
DbSetOrder(1)

If aReturn[5] = 1
   Set Printer To 
   DbCommitAll()
   OurSpool(wnrel)
Endif

Ms_Flush()

Return Nil
