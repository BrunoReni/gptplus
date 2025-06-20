#Include "TRMA080.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � TRMA080  � Autor � Cristina Ogura        � Data � 30.03.99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastro dos Sinonimos dos Cursos                          ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TRMA080                                                    ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Avoid                                                      ���
�������������������������������������������������������������������������Ĵ��
���Uso       � TRMA080                                                    ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���21.07.2014�Cecilia Car.   �TPZSOX�Incluido o fonte da 11 para a 12 e   ���
���          �               �      �efetuada a limpeza.                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function TRMA080

LOCAL cFiltra			//Variavel para filtro
LOCAL aIndFil	:= {}	//Variavel Para Filtro

Private bFiltraBrw := {|| Nil}		//Variavel para Filtro

//��������������������������������������������������������������Ŀ
//� Define Array contendo as Rotinas a executar do programa      �
//� ----------- Elementos contidos por dimensao ------------     �
//� 1. Nome a aparecer no cabecalho                              �
//� 2. Nome da Rotina associada                                  �
//� 3. Usado pela rotina                                         �
//� 4. Tipo de Transa��o a ser efetuada                          �
//�    1 - Pesquisa e Posiciona em um Banco de Dados             �
//�    2 - Simplesmente Mostra os Campos                         �
//�    3 - Inclui registros no Bancos de Dados                   �
//�    4 - Altera o registro corrente                            �
//�    5 - Remove o registro corrente do Banco de Dados          �
//����������������������������������������������������������������
Private aRotina := MenuDef() // ajuste para versao 9.12 - chamada da funcao MenuDef() que contem aRotina

//��������������������������������������������������������������Ŀ
//� Define o cabecalho da tela de atualizacoes                   �
//����������������������������������������������������������������
Private cCadastro := OemtoAnsi(STR0006)	//"Cadastro de Sinonimo dos Cursos"
Private cDelFunc	:= Nil //N�o apagar

//������������������������������������������������������������������������Ŀ
//� Inicializa o filtro utilizando a funcao FilBrowse                      �
//��������������������������������������������������������������������������
dbSelectArea("RA9")
dbSetOrder(1)

cFiltra 	:= CHKRH(FunName(),"RA9","1")
bFiltraBrw 	:= {|| FilBrowse("RA9",@aIndFil,@cFiltra) }
Eval(bFiltraBrw)

//��������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE                                  �
//����������������������������������������������������������������
dbSelectArea("RA9")
dbGoTop()

mBrowse(6, 1, 22, 75, "RA9")

//������������������������������������������������������������������������Ŀ
//� Deleta o filtro utilizando a funcao FilBrowse                     	   �
//��������������������������������������������������������������������������
EndFilBrw("RA9",aIndFil)

dbSelectArea("RA9")
dbSetOrder(1)

Return Nil

/*                                	
�����������������������������������������������������������������������Ŀ
�Fun��o    � MenuDef		�Autor�  Luiz Gustavo     � Data �22/12/2006�
�����������������������������������������������������������������������Ĵ
�Descri��o �Isola opcoes de menu para que as opcoes da rotina possam    �
�          �ser lidas pelas bibliotecas Framework da Versao 9.12 .      �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �< Vide Parametros Formais >									�
�����������������������������������������������������������������������Ĵ
� Uso      �TRMA080                                                     �
�����������������������������������������������������������������������Ĵ
� Retorno  �aRotina														�
�����������������������������������������������������������������������Ĵ
�Parametros�< Vide Parametros Formais >									�
�������������������������������������������������������������������������*/   

Static Function MenuDef()

 Local aRotina :=  { 	{ STR0001,'PesqBrw', 0, 1,,.F.}, ;		//"Pesquisar"
						{ STR0002,'AxVisual', 0, 2}, ;		//"Visualizar"
						{ STR0003,'AxInclui', 0, 3}, ;		//"Incluir"
						{ STR0004,'AxAltera', 0, 4}, ;		//"Alterar"
						{ STR0005,'AxDeleta', 0, 5,3} }	//"Excluir"

Return aRotina