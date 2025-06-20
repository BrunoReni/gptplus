#INCLUDE "Protheus.ch"
#INCLUDE "Parmtype.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � PLSA997	� Autor �   Leonardo Candido    � Data �17.02.2012���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Cadastro de CBO				                              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � 				                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �                                                            ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���            �        �      �                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function PLSA997()
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
Private aRotina   := MenuDef()
Private cCadastro := Fundesc()//"Cadastro de CBO"

mBrowse( 6, 1,22,75,"B0X")

Return


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �  CBOINC  � Autor � Leonardo Candido   � Data �  17/02/2012 ���
�������������������������������������������������������������������������͹��
���Desc.     � Validacao da Inclusao do CBO                               ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � PLSA997                     		                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function PLSA997INC(cAlias,nReg,nOpc)

RegToMemory( cAlias, .T., .F. )
//AxInclui -   ( [ cAlias ] [ nReg ] [ nOpc ] [ aAcho ] [ cFunc ] [ aCpos ] [ cTudoOk ] [ lF3 ] [ cTransact ] [ aButtons ] [ aParam ] [ aAuto ] [ lVirtual ] [ lMaximized ] [ cTela ] [ lPanelFin ] [ oFather ] [ aDim ] [ uArea ] ) --> nOpca 
nOpca := AxInclui(cAlias,nReg,nOpc,,,,"TudoOk(cAlias,nReg,nOpc)",,,)

Return 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �  CBODEL  � Autor � Leonardo Candido   � Data �  17/02/2012 ���
�������������������������������������������������������������������������͹��
���Desc.     � Validacao da Inclusao do CBO                               ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � PLSA997                 		                              ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function PLSA997DEL(cAlias,nReg,nOpc)

Local aParam := { {|| ""},; // AADD( aParam,  {|| U_Before()} ) - antes da abertura
                  {|| TudoOK(cAlias,nReg,nOpc,B0X->B0X_CODCBO) },; // AADD( aParam,  { || TudoOK() } )- ao licar no botao ok
                  {|| ""},;	//AADD( aParam,  {|| U_Transaction() } ) - durante a transacao
                  {|| ""}}	//AADD( aParam,  {|| U_Fim() } ) - termino da transacao */

RegToMemory( cAlias, .T., .F. )
//AxDeleta - Tela padr�o para deletar registro ( [ cAlias ] [ nReg ] [ nOpc ] [ cTransact ] [ aCpos ] [ aButtons ] [ aParam ] [ aAuto ] [ lMaximized ] [ cTela ] [ aAcho ] [ lPanelFin ] [ oFather ] [ aDim ] ) --> nOpca

nOpca := AxDeleta(cAlias,nReg,nOpc,,,,aParam,,,)
//nOpca := AxDeleta("SA1",SA1->(Recno()),5,"U_Transaction",aCpos,aButtons,aParam,,.T.,,,,,)           

Return 
  

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �  TudoOk	� Autor � Leonardo Candido   � Data �  17/02/12   ���
�������������������������������������������������������������������������͹��
���Desc.     �  Validacao da gravacao de Orcamento DAF                    ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � PLSA997	                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function TudoOk(cAlias,nReg,nOpc,cCbo)

Local lRet 	   := .T.
Local cCodCbo  := ""
Local lAchou   := .F.

If !Empty(M->B0X_CODCBO)
	cCodCbo := M->B0X_CODCBO
Else
	cCodCbo := cCbo 
EndIf

dbSelectArea("B0X")
B0X->( dbSetOrder(1) ) // B0X_FILIAL+B0X_CODCBO

If nOpc == 3 .Or. nOpc == 4 
	If B0X->(dbSeek( xFilial("B0X") + cCodCbo))
		MsgInfo(OemToAnsi("C�digo CBO j� cadastrado na base de dados."))
		lRet:= .F.
	EndIf
ElseIf nOpc == 5
    dbSelectArea("BAQ")
    dbSetOrder(6) //BAQ_FILIAL + BAQ_CBOS
    lAchou := BAQ->(dbSeek( xFilial("BAQ") + cCodCbo))
    If lAchou
       MsgInfo(OemToAnsi("C�digo CBO n�o pode ser exclu�do pois j� foi utilizado no cadastro de especialidades(BAQ)."))
       lRet := .F.
    EndIf   
EndIf	

Return lRet

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor �   Leonardo Candido    � Data �17/02/2012���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Utilizacao de menu Funcional                               ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Array com opcoes da rotina.                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Parametros do array a Rotina:                               ���
���          �1. Nome a aparecer no cabecalho                             ���
���          �2. Nome da Rotina associada                                 ���
���          �3. Reservado                                                ���
���          �4. Tipo de Transa��o a ser efetuada:                        ���
���          �		1 - Pesquisa e Posiciona em um Banco de Dados         ���
���          �    2 - Simplesmente Mostra os Campos                       ���
���          �    3 - Inclui registros no Bancos de Dados                 ���
���          �    4 - Altera o registro corrente                          ���
���          �    5 - Remove o registro corrente do Banco de Dados        ���
���          �5. Nivel de acesso                                          ���
���          �6. Habilita Menu Funcional                                  ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef()


Local aRotina	:= {}

AADD( aRotina, {"Pesquisar"		,"AxPesqui"   , 0 , 1, 0, .F.	} )
AADD( aRotina, {"Visualizar"	,"AxVisual"   , 0 , 2, 0, Nil	} )
AADD( aRotina, {"Incluir"		,"PLSA997INC" , 0 , 3, 0, Nil	} )
AADD( aRotina, {"Alterar"		,"AxAltera"   , 0 , 4, 0, Nil	} )
AADD( aRotina, {"Excluir"		,"PLSA997DEL" , 0 , 5, 3, Nil	} )


	
    	aadd(aRotina, {"Vinculo TISS" , "MsgRun('',,{||PLVINCTIS('B0X',B0X->B0X_CODCBO, 1)})", 0 ,})
		aadd(aRotina, {"Excluir Vinculo TISS" , "MsgRun('',,{||PLVINCTIS('B0X',B0X->B0X_CODCBO, 0)})", 0 ,})                  




Return aRotina

//	AxCadastro("SA1", "Clientes", "U_DelOk()", "U_COK()", aRotAdic, bPre, bOK, bTTS, bNoTTS, , , aButtons, , ) 
