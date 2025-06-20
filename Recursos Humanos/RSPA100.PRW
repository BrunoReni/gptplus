#INCLUDE "PROTHEUS.CH"
#INCLUDE "RSPA100.CH"

Static lRSPA100Inc	:= ExistBlock('RSPA100INC')

/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Fun��o    � RSPA100  � Autor � Fernando Joly         � Data � 20.02.98    ���
����������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastro de Vagas                                             ���
����������������������������������������������������������������������������Ĵ��
���Sintaxe   � Clipper 5.3                                                   ���
����������������������������������������������������������������������������Ĵ��
���Parametros� Avoid                                                         ���
����������������������������������������������������������������������������Ĵ��
���Uso       � RSPA100                                                       ���
����������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.                ���
����������������������������������������������������������������������������Ĵ��
���Programador � Data   � REQ.   �  Motivo da Alteracao                      ���
����������������������������������������������������������������������������Ĵ��
���Cecilia C.  |31/03/14|315701     |Ajuste na integracao SIGAORG com modulos���
���            |        |           |SIGACSA, SIGATRM, SIGARSP, SIGAGPE.     ���
���Gustavo M.  |19/09/14|TQPLM1     |Ajuste para nao obrigar o preenchimento ���
���            |        |           |da data de fechamento.                  ���
���Mariana M.  |24/06/15|TSRWDM     |Criacao do PE RSP100EX                  ���
���Flavio Corr.|20/07/15|PCREQ-4161 |Ajuste para WorkArea admissao           ���
���Renan Borges|05/08/15|TRZVKM     |Ajuste para  verificar compartilhamento ���
���            |        |           |entre tabelas SQS, SRJ e SQ3.           ���
���Eduardo K.  |11/11/16|TWKUCS		|inclus�o do PE RSPA100INC               ���
���Marcelo F.  |22/02/17|MRH-3832   |Implementa��o de melhoria para tratar   ���
���            |        |           |novo campo de caracteristica/perfil vaga���
���Willian U.  |10/11/17|DRHPONTP-2033 |Ajuste para que ao excluir uma vaga, ���
���            |        |              |o sistema verifique corretamente se  ���
���            |        |              |h� rela��o entre a SQG e a SQS.      ���
�����������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������*/

Function RSPA100

Local aIndexSQS	:= {}
Local cSRJ		:= ""
Local cSQS		:= ""

//��������������������������������������������������������������Ŀ
//� Define Variaveis                                             �
//����������������������������������������������������������������
Private  aAC := { STR0001, STR0002 } //'Abandona'###'Confirma'
Private  aCRA:= { STR0002, STR0003, STR0001 } //'Confirma'###'Redigita'###'Abandona'

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
Private cCadastro := OemtoAnsi(STR0009) //'Cadastro de Vagas'
Private cDelfunc   
Private cFiltraSQS := ""

Private lIntRSP		:= GetMv("MV_IORGRSP", NIL, "0") == "1"

//��������������������������������������������������������������Ŀ
//� Consiste o Modo de Acesso dos Arquivos                       �
//����������������������������������������������������������������  
cSQS := FWModeAccess( "SQS", 1) + FWModeAccess( "SQS", 2) + FWModeAccess( "SQS", 3)
cSRJ := FWModeAccess( "SRJ", 1) + FWModeAccess( "SRJ", 2) + FWModeAccess( "SRJ", 3)

If cSRJ > cSQS
	//"O Modo de Acesso do relacionamento para a tabela de Vagas deve possuir um compartilhamento igual ou maior ao cadastro de Fun��es!"
	//"Altere o modo de acesso atraves do Configurador. Arquivos SQS e SRJ."
	MsgInfo( oEmToAnsi( STR0024 ) + CRLF + CRLF + oEmToAnsi( STR0025 ) )
	Return (.F.)
EndIf

//������������������������������������������������������������������������������������Ŀ
//�Ponto de Entrada para criar filtro para a tabela SQS                                �
//�Variaveis que podem ser Usadas                                                      �
//�cFiltraSQS = Filtro da tabela  									                   �
//��������������������������������������������������������������������������������������
If ExistBlock("RSP100FT")
   ExecBlock("RSP100FT",.F.,.F.)
Endif     

FilBrowse("SQS",@aIndexSQS,@cFiltraSQS) 

aColors:= {}
Aadd(aColors, {"SQS->QS_NRVAGA > SQS->QS_VAGAFEC","BR_VERDE",STR0011})
Aadd(aColors, {"SQS->QS_NRVAGA <= SQS->QS_VAGAFEC","BR_VERMELHO",STR0012})

aLegenda:= {}
Aadd(aLegenda,{"BR_VERDE",STR0011})  
Aadd(aLegenda,{"BR_VERMELHO",STR0012})

If ExistBlock("RSP100LG")
	ExecBlock("RSP100LG",.F.,.F.)
Endif     

//��������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE                                  �
//����������������������������������������������������������������
mBrowse(6, 1, 22, 75, 'SQS',,,,,,aColors,,,,,,,,,,,,, {|oBrowse|AT410BrwAct(oBrowse)} )

/*
������������������������������������������������������������������������Ŀ
� Deleta o filtro utilizando a funcao FilBrowse                     	 �
��������������������������������������������������������������������������*/
EndFilBrw( "SQS" , aIndexSQS )

Return Nil

Static Function AT410BrwAct(oBrowse)
          
Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � Rspa100LegBrw� Autor � Eduardo Ju        � Data � 22.12.04 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Retorna Legenda de Cores para a mBrowse                    ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � <Vide Parametros Formais>                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� <Vide Parametros Formais> 								  ���
�������������������������������������������������������������������������Ĵ��
���Uso		 � Rspa100  												  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function Rspa100LegBrw()

If ( Type( "cCadastro" ) == "U" )
	Private cCadastro := STR0010							//"Legenda"
EndIf

If ( Type("aLegenda") == "U")
	aLegenda	:= {}
	Aadd(aLegenda,{"BR_VERDE",STR0011})  
	Aadd(aLegenda,{"BR_VERMELHO",STR0012})
EndIf		


BrwLegenda(	OemToAnsi(cCadastro),OemToAnsi(STR0010)	,aLegenda)  

Return( .T. )


/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �RSP100Inc � Autor � Bruno Sobieski        � Data � 21.07.05 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de Incluisao de Vagas                             ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � RSP100Inc(ExpC1,ExpN1,ExpN2)                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Numero da opcao selecionada                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � RSPA100                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function RSP100Inc(cAlias,nReg,nOpc,xRotAuto)
Local nOpca			:=	0
Local aBut100		:= {}		//Array recebe retorno do PE
Local aRsp100Btn	:= {}		//Array do botoes
Local aRotAuto
Local aCampos 		:= {}

// Inclusao de botoes na toobar  
If ExistBlock("RSP100B1")
	aBut100:=ExecBlock("RSP100B1",.F.,.F.,{nOpc})
	If Valtype(aBut100)="A".AND.Len(aBut100)>=2 //Garante que tenha o icone do botao e a fun��o a ser executada
		aadd(aRsp100Btn,aBut100)
	EndIf	
EndIf	
dbSelectArea( cAlias )
PcoIniLan("000080")

RSP100Uso(@aCampos)
	
If xRotAuto <> NIL
	aRotAuto := aClone(xRotAuto)
Endif
	
nOpca := AxInclui(cAlias,nReg,nOpc,aCampos, , ,"RSP100Tok()",,"RSPPerfilVaga()",aRsp100Btn,,aRotAuto)

If nOpca == 1
	PcoDetLan("000080","01","RSPA100")
	PcoFinLan("000080")
Endif

PcoFreeBlq("000080")
Return

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �RSP100Uso � Autor � IP Rh Inovacao        � Data � 08.03.12 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Carrega os campos a serem apresentados na Enchoice         ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � RSP100Uso(ExpC1) 			                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Array com os campos a serem apresentados Enchoice  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � RSPA100                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function RSP100Uso(aCampos)
Local aArea 	:= GetArea()
Local lIntRSP	:= GetMv("MV_IORGRSP", NIL, "0") == "1" 
Local cNoFields	:= If( lIntRSP, "", "QS_POSTO,QS_FILPOST")
Local lAprovOp	:= SuperGetMv("MV_GSAPROV",.F.,"2")  == "1"

aCampos := {}

//Integra��o SIGATEC - M�dulo 28
If !lAprovOp
	cNoFields += ",QS_FILTFF,QS_CODTFF"
EndIf

SX3->(dbSetOrder(1))
If SX3->( dbSeek( "SQS" ) )
	While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == "SQS"
		If X3USO(SX3->X3_USADO) .AND. cNivel >= SX3->X3_NIVEL .And. !(alltrim(SX3->X3_CAMPO) $ cNoFields)
			aAdd( aCampos , AllTrim(SX3->X3_CAMPO) )
		Endif
		SX3->(dbSkip())
    Enddo
Endif
RestArea(aArea)

Return


/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �RSP100Tok � Autor � IP Rh Inovacao        � Data � 08.03.12 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valida��o do tudo ok                                       ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � RSP100Tok() 			                                       ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � RSPA100                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function RSP100Tok()
Local lRet := .T.
Local lIntRSP	:= GetMv("MV_IORGRSP", NIL, "0") == "1"
// Verifica se houver integracao entre ORG e RSP o campo RBT_FUNCAO deve ser obrigatorio
If lIntRSP .And. EMPTY(M->QS_POSTO)
	Alert(STR0017 + " " + AllTrim(TITSX3("QS_POSTO")[1]) + " " + STR0018) // "O campo" ### "dever� ser preenchido quando a Integra��o entre os m�dulos SIGAORG e SIGARSP est� ativada."
 	lRet	:= .f.
Endif

If lRet
	lRet := PcoVldLan('000080','01','RSPA100')
Endif

If lRet
	If !Empty(M->QS_TESTE) .AND. (Empty(M->QS_PONTOS) .OR. Empty(M->QS_AUTOM))
		Alert(STR0019 + " '" + AllTrim(TITSX3("QS_PONTOS")[1]) + "' " + STR0020 + " '" + AllTrim(TITSX3("QS_AUTOM")[1]) + "' " + STR0021 + " " + AllTrim(TITSX3("QS_TESTE")[1]) + " " + STR0022)//"Os Campos" ### ou ### "dever�o estar preenchidos, quando o campo" ### "for selecionado."  
		lRet	:= .F.
	EndIf
EndIf
If !Empty(M->QS_FILRESP) .AND. !Empty(M->QS_MATRESP)
	aArea 	:= GetArea()
	dbSelectArea("SRA")
	dbSetOrder(1)
	If !DbSeek(M->QS_FILRESP+M->QS_MATRESP)
	Alert(STR0023)//"A filial e matricula n�o foi localizada. Selecione a matricula do respons�vel atrav�s da op��o F3, para que a filial e a matricula seja inserida corretamente."
		lRet	:= .F.
	EndIf		
   		RestArea(aArea)
Endif

If ((lRet) .AND. (lRSPA100Inc))
	lRet := ExecBlock('RSPA100INC',.F.,.F.)
EndIf

Return lRet



/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �RSP100Tok � Autor � IP Rh Inovacao        � Data � 08.03.12 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valida��o do tudo ok                                       ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � RSP100Tok() 			                                       ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � RSPA100                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function RSPPerfilVaga()

	If (SQS->(ColumnPos("QS_CODPERF")) > 0) 
		If !Empty(M->QS_PERFIL)
			MSMM(QS_CODPERF,,,M->QS_PERFIL,1,,,"SQS","QS_CODPERF")
		Else	
			MSMM(QS_CODPERF,,,,2)
	    EndIf
	EndIf    	                                                        

Return .T.


/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �RSP100Exc � Autor � Bruno Sobieski        � Data � 21.07.05 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de Exclusao  de Vagas                             ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � RSP100Exc(ExpC1,ExpN1,ExpN2)                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Numero da opcao selecionada                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � RSPA100                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function RSP100Exc(cAlias,nReg,nOpc) 
Local nOpca			:= 0
Local aBut100		:= {}		//Array recebe retorno do PE
Local aRsp100Btn	:= {}		//Array do botoes
Local aCampos 		:= {}
Local lRet			:= .T.

// Inclusao de botoes na toobar  
If ExistBlock("RSP100B1")
	aBut100:=ExecBlock("RSP100B1",.F.,.F.,{nOpc})
	If Valtype(aBut100)="A".AND.Len(aBut100)>=2 //Garante que tenha o icone do botao e a fun��o a ser executada
		aadd(aRsp100Btn,aBut100)
	EndIf	
EndIf	

RSP100Uso(@aCampos)

dbSelectArea( cAlias )
If RSP100ChkDel(cAlias,nReg,nOpc)
	If ExistBlock("RSP100EX")
		lRet := ExecBlock("RSP100EX",.F.,.F.)
	EndIf
	If lRet 
		nOpca := AxDeleta(cAlias,nReg,nOpc,,aCampos,aRsp100Btn)
		If nOpca == 2
			PcoIniLan("000080")
			PcoDetLan("000080","01","RSPA100",.T.)
			PcoFinLan("000080")
		Endif
	EndIf
EndIf
Return

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �RSP100Alt � Autor � Gustavo Henrique      � Data � 13.01.06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de alteracao de Vagas                             ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � RSP100Alt(ExpC1,ExpN1,ExpN2)                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Numero da opcao selecionada                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � RSPA100                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function RSP100Alt(cAlias,nReg,nOpc,xRotAuto)
Local nOpca	:=	0
Local aBut100		:= {}		//Array recebe retorno do PE
Local aRsp100Btn	:= {}		//Array do botoes
Local aRotAuto
Local aCampos 		:= {}

// Inclusao de botoes na toobar  
If ExistBlock("RSP100B1")
	aBut100:=ExecBlock("RSP100B1",.F.,.F.,{nOpc})
	If Valtype(aBut100)="A".AND.Len(aBut100)>=2 //Garante que tenha o icone do botao e a fun��o a ser executada
		aadd(aRsp100Btn,aBut100)
	EndIf	
EndIf	

dbSelectArea( cAlias )
PcoIniLan("000080")

RSP100Uso(@aCampos)

If xRotAuto <> NIL
	aRotAuto := aClone(xRotAuto)
Endif

nOpca := AxAltera(cAlias,nReg,nOpc,aCampos , , , ,"RSP100Tok()","RSPPerfilVaga()",,aRsp100Btn,,aRotAuto)

If nOpca == 1
	PcoDetLan("000080","01","RSPA100")
	PcoFinLan("000080")
Endif
PcoFreeBlq("000080")
Return

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �RSP100ChkDel� Autor � Emerson Grassi Rocha� Data � 24/04/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Checagem de arquivos antes da Exclusao de Vagas	          ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � RSP100Exc(ExpC1,ExpN1,ExpN2)                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Numero da opcao selecionada                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � RSPA100                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function RSP100ChkDel( cAlias , nReg , nOpcx )

Local aArea			:= GetArea()
Local aAreas			:= {}
Local aNotSx9Check	:= {}

Local cFilSQS
Local cVaga
Local cMsgYesNo
Local cTitLog
Local cAliasSQG

Local nAreas

Local uRet

//SQD (Agenda)
aAdd( aAreas , Array( 03 ) )
nAreas := Len( aAreas )
aAreas[nAreas,01] := SQD->( GetArea() )
aAreas[nAreas,02] := Array( 2 )
				aAreas[nAreas,02,01] := "QD_FILIAL"
				aAreas[nAreas,02,02] := "QD_VAGA"
aAreas[nAreas,03] := RetOrdem( "SQD" , "QD_FILIAL+QD_VAGA" , .T. )



cMsgYesNo := OemToAnsi(STR0013)	//"O Sistema agora ira efetuar a verificacao para ver se a vaga selecionada para" 
cMsgYesNo += CRLF
cMsgYesNo += OemToAnsi(STR0014)	//"exclusao esta sendo utilizada. A verifica��o pode ser demorada !!"
cMsgYesNo += CRLF
cMsgYesNo += CRLF
cMsgYesNo += OemToAnsi(STR0015)	//"Confirma a exclus�o da Vaga?"

cTitLog := OemToAnsi(STR0016)	//"Log de Ocorrencias na Exclusao de Vagas"

( cAlias )->( MsGoto( nReg ) )
cFilSQS	:= xFilial( "SQS" )
cVaga	:= SQS->QS_VAGA

aAdd( aNotSx9Check , "SQG" )

uRet := ChkDelRegs(	cAlias		,;	//01 -> Alias de Dominio
					nReg			,;	//02 -> Registro do Dominio
					nOpcx			,;	//03 -> Opcao para a AxDeleta
					cFilSQS		,;	//04 -> Filial do do Dominio
					cVaga			,;	//05 -> Chave do do Dominio
					aAreas			,;	//06 -> Array contendo informacoes dos arquivos a serem pesquisados
					cMsgYesNo		,;	//07 -> Mensagem para MsgYesNo
					cTitLog		,;	//08 -> Titulo do Log de Delecao
					NIL				,;	//09 -> Mensagem para o corpo do Log
					.F.				,;	//10 -> Se executa AxDeleta
					.T.				,;	//11 -> Se deve Mostrar o Log
									,;	//12 -> Array com o Log de Exclusao
									,;	//13 -> Array com o Titulo do Log
									,;	//14 -> Bloco para Posicionamento no Arquivo
									,;	//15 -> Bloco para a Condicao While
									,;	//16 -> Bloco para Skip/Loop no While
									,;	//17 -> Verifica os Relacionamentos no SX9
					aNotSx9Check	 ;	//18 -> Alias que nao deverao ser Verificados no SX9
		)

If(uRet == .T.)
	cAliasSQG := GetNextAlias()
	
	cQryFields  := "QG_FILIAL, QG_CURRIC, "
	cAreaChkDel := "SQG"
	cQueryWhere := "QG_FILMAT = '" + cFilSQS + "' AND QG_VAGA = '" + cVaga + "'"
	
	cQuery := "SELECT "
	cQuery += cQryFields
	cQuery += "R_E_C_N_O_ RECNO "
	cQuery += " FROM "
	cQuery += RetSqlName(cAreaChkDel)
	cQuery += " WHERE "
	cQuery += cQueryWhere
	cQuery += " AND D_E_L_E_T_= ' '"
	cQuery := ChangeQuery(cQuery)
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(NIL,NIL,cQuery),cAliasSQG,.F.,.T.)
	
	If (cAliasSQG)->(!Eof())
		uRet := .F.
		MsgAlert(STR0027)
	EndIf
	
	(cAliasSQG)->(dbclosearea()) 
EndIf
	
RestArea( aArea )

Return( uRet )
             
/*                                	
�����������������������������������������������������������������������Ŀ
�Fun��o    � MenuDef		�Autor�  Luiz Gustavo     � Data �27/12/2006�
�����������������������������������������������������������������������Ĵ
�Descri��o �Isola opcoes de menu para que as opcoes da rotina possam    �
�          �ser lidas pelas bibliotecas Framework da Versao 9.12 .      �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �< Vide Parametros Formais >									�
�����������������������������������������������������������������������Ĵ
� Uso      �RSPA100                                                     �
�����������������������������������������������������������������������Ĵ
� Retorno  �aRotina														�
�����������������������������������������������������������������������Ĵ
�Parametros�< Vide Parametros Formais >									�
�������������������������������������������������������������������������*/   

Static Function MenuDef()

 Private aRotina :=  { 	{ STR0004, 'AxPesqui'		, 0, 1,,.F.}		, ; //'Pesquisar'
					  	{ STR0005, 'RSP100VIS'		, 0, 2}		, ; //'Visualizar'
 						{ STR0006, 'RSP100INC'		, 0, 3}		, ; //'Incluir'
						{ STR0007, 'RSP100ALT'		, 0, 4}		, ; //'Alterar'
						{ STR0008, 'RSP100Exc'		, 0, 5,3}	,;  //'Excluir'
						{ STR0010, 'Rspa100LegBrw'	, 0 , 4 , ,.F.	}	 } 	//"Legenda"
              
//������������������������������������������������������������������������������������Ŀ
//�Ponto de Entrada para incluir outras opcoes no Menu.                                �
//�Variaveis que podem ser Usadas                                                      �
//�aRotina = Opcoes menu 												               �
//��������������������������������������������������������������������������������������
If ExistBlock("RSP100ME")
   ExecBlock("RSP100ME",.F.,.F.)
Endif

Return aRotina

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �RSP100Vis � Autor � IP RH Inovacao        � Data � 08.03.12 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de Visualizacao de Vagas                          ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � RSP100Vis(ExpC1,ExpN1,ExpN2)                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Numero da opcao selecionada                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � RSPA100                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function RSP100Vis(cAlias,nReg,nOpc)
Local aCampos 		:= {}

RSP100Uso(@aCampos)
dbSelectArea( cAlias )
AxVisual(cAlias,nReg,nOpc,aCampos)

Return

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �RSP100Val � Autor � Emerson Campos        � Data � 19/02/13 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valida��o do campo QS_MATRESP                              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � RSP100Val()                                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros� N�o se aplica                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SX3                                                        ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function RSP100Val()
Local lRet := .T.
    If Empty(M->QS_MATRESP)
		M->QS_FILRESP := ''
	Else
		dbSelectArea('SRA')
		
		If !dbSeek(M->QS_FILRESP + M->QS_MATRESP)
			M->QS_FILRESP := '' 
			lRet	:= .F.
		EndIf
		If Empty(M->QS_FILRESP)
			M->QS_FILRESP := SRA->RA_FILIAL	
		EndIf
	EndIf
Return lRet 

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � fChkDtIni� Autor � Claudinei Soares      � Data � 21.05.13 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Checa a Data de Inicio      								  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � Generico 												  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������/*/
Function fChDtIni()
Local dData := &(Alltrim(ReadVar()))
Local lFim	:=	.F.

If( IsMemVar( "QS_DTFECH" ) )
	lFim	:=	!(EMPTY(M->QS_DTFECH)) .AND. (dData > M->QS_DTFECH)
Else	
	lFim	:=	!(EMPTY(SQS->QS_DTFECH)) .AND. (dData > SQS->QS_DTFECH)
EndIf

If (lFim) .OR. (Empty(dData))
	Help(" ",1,".DTABERT.")
	Return (.F.)
Endif
Return (.T.)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � fChkDtFim� Autor � Claudinei Soares      � Data � 21.05.13 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Checa a Data de Inicio      								  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � Generico 												  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������/*/
Function fChDtFim()
Local dData := &(Alltrim(ReadVar()))

If  !Empty(dData) .And. dData < (Iif(IsMemVar( "QS_DTABERT" ), M->QS_DTABERT, SQS->QS_DTABERT))
	Help(" ",1,".DTFECH.")
	Return (.F.)
Endif
Return (.T.)
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �fChVagaIni� Autor � Claudinei Soares      � Data � 21.05.13 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Checa a Quantidade de Vagas Abertas      				  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � Generico 												  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������/*/
Function fChVagaIni()
Local nVaga := &(Alltrim(ReadVar()))

If 	nVaga < (Iif(IsMemVar( "QS_VAGAFEC" ), M->QS_VAGAFEC, SQS->QS_VAGAFEC))
	Help(" ",1,".VAGABERT.")
	Return (.F.)
Endif
Return (.T.)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �fChVagaFim� Autor � Claudinei Soares      � Data � 21.05.13 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Checa a Quantidade de Vagas Finalizadas					  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � Generico 												  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������/*/
Function fChVagaFim()
Local nVaga := &(Alltrim(ReadVar()))

If 	nVaga > (Iif(IsMemVar( "QS_NRVAGA" ), M->QS_NRVAGA, SQS->QS_NRVAGA))
	Help(" ",1,".VAGAFECH.")
	Return (.F.)
Endif
Return (.T.)      

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �fIntOrgRsp� Autor � IP RH Inovacao        � Data � 27.06.13 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Checa se existe integracao SIGAORG e SIGARSP 			  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � Generico 												  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������/*/
Function fIntOrgRsp()
Local lIntegra := .F.

lIntegra := GetMv("MV_IORGRSP", NIL, "0") == "1"     
Return (lIntegra)
