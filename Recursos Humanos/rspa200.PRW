#include "Protheus.ch"
#Include "font.ch"
#Include "colors.ch"
#include "RSPA200.CH"


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � RSPA200  � Autor � Emerson Grassi Rocha  � Data � 29/06/01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Gerar Testes Aleatorios                                    ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � RSPA200()                                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � RSPA200                                                    ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���Cecilia Car.�29/07/14�TQENN4�Incluido o fonte da 11 para a 12 e efetua-���
���            �        �      �da a limpeza.                             ���
���Raquel Hager�08/06/16�TVGR01�Ajuste para gera��o do conte�do nItem de  ���
���            �        �      �acordo com o tamanho do campo QQ_ITEM.    ���
��������������������������������������������������������������������������ٱ� 
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function RSPA200

LOCAL cFiltra		:= ""			//Variavel para filtro 
LOCAL cFiltraSQW	:= ""			//Variavel para filtro

Private aIndFil		:= {}			//Variavel Para Filtro
Private bFiltraBrw 	:= {|| Nil}			//Variavel para Filtro
Private cCadastro	:= OemtoAnsi(STR0003) 	//"Gerar Testes Aleatorios"

Private aRotina := MenuDef() // ajuste para versao 9.12 - chamada da funcao MenuDef() que contem aRotina

//������������������������������������������������������������������������Ŀ
//� Inicializa o filtro utilizando a funcao FilBrowse                      �
//��������������������������������������������������������������������������
dbSelectArea("SQW")
dbSetOrder(1)

cFiltra 	:= CHKRH(FunName(),"SQW","1")
cFiltraSQW 	:= "QW_SEQ == '01'"          
If !Empty(cFiltra)
	cFiltraSQW := cFiltraSQW + ".And." + cFiltra
EndIf

bFiltraBrw 	:= {|| FilBrowse("SQW",@aIndFil,@cFiltraSQW) }
Eval(bFiltraBrw)

//��������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE                                  �
//����������������������������������������������������������������
dbSelectArea("SQW")
dbGoTop()

mBrowse( 6, 1,22,75,"SQW")

//������������������������������������������������������������������������Ŀ
//� Deleta o filtro utilizando a funcao FilBrowse                     	   �
//��������������������������������������������������������������������������
EndFilBrw("SQW",aIndFil)

dbSelectArea("SQW")
dbSetOrder(1)

Return(Nil)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � RS200Gera � Autor � Emerson Grassi Rocha � Data � 29/06/01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Gera modelos de testes que sera executado pelo candidato.  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � RS200Gera(ExpC1,ExpN1,ExpN2)                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � RSPA200                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Rs200Gera(cAlias,nReg,nOpcx)
Local aSaveArea := GetArea()
Local cCod 		:= ""		
Local cDesc		:= ""
Local cDuracao	:= ""
Local nQtdTeste := 0  

Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}

//������������������������������������������������������������������������Ŀ
//� Deleta o filtro utilizando a funcao FilBrowse                     	   �
//��������������������������������������������������������������������������
EndFilBrw("SQW",aIndFil)
aIndFil := {}
dbGoto(nReg)

dbSelectArea("SQW")
If Eof()
	Help("",1,"Rs200Vazio")		// Arquivo de Modelos Vazio.

	//������������������������������������������������������������������������Ŀ
	//� Inicializa o filtro utilizando a funcao FilBrowse                      �
	//��������������������������������������������������������������������������
	Eval(bFiltraBrw)
	dbGoto(nReg)

	RestArea(aSaveArea)      
	
	Return Nil
EndIf

cCod	:= SQW->QW_MODELO
cDesc	:= SQW->QW_DESCRIC
cDuracao:= SQW->QW_DURACAO

/*
��������������������������������������������������������������Ŀ
� Monta as Dimensoes dos Objetos         					   �
����������������������������������������������������������������*/
aAdvSize		:= MsAdvSize()
aAdvSize[5]�:=�(aAdvSize[5]/100) *67
aAdvSize[6]�:=� (aAdvSize[6]/100) *28.5
aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 0 , 0 }					 
aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords ) 

DEFINE MSDIALOG oDlgMain TITLE cCadastro FROM aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] OF oMainWnd  PIXEL
                                                        //3.50.67.3.50
	@ aObjSize[1,1]+8, aObjSize[1,2]+3 SAY OemtoAnsi(STR0004) SIZE 55,7 OF oDlgMain PIXEL //"Codigo do Modelo:"
	@ aObjSize[1,1]+8, aObjSize[1,2]+50 GET cCod	WHEN .F.	SIZE 10,7 OF oDlgMain PIXEL
	@ aObjSize[1,1]+8, aObjSize[1,2]+67 GET cDesc	WHEN .F. 	PICTURE PesqPict("SQW","QW_DESCRIC") SIZE 180,7 OF oDlgMain PIXEL
	@ aObjSize[1,1]+23, aObjSize[1,2]+3 SAY OemtoAnsi(STR0007) SIZE 55,7 OF oDlgMain PIXEL // "Qt.Testes:" 
	@ aObjSize[1,1]+23, aObjSize[1,2]+50 GET nQtdTeste WHEN .T.	PICTURE "999" SIZE 10,7 OF oDlgMain PIXEL
		
ACTIVATE MSDIALOG oDlgMain CENTERED ON INIT (EnchoiceBar(oDlgMain,{||nOpca:=1,MsgRun(STR0006,"",{||Rs200Grava(cCod,cDuracao,nQtdTeste)}),oDlgMain:End() },{|| nOpca := 2,oDlgMain:End()})) //"Aguarde...Gerando Testes aleatorios"

//������������������������������������������������������������������������Ŀ
//� Inicializa o filtro utilizando a funcao FilBrowse                      �
//��������������������������������������������������������������������������
Eval(bFiltraBrw)
dbGoto(nReg)

RestArea(aSaveArea)      

Return  Nil

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Rs200Grava� Autor � Emerson Grassi Rocha  � Data � 29/06/01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Grava os registros referente ao Modelo de Teste.            ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 : Alias                                              ���
���          � ExpN1 : Registro                                           ���
���          � ExpN2 : Opcao                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �RSPA200                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function RS200Grava(cCod,cDuracao,nQtdTeste)  

Local cTeste	:= ""
Local cItem		:= ""		
Local cQuestao  := ""
Local nItem  	:= 0
Local nQuest 	:= 0
Local nMaximo   := 0
Local nAleat    := 0
Local nx        := 0
Local nz        := 0
Local nTamQqIt	:= TamSX3("QQ_ITEM")[1]
Local aQuest    := {}
Local aQueAtu	:= {}
Local lGrava	:= .F.
                    
For nz := 1 to nQtdTeste	// Qtde. de Testes a gerar.   

	cTeste 		:= GetSxeNum("SQQ","QQ_TESTE")
	cItem		:= "00"
	nItem  		:= 0
	
	dbSelectArea("SQW")
	dbSetOrder(1)
	dbSeek(xFilial("SQW")+cCod)
	While !Eof() .And. (xFilial("SQW")+cCod) == (xFilial("SQW")+SQW->QW_MODELO)
    
		//����������������������������������������������������������������������������Ŀ
		//� Verifica quantidade de Questoes de acordo com as especificacoes do Modelo. �
		//������������������������������������������������������������������������������
		cQuestao  	:= ""
		nMaximo 	:= 0
		nAleat    	:= 0
		nx        	:= 0
		nQuest 		:= 0
		aQuest 		:= {} 
		aQueAtu 	:= {}
			
		dbSelectArea("SQO")
		dbSetOrder(2)      
		dbSeek(xFilial("SQO")+SQW->QW_TIPO+SQW->QW_AREA+SQW->QW_TOPICO)
		While xFilial("SQO")+SQW->QW_TIPO+SQW->QW_AREA+SQW->QW_TOPICO  ==;
					  xFilial("SQO")+SQO->QO_TIPO+SQO->QO_AREA+SQO->QO_TOPICO

			If SQO->QO_NIVEL >= SQW->QW_NIVELDE  .And. SQO->QO_NIVEL <= SQW->QW_NIVELAT .And.;
		       SQO->QO_DATA  >= SQW->QW_DTQUEDE  .And. SQO->QO_DATA  <= SQW->QW_DTQUEAT  .And.;	//Questoes entre o intervalo estabelecido
			   SQO->QO_ATIVO <> "2"	//Somente Questoes Ativas		   
				Aadd(aQuest,Val(QO_QUESTAO))
				nQuest++						
			EndIf
			dbSkip()
		EndDo
	
		//����������������������������������������������������������������������������Ŀ
		//� Se no arquivo tiver mais questoes que o solicitado, busca aleatoriamente.  �
		//������������������������������������������������������������������������������	
		
		dbSelectArea("SQW")
		If nQuest > SQW->QW_FREQ       
			aQueAtu 	:= {}
			For nx := 1 to QW_FREQ  
				While .T.   
					nAleat := Round(TrmAleat(nQuest),0) 
					If nAleat > 0
						nAleat := aQuest[nAleat]    
						If Ascan(aQueAtu,{|x| x == nAleat }) == 0 
							Aadd(aQueAtu,nAleat)
							Exit					
						EndIf
					EndIf
				EndDo
			Next nx           
			
		//����������������������������������������������������������������������������Ŀ
		//� Se no arquivo nao tiver questoes suficientes, utiliza apenas as existentes.�
		//������������������������������������������������������������������������������	
		Else
		    aQueAtu := Aclone(aQuest)
		EndIf
	         
	    Begin Transaction	// Transacao para cada linha do Modelo (Frequencia)
			For nx := 1 to Len(aQueAtu)	
		
			    nItem++
			    cItem 	:= StrZero(nItem, nTamQqIt )
			    cQuestao:= StrZero(aQueAtu[nx],3)
		    
				RecLock("SQQ",.T.,.T.)  
		
					Replace SQQ->QQ_FILIAL 	WITH xFilial("SQQ")
					Replace SQQ->QQ_TESTE 	WITH cTeste
					Replace SQQ->QQ_DESCRIC	WITH SQW->QW_DESCRIC
					Replace SQQ->QQ_ITEM	WITH cItem
					Replace SQQ->QQ_QUESTAO	WITH cQuestao
					Replace SQQ->QQ_AREA	WITH SQW->QW_AREA
					Replace SQQ->QQ_TOPICO	WITH SQW->QW_TOPICO
					Replace SQQ->QQ_DURACAO	WITH cDuracao
					Replace SQQ->QQ_TIPO	WITH SQW->QW_TIPO
		
				MsUnlock()   
				
		        lGrava := .T.
			Next nx
		End Transaction
	
		dbSelectArea("SQW")
		dbSkip()
	EndDo

	If nOpca == 1 .And. __lSX8 .And. lGrava
		ConfirmSX8()
	ElseIf (nOpca != 1 .Or. !lGrava).And. __lSX8 
		RollBackSX8()
	EndIf
	
Next nz

Return .t.

/*                                	
�����������������������������������������������������������������������Ŀ
�Fun��o    � MenuDef		�Autor�  Luiz Gustavo     � Data �09/01/2007�
�����������������������������������������������������������������������Ĵ
�Descri��o �Isola opcoes de menu para que as opcoes da rotina possam    �
�          �ser lidas pelas bibliotecas Framework da Versao 9.12 .      �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �< Vide Parametros Formais >									�
�����������������������������������������������������������������������Ĵ
� Uso      �RSPA200                                                     �
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
//�    6 - Alteracao sem inclusao de registro                    �
//����������������������������������������������������������������
Local aRotina := { 	{ STR0001	,"PesqBrw",  0 , 1,,.F.},;	//"Pesquisar"
						{ STR0002	,"RS200Gera", 0 , 2}}	//"Gerar"

Return aRotina