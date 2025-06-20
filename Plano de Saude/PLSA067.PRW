
#INCLUDE "PLSA067.ch"
#INCLUDE "PLSMGER.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PLSA067   �Autor  �Rafael M. Quadrotti � Data �  02/05/04   ���
�������������������������������������������������������������������������͹��
���Desc.     �Cadastro de mensagens para Extratos de boleto, Ficha de     ���
���          �compensacao e carteirinha.                                  ���
���          �Alias: BH1 E BH2                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP6 Pls                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function  PLSA067()

Private aRotina := MenuDef()

dbSelectArea("BH1")
mBrowse(,,,,"BH1")

Return (.T.)                       


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �Pl067Mes  �Autor  �Rafael M. Quadrotti � Data �  05/02/04   ���
�������������������������������������������������������������������������͹��
���Desc.     �Interface principal com os dados das mensagens.             ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �Plano de Saude. Cadastro de mensagens.                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function PL067Mes(cAlias, nReg, nOpc)
Local   aAC       := { STR0006,STR0007 }  //"Abandona"###"Confirma"
Local   oEnchoice
Local   oDlg
Local   aSize     := MsAdvSize(.T.,.F.,400)	//Array com as dimensoes da tela
Local   aInfo	  := {}					  		//Array temporario para a criacao dos objetos da tela
Local   aObjects  := {}					  		//Array temporario para a criacao dos objetos da tela
Local   aPosObj   := {}							//Array com as posicoes dos objetos da tela
Local   aVetTrab  := {}

Private  aCols	  := {}
Private  oGet
Private  aHeader  := {}
Private aTela[0][0]
Private aGets[0][0]


//�������������������������������������������������������������Ŀ
//�Atualiza as variaveis de memoria para os campos do CABECALHO �
//���������������������������������������������������������������
If (nOpc == 3)
	RegToMemory("BH1",.T.)
Else
	RegToMemory("BH1",.F.)
Endif

//���������������������������������������������������������������������Ŀ
//� Calcula as dimensoes da enchoiece e getdados                        �
//�����������������������������������������������������������������������
aObjects := {}

AAdd( aObjects, { 100, 100, .T., .T. } )
AAdd( aObjects, { 100, 100, .T., .T. } )

aInfo       := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
aPosObj     := MsObjSize( aInfo, aObjects,  , .F. )

Store Header "BH2" TO aHeader For .T.
If nOpc == K_Incluir
   Store COLS Blank "BH2" TO aCols FROM aHeader
Else
   BH2->(DbSetOrder(1))
   If !BH2->(DbSeek(xFilial("BH2")+M->BH1_CODIGO))
      Store COLS Blank "BH2" TO aCols FROM aHeader
   Else
      Store COLS "BH2" TO aCols FROM aHeader VETTRAB aVetTrab While  xFilial("BH2") == BH2->BH2_FILIAL .And.;
      																 M->BH1_CODIGO == BH2->BH2_CODIGO 
   Endif
Endif

//��������������������
//�Definicao da tela.�
//��������������������
DEFINE MSDIALOG oDlg TITLE STR0008 FROM  aSize[7], 0 TO aSize[6],aSize[5]  PIXEL OF oMainWnd  //"Cadastro de mensagens"
	oEnchoice:= MsMGet():New("BH1", nReg, nOpc, aAC,"AC","",,aPosObj[1],,,,,,,,.T.,.F.,"aTela",.T.)
	oGet := TPLSBrw():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,4],aPosObj[2,3],nil  ,oDlg,nil,nil,nil,nil,nil,.T.,nil  ,.T.   ,nil   ,aHeader,aCols,.F.,"BH2",nOpc,STR0008,nil,nil,nil,aVetTrab,Nil,Nil,Nil,{||Pls067Vl()},nil) //"Cadastro de Mensagens"
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(	oDlg   ,{||IIf(Pl067Grava(nOpc,oGet),oDlg:End(),"")},; //OK
													{||Iif(nOpc==3,RollBackSX8(),""),oDlg:End()},,)//CANCELA


Return(.T.)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �Pl067Inc  �Autor  �Rafael M. Quadrotti � Data �  05/02/04   ���
�������������������������������������������������������������������������͹��
���Desc.     �Inclusao de mensagens.                                      ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �Plano de Saude. Cadastro de mensagens.                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function PL067Grava(nOpc,oGet)
Local aChave  := {{"BH2_CODIGO",M->BH1_CODIGO}}

If (nOpc == 2) //Se for visualizacao nao grava nada e fecha a Tela
	Return(.T.)
Endif

//Valida os campos obrigatorios
If !Obrigatorio(aGets,aTela)
	Return(.F.)
	
ElseIf Empty(M->BH1_CODINT) .OR. Empty(M->BH1_TIPO) // Valida o codig da operadora e o tipo.
	Help(" ",1,"PLS067VLD") // Os campos C�digo da operadora e tipo devem ser informados.
	Return(.F.)
EndIf

BEGIN TRANSACTION
	BH1->(PluptEnc("BH1",nOpc))
	oGet:Grava(aChave)
END TRANSACTION

Return(.T.)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �Pls067Vl()�Autor  �Rafael M. Quadrotti � Data �  05/02/04   ���
�������������������������������������������������������������������������͹��
���Desc.     �Validacao da digitacao da linha para cartoes magneticos.    ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �Plano de Saude. Cadastro de mensagens.                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Pls067Vl()
Local lRet := .T.

If (M->BH1_TIPO$"3;4")
	If Len(ALLTRIM(M->BH2_MSG01))>30  
	    Help(" ",1,"PLS067CAR")// Para mensagens de Cart�o magnetico o limite maximo para digitaco eh de 30 caracteres.
		lRet := .F.
	Else
		lRet := .T.	
	EndIf
EndIf


Return (lRet)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Darcio R. Sporl       � Data �26/12/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Utilizacao de menu Funcional                               ���
���          �                                                            ���
���          �                                                            ���
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
Private aRotina := {	{ STR0001,	"AxPesqui", 0, 1, 0, .F.},;	//"Pesquisar" //"Pesquisar"
											{ STR0002,	"PL067Mes", 0, 2, 0, Nil},;		//"Visualizar" //"Visualizar"
											{ STR0003,	"PL067Mes", 0, 3, 0, Nil},;		//"Incluir" //"Incluir"
											{ STR0004,	"PL067Mes", 0, 4, 2, Nil},;		//"Alterar" //"Alterar"
											{ STR0005,	"PL067Mes", 0, 5, 1, Nil}}		//"Excluir" //"Excluir"
Return(aRotina)