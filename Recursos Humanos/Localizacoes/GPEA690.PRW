#Include "Protheus.ch"
#Include "Inkey.Ch"
#INCLUDE "GPEA690.CH"

/*/
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
�����������������������������������������������������������������������������Ŀ��
���Fun��o    � GPEA690      � Autor � Abel Ribeiro          � Data � 15/04/08 ���
�����������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastro de Grupos de Horas Extras para Agrupamento            ���
�����������������������������������������������������������������������������Ĵ��
���Sintaxe   � GPEA690()                                                      ���
�����������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAGPE - RH - PORTUGAL                                        ���
�����������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.                 ���
�����������������������������������������������������������������������������Ĵ��
���Programador � Data   �   BOPS   �  Motivo da Alteracao                     ���
�����������������������������������������������������������������������������Ĵ��
���Jonathan Glz�29/04/15|PCREQ-4256|Se realiza modificacion al fuente se      ���
���            �        �          �elimina la funcion AjustaSX3() con motivo ���
���            �        �          �de ajuste para las nueva estructuras de   ���
���            �        �          �version 12                                ���
������������������������������������������������������������������������������ٱ�
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
/*/
Function GPEA690()

Local aIndexRGF	:= {}		       //Variavel Para Filtro

Local cFiltraRGF			       //Variavel para filtro
Private bFiltraBrw := {|| Nil}		//Variavel para Filtro

/*
��������������������������������������������������������������Ŀ
� Define Array contendo as Rotinas a executar do programa      �
� ----------- Elementos contidos por dimensao ------------     �
� 1. Nome a aparecer no cabecalho                              �
� 2. Nome da Rotina associada                                  �
� 3. Usado pela rotina                                         �
� 4. Tipo de Transa��o a ser efetuada                          �
�    1 - Pesquisa e Posiciona em um Banco de Dados             �
�    2 - Simplesmente Mostra os Campos                         �
�    3 - Inclui registros no Bancos de Dados                   �
�    4 - Altera o registro corrente                            �
�    5 - Remove o registro corrente do Banco de Dados          �
����������������������������������������������������������������
*/
Private aRotina := MenuDef() // ajuste para versao 9.12 - chamada da funcao MenuDef() que contem aRotina

/*
��������������������������������������������������������������Ŀ
� Define o cabecalho da tela de atualizacoes                   �
����������������������������������������������������������������*/
Private cCadastro := OemToAnsi(STR0006)  //"Cadastro de Grupos

/*
������������������������������������������������������������������������Ŀ
� Inicializa o filtro utilizando a funcao FilBrowse                      �
��������������������������������������������������������������������������*/
cFiltraRh := CHKRH("GPEA690","RGF","1")
bFiltraBrw 	:= {|| FilBrowse("RGF",@aIndexRGF,@cFiltraRH) }
Eval(bFiltraBrw)

/*
��������������������������������������������������������������Ŀ
� Faz a Carga Inicial da tabela RGF                            �
����������������������������������������������������������������*/
CargaIni()
//��������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE                                  �
//����������������������������������������������������������������
mBrowse(06,01,22,75,"RGF",,,,,,fCriaCor() )

/*
������������������������������������������������������������������������Ŀ
� Deleta o filtro utilizando a funcao FilBrowse                     	 �
��������������������������������������������������������������������������*/
EndFilBrw("RGF",aIndexRGF)

Return( Nil )

/*
�����������������������������������������������������������������������Ŀ
�Fun��o    �Gpea690Del 	�Autor�ABEL RIBEIRO       � Data �15/04/2008�
�����������������������������������������������������������������������Ĵ
�Descri��o �Deletar Registro do Cadastro Grupos Horas Extras            �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �< Vide Parametros Firmais >									�
�����������������������������������������������������������������������Ĵ
� Uso      �GPEA690                                                    �
�����������������������������������������������������������������������Ĵ
� Retorno  �NIL															�
�����������������������������������������������������������������������Ĵ
�Parametros�< Vide Parametros Formais >									�
�������������������������������������������������������������������������*/
Function Gpe690Del( cAlias , nReg , nOpcx )

Local aArea		:= GetArea()
Local uRet		:= NIL

Private cFilAux	:= ""
/*
�������������������������������������������������������������Ŀ
� Executa a Delecao   										  �
���������������������������������������������������������������*/
uRet := AxDeleta( cAlias , nReg , nOpcx,,,,,,,, )

RestArea( aArea )

Return( uRet )
/*
�����������������������������������������������������������������������Ŀ
�Fun��o    �Gpe690Mnt� Autor �Abel Ribeiro           � Data �15/04/08  �
�����������������������������������������������������������������������Ĵ
�Descri��o �Rotina de Manutencao nas opcoes Do Menu                     �
�          �                                                            �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �Gpe690Mnt( cAlias , nReg , nOpc )							�
�����������������������������������������������������������������������Ĵ
�Parametros�cAlias = Alias do arquivo                                   �
�          �nReg   = Numero do registro                                 �
�          �nOpc   = Numero da opcao selecionada                        �
�����������������������������������������������������������������������Ĵ
� Uso      �Gpe690()	                                                �
�������������������������������������������������������������������������*/
Function Gpe690Mnt( cAlias , nReg , nOpc )
Local aAlter  := {}
Local aHeader := {}


// Preencho os arrays de campos do SRV para mostrar na enchoice
aHeader	:= ( cAlias )->( GdMontaHeader( cAlias ) )
aEval(aHeader,{|cCpo| aAdd(aAlter, cCpo[2])})

// Preencho os arrays de campos do RGF para mostrar na enchoice

If nOpc == 2 // Visualizar
	AxVisual(cAlias,nReg,2,,,,,,,,)
ElseIf nOpc == 4 // Alterar
	AxAltera(cAlias,nReg,4,aAlter,aAlter,,,"Gpe690TudOk()",,,,,,,,,,)
ElseIf nOpc == 3 // Incluir
	AxInclui(cAlias,nReg,3,aAlter,,aAlter,"Gpe690TudOk()",,,,,,,,,,)
EndIf

Return(NIL)

/*
�����������������������������������������������������������������������Ŀ
�Fun��o    � MenuDef		�Autor� Abel Ribeiro      � Data �15/04/08  �
�����������������������������������������������������������������������Ĵ
�Descri��o �Isola opcoes de menu para que as opcoes da rotina possam    �
�          �ser lidas pelas bibliotecas Framework da Versao 9.12 .      �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �< Vide Parametros Formais >									�
�����������������������������������������������������������������������Ĵ
� Uso      �GPEA690                                                     �
�����������������������������������������������������������������������Ĵ
� Retorno  �aRotina														�
�����������������������������������������������������������������������Ĵ
�Parametros�< Vide Parametros Formais >									�
�������������������������������������������������������������������������*/
Static Function MenuDef()

 Local aRotina := {;
						{ STR0001 , "PESQBRW"		, 0 , 1 , , .F.} ,;	//"Pesquisar"
						{ STR0002 , "Gpe690Mnt"	, 0 , 2 } ,;	//"Visualizar"
						{ STR0003 , "Gpe690Mnt"	, 0 , 3 } ,;	//"Incluir"
						{ STR0004 , "Gpe690Mnt"	, 0 , 4 } ,;	//"Alterar"
						{ STR0005 , "Gpe690Del"	, 0 , 5 }  ;	//"Excluir"
					 }
Return aRotina

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � fCriaCor �Autor  � Equipe RH          � Data �  30/06/10   ���
�������������������������������������������������������������������������͹��
���Desc.     � Cria array com as cores a serem apresentadas no browse     ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SIGAGPE                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function fCriaCor()
Local aCores	:=	{ ;
					{ "RGF->RGF_TPCOD=='1'" , 'BR_AZUL' } , ;
					{ "RGF->RGF_TPCOD=='2'" , 'BR_VERDE' } ;
					}
Return(aCores)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Gpe690Leg �Autor  � Equipe RH          � Data �  30/06/10   ���
�������������������������������������������������������������������������͹��
���Desc.     � Apresenta Legenda                                          ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SIGAGPE                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Gpe690Leg()

Local aLegenda	:= {}
Local aSvKeys	:= GetKeys()

aLegenda := {;
				{ "BR_AZUL"  , OemToAnsi( STR0013 ) } ,; //"Definido Pelo Sistema"
				{ "BR_VERDE" , OemToAnsi( STR0014 ) }  ; //"Definido Pelo Usuario"
			}

BrwLegenda(	cCadastro ,	STR0012 , aLegenda )			 //"Legenda do Cadastro de Grupo de Verbas"

RestKeys( aSvKeys )
Return( NIL )

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Gpe690TudOk�Autor � Equipe RH          � Data �  30/06/10   ���
�������������������������������������������������������������������������͹��
���Desc.     � Faz as validacoes necessarias                              ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SIGAGPE                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Gpe690TudOk( )
Local lTudoOK := .T.

If Empty(M->RGF_CODIGO)
	MsgInfo( OemToAnsi(STR0015), OemToAnsi(STR0007) ) //"Existe campo em branco e que deve ser preenchido !" ### "Aten��o !!!"
 	lTudoOK := .F.
EndIf
If lTudoOK .And. Empty(M->RGF_DESCRI)
	MsgInfo( OemToAnsi(STR0015), OemToAnsi(STR0007) ) //"Existe campo em branco e que deve ser preenchido !" ### "Aten��o !!!"
 	lTudoOK := .F.
EndIf
If lTudoOK .And. Empty(M->RGF_CODVER)
	MsgInfo( OemToAnsi(STR0015), OemToAnsi(STR0007) ) //"Existe campo em branco e que deve ser preenchido !" ### "Aten��o !!!"
 	lTudoOK := .F.
EndIf
Return lTudoOK


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � CargaIni �Autor  � Equipe RH          � Data �  30/06/10   ���
�������������������������������������������������������������������������͹��
���Desc.     � Faz a carga inicial da tabela                              ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SIGAGPE                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function CargaIni()
Local nX
Local aTabela	:= {}

DbSelectArea("RGF")
DbGoTop()

aAdd(aTabela,{xFilial("RGF"),"1","000001","Contrib Tarea Diferencial","   ","   "})

For nX := 1 to Len(aTabela)
	If !dbSeek(aTabela[nX,1]+aTabela[nX,2]+aTabela[nX,3],.F.)
		RecLock("RGF",.T.)
		RGF->RGF_FILIAL	:= aTabela[nX,1]
		RGF->RGF_TPCOD	:= aTabela[nX,2]
		RGF->RGF_CODIGO	:= aTabela[nX,3]
		RGF->RGF_DESCRI	:= aTabela[nX,4]
		RGF->RGF_CODVER	:= aTabela[nX,5]
		RGF->RGF_BASVER	:= aTabela[nX,6]
		MsUnLock("RGF")
	EndIf
Next nX

DbGoTop()
Return
