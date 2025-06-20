#INCLUDE "HSPAHM37.ch"
#INCLUDE "PROTHEUS.ch"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HSPAHM37  � Autor � MARCELO JOSE       � Data �  11/02/05   ���
�������������������������������������������������������������������������͹��
���Descricao � NUTRICAO E DIETETICA                                       ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP6 IDE                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
 Function HSPAHM37()

 Private cCadastro   := STR0001 //"NUTRICAO E DIETETICA"
 Private aRotina     := MenuDef()
 Private cDelFunc    := ".T." /* Validacao para a exclusao. Pode-se utilizar ExecBlock */
 Private cString     := "GAV"
 Private cGcsTipLoc  := "2/3/8" // UTILIZADO PARA FILTRAR O TIPO DE SETOR NA CONSULTA F3 DO SX1
 Private cFilM37     := ""
 Private cPerg       := "HSPM37" 
 Private cCodLoc     := ""
 
 bKeyF12             := SetKey(VK_F12, {|| FS_FilM37(.T.) } )
 aCor := {{"GAV->GAV_STATUS == '1'"                              , "BR_MARROM"  },; // reservado
          {"GAV->GAV_STATUS == '5'"                              , "BR_CINZA"    }} // ocupado

 If FS_FilM37(.F.)
  mBrowse( 6,1,22,75,cString,,,,,,aCor,,,,,,,,cFilM37)
 EndIf 
 
Return(NIL) 
/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
��      ATIVA FILTRO DO BROWSE                                             ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function FS_FilM37(lSetFilter)
 Local oObjMBrw     := ""
 Local lRet         := .T.
 
 Default lSetFilter := .T.
 
 oObjMBrw           := IIf(lSetFilter, GetObjBrow(), Nil) 

 If (lRet := Pergunte(cPerg,.T.))
 
  cFilM37 :=  "(GAV_STATUS = '1' OR GAV_STATUS = '5')" + ;
            IIF(Empty(MV_PAR01), "", " AND GAV_CODLOC = '" +MV_PAR01+ "'" ) 
 Endif

 If lSetFilter .And. lRet
  SetMBTopFilter("GAV", cFilM37)
  oObjMBrw:GoTop()
  oObjMBrw:Refresh()
 EndIf
 cCodLoc := MV_PAR01
Return(lRet)  

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�� Legenda da movimentacao                                                 ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function HS_M37Leg()
 BrwLegenda(cCadastro, STR0004,{{"BR_CINZA"   , STR0007} ,; //"Legenda"###"Uso Reservado"
                                  {"BR_MARROM"  , STR0008      } }) //"Ocupado"

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
��      chama etiqueta da nutricao e dietetica                             ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
FUNCTION HS_ETIQDIE()
 HSPAHR71(ALLTRIM(GETMV("MV_ETIQDIE")),{1,GAV->GAV_REGATE,GAV->GAV_REGATE} )
Return(Nil)


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MenuDef  � Autor � Tiago Bandeira        � Data � 10/06/07 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Defini��o do aRotina (Menu funcional)                      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � MenuDef()                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function MenuDef()
//��������������������������������������������������������������Ŀ
//� Define Array contendo as Rotinas a executar do programa      �
//� ----------- Elementos contidos por dimensao ------------     �
//� 1. Nome a aparecer no cabecalho                              �
//� 2. Nome da Rotina associada                                  �
//� 3. Usado pela rotina                                         �
//� 4. Tipo de Transa��o a ser efetuada                          �
//�    1 - Pesquisa e Posiciona em um Banco de Dados             �
//�    2 - Simplesmente Mostra os Campos                         �
//�    3 - Gera arquivo TXT para exportacao                      �
//�    4 - Recebe arquivo TXT                                    �
//����������������������������������������������������������������
Local aRotina
Local cFunDieta := ""
Local cFunEtiq  := ""
 
If ExistBlock("HSAHM37REL")
	cFunDieta := "'" + ExecBlock("HSAHM37REL", .F., .F.) + "'"
Else
	cFunDieta := '"HSPAHRC4(cCodLoc)"'
EndIf  

If ExistBlock("HSAHM37ETQ")
	cFunEtiq := "'" + ExecBlock("HSAHM37ETQ", .F., .F.) + "'"
Else
	cFunEtiq := '"HS_ETIQDIE()"'
EndIf  

aRotina :=	{{STR0002, "axPesqui"		, 0, 1, 0, nil},; //"Pesquisar"
                     {STR0003, "HSPAHM33"		, 0, 4, 0, nil},; //"Dieta"
                     {STR0005, &cFunDieta		, 0, 3, 0, nil},; //"MAPA DE DIETAS"
                     {STR0006, &cFunEtiq		, 0, 3, 0, nil},; //"Etiquetas"
                     {STR0004, "HS_m37leg"		, 0, 1, 0, nil}}  //"Legenda"
Return(aRotina)