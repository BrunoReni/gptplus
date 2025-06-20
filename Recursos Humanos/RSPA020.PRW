#INCLUDE "Protheus.ch"
#INCLUDE "RSPA020.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � RSPA020  � Autor � Cristina Ogura        � Data � 24.11.97 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastro de Cursos                                         ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � Void GRHA020(void)                                         ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � RSPA020                                                    ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���Cecilia Car.�29/07/14�TQENN4�Incluido o fonte da 11 para a 12 e efetua-���
���            �        �      �da a limpeza.                             ���
���Luis Artuso �01/10/15�TTAOBW� Ajuste para validar os registros antes da���
���            �        �      � exclus�o                                 ���  
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function RSPA020

Private aRotina := MenuDef() // ajuste para versao 9.12 - chamada da funcao MenuDef() que contem aRotina

//��������������������������������������������������������������Ŀ
//� Define o cabecalho da tela de atualizacoes                   �
//����������������������������������������������������������������
PRIVATE cCadastro :=OemtoAnsi(STR0006) //"Cadastro de Cursos"
PRIVATE cDelfunc                                                        

//��������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE                                  �
//����������������������������������������������������������������
mBrowse( 6, 1,22,75,"SQT")

Return

/*                                	
�����������������������������������������������������������������������Ŀ
�Fun��o    � MenuDef		�Autor�  Luiz Gustavo     � Data �27/12/2006�
�����������������������������������������������������������������������Ĵ
�Descri��o �Isola opcoes de menu para que as opcoes da rotina possam    �
�          �ser lidas pelas bibliotecas Framework da Versao 9.12 .      �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �< Vide Parametros Formais >									�
�����������������������������������������������������������������������Ĵ
� Uso      �RSPA020                                                     �
�����������������������������������������������������������������������Ĵ
� Retorno  �aRotina														�
�����������������������������������������������������������������������Ĵ
�Parametros�< Vide Parametros Formais >									�
�������������������������������������������������������������������������*/   

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
//�    3 - Inclui registros no Bancos de Dados                   �
//�    4 - Altera o registro corrente                            �
//�    5 - Remove o registro corrente do Banco de Dados          �
//����������������������������������������������������������������
 Local aRotina :={   	{ STR0001,"AxPesqui",0,1, , .F.},;  	//"Pesquisar"
						{ STR0002,"AxVisual",0,2},;   			//"Visualizar"
						{ STR0003,"AxInclui",0,3},;  			//"Incluir"
						{ STR0004,"AxAltera",0,4},;  			//"Alterar"
						{ STR0005,"RSP020Rot",0,5,3},;			//"Excluir"   
						{ STR0007,"MsDocument", 0, 4} }			//"Conhecimento"

Return aRotina

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � RSP020Rot� Autor �Henrique Velloso		� Data � 05/08/2015 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Rotina de processamento das Op��es do Menu                   ���
���������������������������������������������������������������������������Ĵ��
���Retorno   � Nenhum                                                       ���
���������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                       ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function RSP020Rot()
Local lChkDelOk := .F.

RstCheckSx9() //Garante que os valores de aCheckSX9 e nCheckSx9 sejam reinicializados.

lChkDelOk  := ChkDelRegs("SQT"	                ,;	//Alias do Arquivo Principal
						 ("SQT")->( Recno() )   ,;	//Registro do Arquivo Principal
						 5                      ,;	//Opcao para a AxDeleta
						 xFilial("SQT")         ,;	//Filial do Arquivo principal para Delecao
						 GetMemVar( "QT_CURSO" ),;	//Chave do Arquivo Principal para Delecao
						 NIL                    ,;	//Array contendo informacoes dos arquivos a serem pesquisados
						 NIL                    ,;	//Mensagem para MsgYesNo
						 NIL                    ,;	//Titulo do Log de Delecao
						 NIL                    ,;	//Mensagem para o corpo do Log
						 .T.                    ,;	//Se executa AxDeleta
						 .T.                    ,;	//Se deve Mostrar o Log
						 NIL                    ,;	//Array com o Log de Exclusao
						 NIL                    ,;	//Array com o Titulo do Log
						 NIL                    ,;	//Bloco para Posicionamento no Arquivo
						 NIL                    ,;	//Bloco para a Condicao While
						 NIL                    ,;	//Bloco para Skip/Loop no While
						 .T.                    ,;	//Verifica os Relacionamentos no SX9
						 Nil                    ,;	//Alias que nao deverao ser Verificados no SX9
						 NIL                    ,;	//Se faz uma checagem soft
						 .F.                     ;  //Se esta executando rotina automatica
						)
						
Return( lChkDelOk  )
