#INCLUDE "PROTHEUS.CH"
#INCLUDE "MATA512.CH"
#INCLUDE "FWMVCDEF.CH"

/*/                
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MATA512   � Autor � Sergio S. Fuzinaka    � Data � 14.12.05 ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Rotina de Expedicao - Inclusao e/ou alteracao de Transporta-���
���          �ra e Veiculo na Nota Fiscal de Saida                        ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function MATA512

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
Private aRotina	:= MenuDef()

//��������������������������������������������������������������Ŀ
//� Define o cabecalho da tela de atualizacoes                   �
//����������������������������������������������������������������
Private cCadastro	:= OemtoAnsi(STR0004)         //"Expedicao"         

dbSelectArea("SF2")
dbSetOrder(1)
MsSeek(xFilial("SF2"))
mBrowse(6,1,22,75,"SF2")

Return Nil

/*/                
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �A512Manut � Autor � Sergio S. Fuzinaka    � Data � 14.12.05 ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Inclusao e/ou alteracao de Transportadora e Veiculo         ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function A512Manut()

Local aArea			:= GetArea()
Local aTitles		:= {OemtoAnsi(STR0005)} //"Nota Fiscal"
Local nCntFor		:= 0
Local nOpc			:= 0
Local lVeiculo		:= (SF2->(FieldPos("F2_VEICUL1"))>0 .And. SF2->(FieldPos("F2_VEICUL2"))>0 .And. SF2->(FieldPos("F2_VEICUL3"))>0)
Local cTransp		:= ""
Local cVeicul1		:= ""
Local cVeicul2		:= ""
Local cVeicul3		:= ""
Local oDlg
Local oFolder
Local oList
Local lM512Agr		:= ExistBlock("M512AGRV")
Local lIntGFE   	:= SuperGetMv("MV_INTGFE",,.F.)
Local lIntGFEDir 	:= SuperGetMv("MV_INTGFE2",,"2") == "1"
Local lRet			:= .T.
Local aStruModel	:= {}   
Local aFieldValue	:= {}                 
Local aRecnoSF2 	:= {}
Local bSeekSF2		:= NIL
Local cCarga     	:= ""
Local cSeqCarga		:= ""
Local nI  			:= 0
Local aRetGFE		:= {.T.,""}	
Local oModel      	:= NIL

Private aHeader		:= {}
Private aCols	   	:= {}
Private oTransp
Private oVeicul1
Private oVeicul2
Private oVeicul3
Private N

If lVeiculo

	If !Empty(SF2->F2_CARGA)
		cCarga 	 := SF2->F2_CARGA
		cSeqCarga := SF2->F2_SEQCAR	
	EndIf

	If lRet
		RegToMemory("SF2",.F.)
		
		cTransp	:= Posicione("SA4",1,xFilial("SA4")+SF2->F2_TRANSP,"A4_NOME")
		cVeicul1:= Posicione("DA3",1,xFilial("DA3")+SF2->F2_VEICUL1,"DA3_DESC")
		cVeicul2:= Posicione("DA3",1,xFilial("DA3")+SF2->F2_VEICUL2,"DA3_DESC")	
		cVeicul3:= Posicione("DA3",1,xFilial("DA3")+SF2->F2_VEICUL3,"DA3_DESC")
	
		//������������������������������������������������������Ŀ
		//� Montagem do aHeader                                  �
		//��������������������������������������������������������
		dbSelectArea("SX3")
		dbSetOrder(1)
		If dbSeek("SF2")
			While ( !Eof() .And. (SX3->X3_ARQUIVO == "SF2") )
				If ( X3USO(SX3->X3_USADO) .And. ;
					AllTrim(SX3->X3_CAMPO) $ "F2_DOC|F2_SERIE|F2_CLIENTE|F2_LOJA|F2_EMISSAO" .And. ;
					cNivel >= SX3->X3_NIVEL )
					
					Aadd(aHeader,{ TRIM(X3Titulo()),;
						SX3->X3_CAMPO,;
						SX3->X3_PICTURE,;
						SX3->X3_TAMANHO,;
						SX3->X3_DECIMAL,;
						SX3->X3_VALID,;
						SX3->X3_USADO,;
						SX3->X3_TIPO,;
						SX3->X3_ARQUIVO,;
						SX3->X3_CONTEXT } )
				EndIf
				dbSelectArea("SX3")
				dbSkip()
			EndDo
		EndIf                     
		
		//������������������������������������������������������Ŀ
		//� Montagem do aCols                                    �
		//��������������������������������������������������������
		dbSelectArea("SF2")
		
		If !Empty(SF2->F2_CARGA)
			SF2->(dbSetOrder(5))
			bSeekSF2  := { || SF2->(dbSeek(xFilial('SF2')+cCarga)) }
			bWhileSF2 := { || SF2->(!Eof()) .And. xFilial('SF2')+SF2->F2_CARGA == xFilial('SF2')+cCarga }
		Else
			bWhileSF2 := { || .T. }			
		EndIf
	
		If bSeekSF2 != NIL
			Eval(bSeekSF2)
		EndIf
		
		While Eval(bWhileSF2)
			AADD(aCols,Array(Len(aHeader)))
			For nCntFor:=1 To Len(aHeader)
				If ( aHeader[nCntFor,10] <>  "V" )
					aCols[Len(aCols)][nCntFor] := FieldGet(FieldPos(aHeader[nCntFor,2]))
				Else			
					aCols[Len(aCols)][nCntFor] := CriaVar(aHeader[nCntFor,2])
				EndIf
			Next nCntFor
			AAdd(aRecnoSF2,SF2->(Recno()))
			If Empty(cCarga)
				Exit
			EndIf
			SF2->(dbSkip())		
		EndDo
		
		//���������������������������������������������Ŀ
		//�Monta a tela de exibicao dos dados           �
		//�����������������������������������������������
		DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006) FROM 09,00 TO 28.2,80 //"Manutencao de Transportadoras e Veiculos"
		
		oFolder	:= TFolder():New(001,001,aTitles,{"HEADER"},oDlg,,,, .T., .F.,315,141)
		oList 	:= TWBrowse():New( 5, 1, 310, 42,,{aHeader[1,1],aHeader[2,1],aHeader[3,1],aHeader[4,1],aHeader[5,1]},{30,90,50,30,50},oFolder:aDialogs[1],,,,,,,,,,,,.F.,,.T.,,.F.,,, ) //"Numero"###"Serie"###"Cliente"###"Loja"###"DT Emissao"
		oList:SetArray(aCols)
		oList:bLine	:= {|| {aCols[oList:nAt][1],aCols[oList:nAt][2],aCols[oList:nAt][3],aCols[oList:nAt][4],aCols[oList:nAt][5]}}
		oList:lAutoEdit	:= .F.
		
		@ 051,005 SAY RetTitle("F2_TRANSP")		SIZE 40,10 PIXEL OF oFolder:aDialogs[1]
		@ 066,005 SAY RetTitle("F2_VEICUL1")	SIZE 40,10 PIXEL OF oFolder:aDialogs[1]
		@ 081,005 SAY RetTitle("F2_VEICUL2")	SIZE 40,10 PIXEL OF oFolder:aDialogs[1]	
		@ 095,005 SAY RetTitle("F2_VEICUL3")	SIZE 40,10 PIXEL OF oFolder:aDialogs[1]		
		
		@ 051,050 MSGET M->F2_TRANSP	PICTURE PesqPict("SF2","F2_TRANSP")		F3 CpoRetF3("F2_TRANSP")	SIZE 50,07 PIXEL OF oFolder:aDialogs[1] VALID IIf(Vazio(),(cTransp:="",.T.),.F.) .Or. (ExistCpo("SA4").And.A512Disp(@cTransp))
		@ 066,050 MSGET M->F2_VEICUL1	PICTURE PesqPict("SF2","F2_VEICUL1")	F3 CpoRetF3("F2_VEICUL1")	SIZE 50,07 PIXEL OF oFolder:aDialogs[1] VALID IIf(Vazio(),(cVeicul1:="",.T.),.F.) .Or. (ExistCpo("DA3").And.A512Disp(@cVeicul1))
		@ 081,050 MSGET M->F2_VEICUL2	PICTURE PesqPict("SF2","F2_VEICUL2")	F3 CpoRetF3("F2_VEICUL2")	SIZE 50,07 PIXEL OF oFolder:aDialogs[1] VALID IIf(Vazio(),(cVeicul2:="",.T.),.F.) .Or. (ExistCpo("DA3").And.A512Disp(@cVeicul2))	
		@ 095,050 MSGET M->F2_VEICUL3	PICTURE PesqPict("SF2","F2_VEICUL3")	F3 CpoRetF3("F2_VEICUL3")	SIZE 50,07 PIXEL OF oFolder:aDialogs[1] VALID IIf(Vazio(),(cVeicul3:="",.T.),.F.) .Or. (ExistCpo("DA3").And.A512Disp(@cVeicul3))	
		
		@ 051,105 MSGET oTransp		VAR cTransp		PICTURE PesqPict("SF2","F2_TRANSP")		WHEN .F. SIZE 150,07 PIXEL OF oFolder:aDialogs[1]
		@ 066,105 MSGET oVeicul1	VAR cVeicul1	PICTURE PesqPict("SF2","F2_VEICUL1")	WHEN .F. SIZE 150,07 PIXEL OF oFolder:aDialogs[1]
		@ 081,105 MSGET oVeicul2	VAR cVeicul2	PICTURE PesqPict("SF2","F2_VEICUL2")	WHEN .F. SIZE 150,07 PIXEL OF oFolder:aDialogs[1]	
		@ 095,105 MSGET oVeicul3	VAR cVeicul3	PICTURE PesqPict("SF2","F2_VEICUL3")	WHEN .F. SIZE 150,07 PIXEL OF oFolder:aDialogs[1]		
		
		@ 110,005 TO 111,310 PIXEL OF oFolder:aDialogs[1]
		@ 113,225 BUTTON OemToAnsi(STR0008)	SIZE 040,13 FONT oFolder:aDialogs[1]:oFont ACTION (nOpc:=1,oDlg:End())	OF oFolder:aDialogs[1] PIXEL	//"Confirmar"
		@ 113,270 BUTTON OemToAnsi(STR0007)	SIZE 040,13 FONT oFolder:aDialogs[1]:oFont ACTION oDlg:End()			OF oFolder:aDialogs[1] PIXEL	//"Cancelar"
		
		ACTIVATE MSDIALOG oDlg CENTERED
		
		If nOpc == 1                                                   
			
			// Fun��o para realizar as altera��es das informa��es do SIGAGFE
			aRetGFE := AtuInfoFrt(aRecnoSF2[1],{{1, "GWN_CDTRP", M->F2_TRANSP},{2, "GWN_CDTPVC", Posicione("DA3", 1, xFilial("DA3") + M->F2_VEICUL1, "DA3_TIPVEI"), M->F2_VEICUL1},{3, "GWN_PLACAD", Posicione("DA3", 1, xFilial("DA3") + M->F2_VEICUL1, "DA3_PLACA")}})
			
			If aRetGFE[1] == .F.
				MsgStop(aRetGFE[2],"Ocorreu uma valida��o impeditiva no m�dulo Gest�o de Frete Embarcador. Verifique a mensagem abaixo: ")
			Else
				For nI := 1 To Len(aRecnoSF2)	
					SF2->(dbGoTo(aRecnoSF2[nI]))
			  		
			  		RecLock("SF2",.F.)
				  		SF2->F2_TRANSP	:= M->F2_TRANSP
				  		SF2->F2_VEICUL1	:= M->F2_VEICUL1
				  		SF2->F2_VEICUL2	:= M->F2_VEICUL2
				  		SF2->F2_VEICUL3	:= M->F2_VEICUL3
			 		SF2->(MsUnlock())
					
					MaEnvEAI(,,4,"MATA461")
				Next nI			
			EndIf
		EndIf
		
		//������������������������������������������������������������������������Ŀ
		//� Ponto de entrada antes da gravacao da manutencao                       �
		//��������������������������������������������������������������������������
		If lM512Agr
			ExecBlock("M512AGRV",.F.,.F.)
		EndIf
	EndIf		
Else
	MsgAlert(OemToAnsi(STR0009))                                            	
Endif

RestArea(aArea)

Return Nil

/*/                
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �A512Disp  � Autor � Sergio S. Fuzinaka    � Data � 14.12.05 ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Display do Campo                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function A512Disp(cCampo)

Local aArea	:= GetArea()
Local cCpo	:= ReadVar()

Do Case
	Case cCpo == "M->F2_TRANSP"
		cCampo := Posicione("SA4",1,xFilial("SA4")+M->F2_TRANSP,"A4_NOME")
		oTransp:Refresh()
	Case cCpo == "M->F2_VEICUL1"
		cCampo	:= Posicione("DA3",1,xFilial("DA3")+M->F2_VEICUL1,"DA3_DESC")
		oVeicul1:Refresh()	
	Case cCpo == "M->F2_VEICUL2"
		cCampo	:= Posicione("DA3",1,xFilial("DA3")+M->F2_VEICUL2,"DA3_DESC")
		oVeicul2:Refresh()	
	Otherwise
		cCampo	:= Posicione("DA3",1,xFilial("DA3")+M->F2_VEICUL3,"DA3_DESC")
		oVeicul3:Refresh()	
EndCase

RestArea(aArea)

Return(.T.)

/*/
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Marco Bianchi         � Data �12/05/2008���
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

Private aRotina	:= {	{ STR0001 ,"AxPesqui"  , 0 , 1,0,.F.},;	//"Pesquisar"
						{ STR0002 ,"AxVisual"  , 0 , 2,0,NIL},;	//"Visualizar"
						{ STR0003 ,"A512Manut" , 0 , 4,0,NIL} }	//"Manutencao"



If ExistBlock("MA512MNU")
	ExecBlock("MA512MNU",.F.,.F.)
EndIf

Return(aRotina)