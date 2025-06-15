#INCLUDE 'WizLtUni.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TBICONN.CH'
#INCLUDE 'FILEIO.CH'
#DEFINE PULALINHA CHR(13)+CHR(10)
/* 
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �WizLtUni  � Autor �Fernando J. Siquini    � Data � 09/01/07 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Efetua manutencao nas tab. ref. ao cont.de rastreabilidade ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAEST / SIGAWMS MP811                                    ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
User Function ESTW002(lWizard)

Local lGravouLog    := .F.
Local nX            := 0
Local cLog			:= ""

Private __cInterNet := Nil
Private aArqUpd     := {}
Private aEmpresas   := {}

Private IsInUpdate  := ( Type('_UpdRunInUpd') == 'L' ) .And. _UpdRunInUpd //-- Quando esta rotina UPDATE for executada pelo atualizador de versao nao irah apresentar telas de paradas, e irah trabalhar com todo o ambiente da empresa aberto
Private lExecSB8    := .T.
Private lExecSD5    := .T.
Private lExecSBJ    := .T.
Private lExecSBF    := .T.
Private lExecSDB    := .T.
Private lExecSBK    := .T.
Private cFilProd    := ''

Private cTitulo     := STR0146 //'Wizard Lote Unico - ESTW002'                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       
Private cAcao       := STR0001 //'Ajuste das tabelas de rastreabilidade'
Private cArqEmp     := 'SIGAMAT.EMP'
Private cApresenta  := ''
Private cItemAju    := STR0002 //'Andamento do ajuste de cada tabela:'
Private cTerAceite  := ''
Private cLogUpdate  := ''
Private cEscEmp     := STR0003 //'Aten��o: Para que o Ajuste possa ser efetuado NENHUM usuario pode estar utilizando o sistema!'
Private cEmpAtu     := ''

Private lConcordo   := .F.

Private nTela       := 0
Private nAtuTotal   := 0
Private nAtuParci   := 0

Private oTitulo
Private oAcao

Private oEmpAtu
Private oSelEmp

Private oMemo1
Private oMemo2
Private oMemo3
Private oMemo4

Private oDlgUpd

Private oPanel1
Private oPanel2
Private oPanel3
Private oPanel4
Private oPanel5

Private oMtTotal
Private oMtParci
Private oItemAju

Private oAtuTotal

Private oAtuParc1
Private oAtuParc2
Private oAtuParc3

Private oApresenta

Private oTerAceite
Private oChkAceite

Private oBtnAvanca
Private oBtnCancelar

Default lWizard := .F.

cApresenta := STR0004+PULALINHA //' Esta atualiza��o ir� ajustar a base de dados para trabalhar com o conceito de LOTE �NICO. Com isso a movimenta��o de produtos que tenham controle de rastreabilidade do tipo LOTE n�o ir�o mais atualizar os campos de SUB-LOTE do sistema.'
cApresenta += STR0005+PULALINHA //' Durante sua execu��o todas as tabelas envolvidas no processo de rastreabilidade (SB8, SD5 e SBJ) terao seus registros aglutinados por LOTE.'
cApresenta += STR0006+PULALINHA //' Feito isso ser� criado e ativado o par�metro MV_LOTEUNI no dicion�rio de par�metros SX6'

cTerAceite :=STR0007+PULALINHA //'Antes que sua atualiza��o inicie, voc� deve ler e aceitar os termos e as condi��es a seguir. Ap�s aceit�-los, voc� pode prosseguir com a atualiza��o.'
cTerAceite += PULALINHA
cTerAceite += STR0008+PULALINHA //'ATEN��O: LEIA COM ATEN��O ANTES DE PROSSEGUIR COM A ATUALIZA��O'
cTerAceite += PULALINHA
cTerAceite += STR0009+PULALINHA //'ACORDO DE LICEN�A DE SOFTWARE PARA USU�RIO FINAL (ACORDO)'
cTerAceite += PULALINHA
cTerAceite += STR0010+PULALINHA //'TERMOS E CONDI��ES'
cTerAceite += PULALINHA
cTerAceite += STR0011+PULALINHA //'ADVERT�NCIAS LEGAIS: AO CLICAR NA OP��O [SIM, LI E ACEITO O TERMO ACIMA] NO FINAL DESTA JANELA, VOC� INDICA QUE LEU E CONCORDOU COM TODOS OS TERMOS DESTE ACORDO E QUE CONSENTE EM SER REGIDO POR ESTE ACORDO E TORNAR-SE PARTE DELE.  A MICROSIGA EST� DISPOSTA A DISPONIBILIZAR ESTE AJUSTE PARA VOC� APENAS SOB A CONDI��O DE QUE VOC� CONCORDE COM TODOS OS TERMOS CONTIDOS NESTE ACORDO.'
cTerAceite += STR0101 //'  SE VOC� N�O CONCORDA COM TODOS OS TERMOS DESTE ACORDO, CLIQUE NO BOT�O [CANCELAR] E N�O PROSSIGA COM O AJUSTE. '
cTerAceite += PULALINHA
cTerAceite += STR0012+PULALINHA //'O ACORDO A SEGUIR � UM ACORDO LEGAL ENTRE VOC� (O USU�RIO FINAL, SEJA UM INDIV�DUO OU ENTIDADE), E A MICROSIGA S/A. (PROPRIAMENTE DITA OU SUAS LICENCIADAS). '
cTerAceite += PULALINHA
cTerAceite += STR0013+PULALINHA //'ESTE SOFTWARE � LICENCIADO PELA MICROSIGA PARA VOC�, E QUALQUER RECEPTOR SUBSEQ�ENTE DO SOFTWARE, SOMENTE PARA USO SEGUNDO OS TERMOS ESTABELECIDOS NESTE DOCUMENTO. '
cTerAceite += PULALINHA
cTerAceite += STR0014+PULALINHA //'PREMISSAS DE UTILIZA��O: Antes de executar esta rotina � obrigat�ria a realiza��o de uma c�pia de seguran�a geral do sistema Protheus (bin�rio, RPO, dicion�rios SXs e banco de dados). Fa�a testes de performance e planeje-se antes de executar esta atualiza��o, pois ela requer acesso exclusivo �s tabelas do sistema (ou seja: nenhum usu�rio poder� acessar o sistema) durante toda a sua execu��o, que pode demorar v�rias horas para ser finalizada!'
cTerAceite += STR0102 //' Depois de iniciada esta rotina n�o poder� ser interrompida! Qualquer tipo de interrup��o (ex.: falta de energia, problemas de hardware, problemas de rede, etc.) poder� danificar todo o sistema! Neste caso deve-se realizar a restaura��o da c�pia de seguran�a feita imediatamente antes do inicio da atualiza��o antes de execut�-la novamente. Ap�s a execu��o desta atualiza��o o sistema ir� utilizar o conceito de LOTE �NICO nas movimentados de produto com rastreabilidade do tipo LOTE.'
cTerAceite += STR0103 //' Uma vez ativado, este conceito n�o poder� ser desabilitado! Para isso � importante que o par�metro MV_LOTEUNI nunca seja desabilitado, sob pena de causar, entre outros problemas, desbalanceamento de saldos na base de dados. '
cTerAceite += PULALINHA
cTerAceite += STR0015+PULALINHA //'CONCESS�O DE LICEN�A: A Microsiga lhe concede uma licen�a limitada, n�o-exclusiva e revog�vel para usar a vers�o de c�digo execut�vel da Atualiza��o do m�dulo de estoque e custos denominada WizLtUni, eximindo-se de qualquer dado resultante da utiliza��o deste. '
cTerAceite += PULALINHA
cTerAceite += STR0016+PULALINHA //'DIREITOS AUTORAIS: O Software � propriedade da Microsiga e est� protegido por leis de direitos autorais do Brasil e disposi��es de tratados internacionais.  Voc� reconhece que n�o lhe ser� transferido qualquer direito a qualquer propriedade intelectual do Software. '
cTerAceite += PULALINHA
cTerAceite += STR0017+PULALINHA //'LIMITA��ES: Exceto se explicitamente disposto em contr�rio neste Acordo, voc� n�o pode: a) modificar o Software ou criar trabalhos derivados do mesmo; b) descompilar, desmontar, fazer engenharia reversa, ou de outras maneiras tentar alterar o c�digo-fonte do Software; c) copiar (exceto para fazer uma c�pia de backup), redistribuir, impedir, vender, alugar, arrendar, sublicenciar, atribuir ou de outras maneiras transferir seus direitos ao Software; ou'
cTerAceite += STR0104 //' d) remover ou alterar qualquer marca registrada, logotipo, registro ou outras advert�ncias propriet�rias no Software.  Voc� pode transferir todos os seus direitos ao Software regidos por este Acordo para outra pessoa transferindo-lhe, permanentemente, o computador pessoal no qual o Software est� instalado, contanto que voc� n�o retenha nenhuma c�pia do Software e que o receptor concorde com todos os termos deste Acordo. '
cTerAceite += PULALINHA
cTerAceite += STR0018+PULALINHA //'ATIVIDADES DE ALTO RISCO: O Software n�o � tolerante a falhas e n�o foi projetado, fabricado ou desenvolvido para uso em ambientes perigosos que requerem desempenho � prova de falhas, como na opera��o de instala��es nucleares, navega��o de aeronaves ou sistemas de comunica��o, controle de tr�fego a�reo, dispositivos m�dicos implantados em seres humanos, m�quinas externas de suporte � vida humana, dispositivos de controle de explosivos, submarinos,'
cTerAceite += STR0105 //' sistemas de armas ou controle de opera��o de ve�culos motorizados nos quais a falha do Software poderia levar diretamente � morte, danos pessoais ou danos f�sicos ou ambientais graves (Atividades de Alto Risco). Voc� concorda em n�o usar o Software em Atividades de Alto Risco. '
cTerAceite += PULALINHA
cTerAceite += STR0019+PULALINHA //'REN�NCIA �S GARANTIAS: A Microsiga n�o garante que o Software satisfar� suas exig�ncias, que a opera��o do mesmo ser� ininterrupta ou livre de erros, ou que todos os erros de Software ser�o corrigidos.  Todo o risco no que se refere � qualidade e ao desempenho do Software decorre por sua conta. '
cTerAceite += PULALINHA
cTerAceite += STR0020+PULALINHA //'O SOFTWARE � FORNECIDO [COMO EST�] E SEM GARANTIAS DE QUALQUER TIPO, EXPRESSAS OU IMPL�CITAS, INCLUINDO, MAS N�O SE LIMITANDO A, GARANTIAS DE T�TULOS, N�O-VIOLA��O, COMERCIALIZA��O E ADEQUA��O PARA UMA FINALIDADE EM PARTICULAR.  NENHUMA INFORMA��O OU CONSELHO VERBAL OU POR ESCRITO, FORNECIDOS PELA MICROSIGA, SEUS FUNCION�RIOS, DISTRIBUIDORES, REVENDEDORES OU AGENTES AUMENTAR�O O ESCOPO DAS GARANTIAS ACIMA OU CRIAR�O QUALQUER GARANTIA NOVA. '
cTerAceite += PULALINHA
cTerAceite += STR0021+PULALINHA //'LIMITA��O DE RESPONSABILIDADE: MESMO QUE QUALQUER SOLU��O FORNECIDA NA GARANTIA FALHE EM SEU PROP�SITO ESSENCIAL, EM NENHUM EVENTO A MICROSIGA TER� OBRIGA��ES POR QUALQUER DANO ESPECIAL, CONSEQ�ENTE, INDIRETO OU SEMELHANTE, INCLUINDO PERDA DE LUCROS OU DADOS, DERIVADOS DO USO OU INABILIDADE DE USAR O SOFTWARE, OU QUAISQUER DADOS FORNECIDOS, MESMO QUE A MICROSIGA OU OUTRA PARTE TENHA SIDO AVISADA DA POSSIBILIDADE DE TAL DANO, OU EM QUALQUER'
cTerAceite += STR0106 //' REIVINDICA��O DE QUALQUER OUTRA PARTE.  ALGUMAS JURISDI��ES N�O PERMITEM A LIMITA��O OU EXCLUS�O DE RESPONSABILIDADE POR DANOS INCIDENTAIS OU CONSEQ�ENTES; PORTANTO, A LIMITA��O OU EXCLUS�O ACIMA PODE N�O SE APLICAR AO SEU CASO. '
cTerAceite += PULALINHA
cTerAceite += STR0022+PULALINHA //'TERMO: Este Acordo � v�lido at� ser terminado.  Este Acordo terminar�, e a licen�a concedida a voc� por este Acordo ser� revogada, imediatamente, sem qualquer advert�ncia da Microsiga, se voc� n�o obedecer a qualquer disposi��o deste Acordo.  Ao t�rmino do mesmo, voc� dever� destruir o Software. '
cTerAceite += PULALINHA
cTerAceite += STR0023 //'ACORDO INTEGRAL: Este Acordo constitui o acordo integral entre voc� e a Microsiga, no que se refere ao Software licenciado, e substitui todas as comunica��es, as representa��es, as compreens�es e os acordos anteriores, verbais ou por escrito, entre voc� e a Microsiga relativos a este Software.  Este Acordo n�o pode ser modificado ou renunciado, exceto por escrito e assinado por uma autoridade ou outro representante autorizado de cada parte.'
cTerAceite += STR0107 // '  Se qualquer disposi��o for considerada inv�lida, todas as outras permanecer�o v�lidas, a menos que impe�a o prop�sito de nosso Acordo.  A falha de qualquer parte em refor�ar qualquer direito concedido neste documento, ou em entrar em a��o contra a outra parte no caso de qualquer viola��o, n�o ser� considerada uma desist�ncia � subseq�ente execu��o dos direitos ou � subseq�ente a��o no caso de futuras viola��es.'

SET DELETED ON

//���������������������������������������������������Ŀ
//� Abre o arquivo de Empresas de forma compartilhada �
//�����������������������������������������������������
If !OpenSM0(.T.)
	If lWizard
		Return STR0024
	Else
		Final(STR0024) //'SIGAMAT.EMP com problemas!'
	Endif
EndIf
SM0->(DbGotop())
Do While ! SM0->(Eof())
	If !Empty(SM0->M0_CODIGO) .And. aScan(aEmpresas, {|x| SubStr(x,1,2) == SM0->M0_CODIGO}) == 0
		aAdd(aEmpresas, SM0->M0_CODIGO+' - '+SM0->M0_NOME)
	EndIf
	SM0->(DbSkip())
EndDo

If lWizard
	cLog := wizLTTabs(,lWizard)
	Return cLog
Endif

If !IsInUpdate
	DEFINE DIALOG oDlgUpd TITLE STR0146 FROM 0, 0 TO 22, 75 SIZE 550, 350 PIXEL
	@ 000,000 BITMAP oBmp RESNAME 'ProjetoAP' OF oDlgUpd SIZE 095, oDlgUpd:nBottom NOBORDER WHEN .F. PIXEL
	@ 005,070 SAY oTitulo         VAR cTitulo OF oDlgUpd PIXEL FONT (TFont():New('Arial',0,-13,.T.,.T.))
	@ 015,070 SAY oAcao           VAR cAcao   OF oDlgUpd PIXEL
	@ 155,140 BUTTON oBtnCancelar PROMPT STR0025    SIZE 60, 14 ACTION If(oBtnCancelar:cCaption==STR0025, oDlgUpd:End(), GravaLog(.T., cLogUpdate, @lGravouLog))                      OF oDlgUpd PIXEL //'&Cancelar'###'&Cancelar'
	@ 155,210 BUTTON oBtnAvanca   PROMPT STR0026  SIZE 60, 14 ACTION If(oBtnAvanca:cCaption==STR0027, (GravaLog(.F., cLogUpdate, lGravouLog), oDlgUpd:End()), SelePanel(@nTela)) OF oDlgUpd PIXEL //'&Avancar >>'###'&Finalizar'
	oDlgUpd:nStyle := nOR( DS_MODALFRAME, WS_POPUP, WS_CAPTION, WS_VISIBLE )
	
	oPanel1 := TPanel():New( 028, 072, ,oDlgUpd, , , , , , 200, 120, .F.,.T. )
	@ 002,005 SAY oApresenta VAR STR0028 OF oPanel1                        FONT (TFont():New('Arial',0,-13,.T.,.T.))PIXEL //'Bem-Vindo!'
	@ 015,005 GET oMemo1     VAR cApresenta  OF oPanel1 MEMO PIXEL SIZE 180,100 FONT (TFont():New('Verdana',,-12,.T.)) NO BORDER
	oMemo1:lReadOnly := .T.
	
	oPanel2 := TPanel():New( 028, 072, ,oDlgUpd, , , , , , 200, 120, .F.,.T. )
	@ 002,005 SAY oTerAceite VAR STR0029 OF oPanel2                         FONT (TFont():New('Arial',0,-13,.T.,.T.))PIXEL //'Leia com atencao!'
	@ 015,005 GET oMemo2     VAR cTerAceite  OF oPanel2 MEMO PIXEL SIZE 180,90 FONT (TFont():New('Verdana',,-12,.T.)) NO BORDER
	@ 107,107 CheckBox oChkAceite VAR lConcordo PROMPT STR0030 SIZE 80,10 Of oPanel2 PIXEL //'Sim, li e aceito o termo acima.'
	oMemo2:lReadOnly   := .T.
	oChkAceite:bChange := {|| Concordo(lConcordo)}
	
	oPanel3 := TPanel():New( 028, 072, ,oDlgUpd, , , , , , 200, 120, .F.,.T. )
	@ 002,005 SAY oSelEmp VAR STR0031 OF oPanel3                         FONT (TFont():New('Arial',0,-13,.T.,.T.))PIXEL //'Escolha a Empresa:'
	@ 015,005 MSCOMBOBOX oEmpAtu VAR cEmpAtu ITEMS aEmpresas SIZE 130,10 OF oPanel3 PIXEL
	@ 030,005 GET oMemo3 VAR cEscEmp          OF oPanel3 MEMO PIXEL SIZE 180,80 FONT (TFont():New('Verdana',,-12,.T.)) NO BORDER
	oMemo3:lReadOnly := .T.
	
	oPanel4 := TPanel():New( 028, 072, ,oDlgUpd, , , , , , 200, 120, .F.,.T. )
	@ 010,000 SAY oSay       VAR STR0032      OF oPanel4        PIXEL FONT (TFont():New('Arial',0,-11,.T.,.T.)) //'Andamento geral do ajuste:'
	@ 050,000 SAY oItemAju   VAR cItemAju                          OF oPanel4        PIXEL FONT (TFont():New('Arial',0,-11,.T.,.T.))
	@ 037,000 SAY oAtuTotal  VAR Space(40)                         OF oPanel4        PIXEL
	@ 077,000 SAY oAtuParc1  VAR Space(40)                         OF oPanel4        PIXEL
	@ 087,000 SAY oAtuParc2  VAR Space(40)                         OF oPanel4        PIXEL
	@ 097,000 SAY oAtuParc3  VAR Space(40)                         OF oPanel4        PIXEL
	@ 020,000 METER oMtTotal VAR nAtuTotal TOTAL 1000  SIZE 190, 15 OF oPanel4 UPDATE PIXEL
	@ 060,000 METER oMtParci VAR nAtuParci TOTAL 1000  SIZE 190, 15 OF oPanel4 UPDATE PIXEL
	
	oPanel5 := TPanel():New( 028, 072, ,oDlgUpd, , , , , , 200, 120, .F.,.T. )
	@ 002,005 SAY oLogUpdate VAR STR0033 OF oPanel5                         FONT (TFont():New('Arial',0,-13,.T.,.T.))PIXEL //'Veja o que foi feito:'
	@ 015,005 GET oMemo4     VAR cLogUpdate  OF oPanel5 MEMO PIXEL SIZE 180,90 FONT (TFont():New('Verdana',,-12,.T.)) NO BORDER
	oMemo4:lReadOnly   := .T.
	
	ACTIVATE DIALOG oDlgUpd CENTER ON INIT SelePanel(@nTela)
Else
	cEmpAtu := cEmpAnt
	wizLTTabs(IsInUpdate)
	GravaLog(.F., cLogUpdate, .F., IsInUpdate)
EndIf	

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �SelePanel �Autor  �Microsiga           � Data �  01/22/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function SelePanel(nTela)

//����������������������������������������Ŀ
//� Atualiza variaveis da janela principal �
//������������������������������������������
oTitulo:nLeft           := 120; oTitulo:Refresh()
oAcao:nLeft             := 120; oAcao:Refresh()
oBmp:lVisibleControl    := .T.
oPanel1:lVisibleControl := .F.
oPanel2:lVisibleControl := .F.
oPanel3:lVisibleControl := .F.
oPanel4:lVisibleControl := .F.
oPanel5:lVisibleControl := .F.

Do Case
	Case nTela == 0 //-- Apresentacao
		oPanel1:lVisibleControl := .T.
	Case nTela == 1 //-- Termo de aceite
		oPanel2:lVisibleControl := .T.
		oBtnAvanca:lActive      := .F.
	Case nTela == 2 //-- Selecao da empresa
		oPanel3:lVisibleControl := .T.
	Case nTela == 3 //-- Execucao do ajuste
		cAcao                   := STR0034; oAcao:Refresh() //'Execucao do ajuste'
		oPanel4:lVisibleControl := .T.
		oBtnCancelar:lActive    := .F. //-- A partir deste ponto nao pode mais ser cancelado
		oBtnAvanca:lActive      := .F.
		wizLTTabs()
		cItemAju                := STR0002; oItemAju:Refresh() //'Andamento do ajuste de cada tabela:'
		oAtuTotal:cCaption      := STR0035; oAtuTotal:Refresh() //'Ajuste finalizado!'
		oAtuParc1:cCaption      := STR0036; oAtuParc1:Refresh() //'Ajuste das tabelas finalizado!'
		oAtuParc2:cCaption      := ''; oAtuParc2:Refresh()
		oAtuParc3:cCaption      := ''; oAtuParc3:Refresh()
		oBtnAvanca:lActive      := .T.
	Case nTela == 4
		cAcao                   := STR0035; oAcao:Refresh() //'Ajuste finalizado!'
		oPanel5:lVisibleControl := .T.
		oBtnCancelar:cCaption   := STR0037 //'&Salvar Log'
		oBtnCancelar:lActive    := .T.
		oBtnAvanca:cCaption     := STR0027 //'&Finalizar'
EndCase

nTela ++

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �wizLTTabs� Autor �Fernando J. Siquini    � Data �08/01/07  ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Funcao de processamento do ajuste das tabelas              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � WizLtUni                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function wizLTTabs(IsInUpdate,lWizard)

Local aFilSB8     := {}
Local aFilSD5     := {}
Local aFilSBJ     := {}
Local aFilSBF     := {}
Local aFilSBK     := {}
Local aFilSDA     := {}
Local aFilSDB     := {}
Local aThreads    := {}
Local aRecnoSM0   := {}
Local aRecnoSX6   := {}
Local aRange      := {}
Local aProds      := {}
Local cTexto      := ''
Local cProdIni    := ""
Local cProdFim    := ""
Local cX6UPDEST8  := ''
Local cStartPath  := GetSrvProfString("Startpath","")
Local cJobFile    := ""
Local cJobAux     := ""
Local cThread     := ""
Local lStartJob	  := .F.
Local lQuery      := .F.
Local lRet        := .T.
Local lIncluiSX6  := .F.
Local nX          := 0
Local nY          := 0
Local nPosIni     := 0
Local nPosFim     := 0
Local nThreads    := 1
Local nThreadsAnt := 1

Default IsInUpdate := .F.
Default lWizard	   := .F.

Private cModulo    := 'EST'
Private lMsFinalAut:= .F.
Private nModulo    := 04 //-- SIGAEST
Private oMemoLog

Private lUpd8Mult	:= .F.

//������������������������������������������Ŀ
//� Verifica se o ambiente TOP e/ou CODEBASE �
//��������������������������������������������
#IFDEF TOP
	If TcSrvType() <> "AS/400"
		lQuery := .T.
	Endif
#ENDIF

//�������������������������������������������������������������������������������������������������������������������Ŀ
//� Abre o arquivo de Empresas de forma exclusiva e alimenta array com todas as Filiais que terao o ajuste processado �
//���������������������������������������������������������������������������������������������������������������������
If !IsInUpdate
	// Tenta abrir exclusivo
	If !OpenSM0(.F.)
		If lWizard
			Return STR0028
		Endif
		Final(STR0038) //'SIGAMAT.EMP em uso!'
	EndIf
	// Tenta abrir compartilhado - Necessario para rodar as multi-threads
	If !OpenSM0(.T.)
		If lWizard
			Return STR0024
		Endif
		Final(STR0024) //'SIGAMAT.EMP com problemas!'
	EndIf
EndIf	
SM0->(dbGotop())
Do While !SM0->(Eof())
	If SM0->M0_CODIGO == SubStr(cEmpAtu,1,2) .And. aScan(aRecnoSM0, {|x| x[2] == SM0->M0_CODIGO+SM0->M0_CODFIL}) == 0
		aAdd(aRecnoSM0, {Recno(), SM0->M0_CODIGO+SM0->M0_CODFIL})
	EndIf
	SM0->(dbSkip())
EndDo
aSort(aRecnoSM0,,, {|x, y| x[2] < y[2]})

//����������������������������������������Ŀ
//� Atualiza variaveis da janela principal �
//������������������������������������������
nAtuTotal       := 0
If !IsInUpdate .And. !lWizard
	oMtTotal:nTotal := (3*Len(aRecnoSM0))
EndIf	

//������������������������������������Ŀ
//� Laco com processamento das filiais �
//��������������������������������������
For nX := 1 To Len(aRecnoSM0)
	SM0->(dbGoto(aRecnoSM0[nX, 1]))
	If nX == 1
		If !IsInUpdate .And. !lWizard
			MsgRun(STR0039+AllTrim(SM0->M0_CODIGO+'-'+SM0->M0_NOME)+'...',STR0040,{|| CursorWait(), AbreEmpre(SM0->M0_CODIGO, SM0->M0_CODFIL, cModulo) ,CursorArrow()}) //'Aguarde... Iniciando Empresa '###'Aguarde...'
		Else
			AbreEmpre(SM0->M0_CODIGO, SM0->M0_CODFIL, cModulo)	
		EndIf	
		
		//�����������������������
		//� LOG - Secao inicial �
		//�����������������������
		cTexto += STR0041+DtoC(Date())+STR0042+SubStr(Time(), 1, 5)+PULALINHA //'>> Ajuste Iniciado em '###', as '
		cTexto += PULALINHA
		cTexto += STR0043+PULALINHA //'LOG do Wizard Lote Unico'
		cTexto += '======================'+PULALINHA
		cTexto += PULALINHA
		
		//�����������������������������������
		//� LOG - Secao referente a empresa �
		//�����������������������������������
		cTexto += STR0044+AllTrim(SM0->M0_CODIGO+'-'+SM0->M0_NOME)+PULALINHA //'*Empresa : '
		cTexto += STR0045+PULALINHA //' Tipo de acesso das tabelas envolvidas no ajuste:'
		cTexto += STR0046+If(Empty(SB8->(xFilial('SB8'))), STR0047, STR0048)+PULALINHA //' SB8 - Acesso '###'compartilhado para todas as filiais desta empresa (so sera feito 1 ajuste para toda a empresa)'###'exclusivo, individual para cada filial'
		cTexto += STR0049+If(Empty(SD5->(xFilial('SD5'))), STR0047, STR0048)+PULALINHA //' SD5 - Acesso '###'compartilhado para todas as filiais desta empresa (so sera feito 1 ajuste para toda a empresa)'###'exclusivo, individual para cada filial'
		cTexto += STR0050+If(Empty(SBJ->(xFilial('SBJ'))), STR0047, STR0048)+PULALINHA //' SBJ - Acesso '###'compartilhado para todas as filiais desta empresa (so sera feito 1 ajuste para toda a empresa)'###'exclusivo, individual para cada filial'
		cTexto += STR0108+If(Empty(SBF->(xFilial('SBF'))), STR0047, STR0048)+PULALINHA //' SBF - Acesso '###'compartilhado para todas as filiais desta empresa (so sera feito 1 ajuste para toda a empresa)'###'exclusivo, individual para cada filial'
		cTexto += STR0109+If(Empty(SBK->(xFilial('SBK'))), STR0047, STR0048)+PULALINHA //' SBK - Acesso '###'compartilhado para todas as filiais desta empresa (so sera feito 1 ajuste para toda a empresa)'###'exclusivo, individual para cada filial'
		cTexto += STR0110+If(Empty(SDA->(xFilial('SDA'))), STR0047, STR0048)+PULALINHA //' SDA - Acesso '###'compartilhado para todas as filiais desta empresa (so sera feito 1 ajuste para toda a empresa)'###'exclusivo, individual para cada filial'
		cTexto += STR0111+If(Empty(SDB->(xFilial('SDB'))), STR0047, STR0048)+PULALINHA //' SDB - Acesso '###'compartilhado para todas as filiais desta empresa (so sera feito 1 ajuste para toda a empresa)'###'exclusivo, individual para cada filial'
		cTexto += PULALINHA
		lMsHelpAuto := .F. //-- Seta variavel para forcar a exibicao dos HELPs na tela
		dbSelectArea('SX6') //-- Parametros
		dbSetOrder(1) //-- X6_FIL+X6_VAR
		If dbSeek(Space(FWGETTAMFILIAL)+'MV_LOTEUNI', .F.)
			If !IsInUpdate
				If !lWizard
					If Aviso(STR0147/*ESTW002*/, STR0055+cEmpAtu+STR0056, {STR0057, STR0058})	== 1 //'O Wizard Lote Unico ja foi executado para a empresa '###'! Deseja executa-lo novamente?'###'Aborta'###'Executa'
						Final(STR0059) //'WizLtUni ja executado!'
					EndIf
				Endif	
				cTexto += STR0060+PULALINHA //' Obs.: O usuario foi informado que este UPDATE jah havia sido executado anteriormente para esta mesma empresa. Esta nova execucao foi forcada.'
				cTexto += PULALINHA
			EndIf
		EndIf

		//�������������������������������������������������������������������������������������������Ŀ
		//� Parametro MV_UPDEST8 que auxilia em testes ou execucoes especiais                         �
		//� ATENCAO! este parametro deve ser alterado somente com supervisao de um analista Microsiga �
		//���������������������������������������������������������������������������������������������
		dbSelectArea('SX6')
		dbSetOrder(1)
		If dbSeek(Space(FWGETTAMFILIAL)+'MV_UPDEST8', .F.)
			cX6UPDEST8 := X6_CONTEUD
		Else
			cX6UPDEST8 := PadR('SSSSSSS', Len(X6_CONTEUD))
		EndIf	
		lExecSB8 := (SubStr(cX6UPDEST8, 1, 1)=='S') // Tabela SB8
		lExecSD5 := (SubStr(cX6UPDEST8, 2, 1)=='S') // Tabela SD5
		lExecSBJ := (SubStr(cX6UPDEST8, 3, 1)=='S') // Tabela SBJ
		lExecSBF := (SubStr(cX6UPDEST8, 4, 1)=='S') // Tabela SBF
		lExecSBK := (SubStr(cX6UPDEST8, 5, 1)=='S') // Tabela SBK
		lExecSDA := (SubStr(cX6UPDEST8, 6, 1)=='S') // Tabela SDA
		lExecSDB := (SubStr(cX6UPDEST8, 7, 1)=='S') // Tabela SDB
		cFilProd := AllTrim(SubStr(cX6UPDEST8, 8, Len(X6_CONTEUD)-7))
		If !Empty(cFilProd)
			cTexto += STR0097+cFilProd+STR0098+PULALINHA //' Atencao: O filtro de produtos "'#'" foi feito via MV_UPDEST8!'
			cTexto += PULALINHA
		EndIf	
		
		//��������������������������������������������Ŀ
		//� Obtem parametro para tratamento de threads �
		//����������������������������������������������
		dbSelectArea('SX6')
		dbSetOrder(1) // X6_FILIAL+X6_VAR)
		If SX6->(dbSeek(Space(FWGETTAMFILIAL)+'MV_UPD8THR', .F.))
			nThreads  := Val(IIf(Empty(SX6->X6_CONTEUD),1,SX6->X6_CONTEUD))	// Qtde. de threads a serem utilizadas
			lUpd8Mult := ( nThreads > 1 ) 									// Indica se eh multi-thread
		EndIf
		
		//������������������������������������������Ŀ
		//� Tratamento de Limite de Threads          �
		//��������������������������������������������
		If nThreads > 15
			nThreads 	:= 15
			nThreadsAnt := 15
		Else
			nThreadsAnt := nThreads
		Endif

	EndIf
	cFilAnt := SM0->M0_CODFIL //-- Seta para a filial atual a variavel utilizada pela funcao xFilial()
	
	//����������������������������������
	//� LOG - Secao referente a filial �
	//����������������������������������
	cTexto += STR0061+AllTrim(SM0->M0_CODFIL+'-'+SM0->M0_FILIAL)+':'+PULALINHA //'*Ajuste feito nas tabelas da filial '
	
	//�������������������������������������������������Ŀ
	//� Inicializa tabelas a serem utilizadas no ajuste �
	//���������������������������������������������������
	dbSelectArea('SB1') //-- Cadastro de Produtos
	dbSetOrder(1)
	
	dbSelectArea('SB8') //-- Saldos por Lote
	dbSetOrder(3) //-- B8_FILIAL+B8_PRODUTO+B8_LOCAL+B8_LOTECTL+B8_NUMLOTE+DTOS(B8_DTVALID)
	
	dbSelectArea('SBJ') //-- Saldos iniciaid por Lote
	dbSetOrder(1) //-- BJ_FILIAL+BJ_COD+BJ_LOCAL+BJ_LOTECTL+BJ_NUMLOTE+DTOS(BJ_DATA)
	
	dbSelectArea('SD5') //-- Movimentacao por Lote
	dbSetOrder(3) //-- D5_FILIAL+D5_NUMSEQ+D5_PRODUTO+D5_LOCAL+D5_LOTECTL+D5_NUMLOTE

	dbSelectArea('SBF') //-- Saldos por localizacao fisica
	dbSetOrder(2) //-- BF_FILIAL+BF_PRODUTO+BF_LOCAL+BF_LOTECTL+BF_NUMLOTE+BF_PRIOR+BF_LOCALIZ+BF_NUMSERI

	dbSelectArea('SBK') //-- Saldos iniciais por localizacao fisica
	dbSetOrder(1) //-- BK_FILIAL+BK_COD+BK_LOCAL+BK_LOTECTL+BK_NUMLOTE+BK_LOCALIZ+BK_NUMSERI+DTOS(BK_DATA)

	dbSelectArea('SDA') //-- Saldos a enderecar
	dbSetOrder(1) //-- DA_FILIAL+DA_PRODUTO+DA_LOCAL+DA_NUMSEQ+DA_DOC+DA_SERIE+DA_CLIFOR+DA_LOJA

	dbSelectArea('SDB') //-- Movimentacao por localizacao fisica
	dbSetOrder(2) //-- DB_FILIAL+DB_PRODUTO+DB_LOCAL+DB_LOTECTL+DB_NUMLOTE+DB_NUMSERI+DB_LOCALIZ+DB_NUMSEQ
	//����������������������������������������Ŀ
	//� Atualiza variaveis da janela principal �
	//������������������������������������������
	If !IsInUpdate .And. !lWizard
		oAtuTotal:cCaption := STR0062+AllTrim(SM0->M0_CODIGO+'-'+SM0->M0_NOME)+STR0063+AllTrim(SM0->M0_CODFIL+'-'+SM0->M0_FILIAL); oAtuTotal:Refresh() //'Empresa: '###' / Filial: '
	EndIf	
	

	//�����������������������������������Ŀ
	//� Atualiza o log de processamento   �
	//�������������������������������������
	ProcLogAtu("INICIO")

	//�������������������������������������Ŀ	
	//� Inicializa o log de processamento   �
	//���������������������������������������
	ProcLogIni( {},"WizLtUni")

	//��������������������������������������������������������������Ŀ
	//� Processamento em uma unica thread                            �
	//����������������������������������������������������������������
	If !lUpd8Mult .Or. !lQuery
		
		//����������������������������������
		//� Realiza o ajuste na tabela SB8 �
		//����������������������������������
		If lExecSB8
			WizLTSB8(@cTexto, aFilSB8, IsInUpdate, lWizard)
		Else
			cTexto += STR0099+'SB8'+STR0100+PULALINHA //' Tabela '#': Ajuste desabilitado via MV_UPDEST8'
		EndIf
		
		//����������������������������������
		//� Realiza o ajuste na tabela SD5 �
		//����������������������������������
		If lExecSD5	
			WizLTSD5(@cTexto, aFilSD5, IsInUpdate, lWizard)
		Else
			cTexto += STR0099+'SD5'+STR0100+PULALINHA //' Tabela '#': Ajuste desabilitado via MV_UPDEST8'
		EndIf
		
		//����������������������������������
		//� Realiza o ajuste na tabela SBJ �
		//����������������������������������
		If lExecSBJ	
			WizLTSBJ(@cTexto, aFilSBJ, IsInUpdate, lWizard)
		Else
			cTexto += STR0099+'SBJ'+STR0100+PULALINHA //' Tabela '#': Ajuste desabilitado via MV_UPDEST8'
		EndIf
		
		//����������������������������������
		//� Realiza o ajuste na tabela SBF �
		//����������������������������������
		If lExecSBF
			WizLTSBF(@cTexto, aFilSBF, IsInUpdate, lWizard)
		Else
			cTexto += STR0099+'SBF'+STR0100+PULALINHA //' Tabela '#': Ajuste desabilitado via MV_UPDEST8'
		EndIf
		
		//����������������������������������
		//� Realiza o ajuste na tabela SBK �
		//����������������������������������
		If lExecSBK
			WizLTSBK(@cTexto, aFilSBK, IsInUpdate, lWizard)
		Else
			cTexto += STR0099+'SBK'+STR0100+PULALINHA //' Tabela '#': Ajuste desabilitado via MV_UPDEST8'
		EndIf
		
		//����������������������������������
		//� Realiza o ajuste na tabela SDA �
		//����������������������������������
		If lExecSDA
			WizLTSDA(@cTexto, aFilSDA, IsInUpdate, lWizard)
		Else
			cTexto += STR0099+'SDA'+STR0100+PULALINHA //' Tabela '#': Ajuste desabilitado via MV_UPDEST8'
		EndIf
		
		//����������������������������������
		//� Realiza o ajuste na tabela SDB �
		//����������������������������������
		If lExecSDB
			WizLTSDB(@cTexto, aFilSDB, IsInUpdate, lWizard)
		Else
			cTexto += STR0099+'SDB'+STR0100+PULALINHA //' Tabela '#': Ajuste desabilitado via MV_UPDEST8'
		EndIf
		
	Else
		//�����������������������������������������������Ŀ
		//� Otimizacao da Multi-Thread (apenas em TOP)    �
		//�������������������������������������������������
        If lQuery
			//����������������������������������
			//� Realiza o ajuste na tabela SB8 �
			//����������������������������������
			If lExecSB8
				//���������������������������������������������Ŀ
				//� Atualiza o log de processamento			    �
				//�����������������������������������������������
				ProcLogAtu("MENSAGEM","Iniciando SB8","Iniciando SB8")
	
				//����������������������������������������Ŀ
				//� Atualiza variaveis da janela principal �
				//������������������������������������������
				If !IsInUpdate .And. !lWizard
					oMtTotal:Set(++nAtuTotal); SysRefresh()
					cItemAju           := STR0073; oItemAju:Refresh() //'Andamento do ajuste da tabela de saldos por lote:'
					nAtuParci          := 0
					oMtParci:nTotal    := nThreads
					oAtuParc1:cCaption := STR0074; oAtuParc1:Refresh() //'Varrendo tabela SB8...'
					oAtuParc2:cCaption := ''; oAtuParc2:Refresh()
					oAtuParc3:cCaption := ''; oAtuParc3:Refresh()
				EndIf
				aThreads:= {}
				nThreads:= nThreadsAnt
				cAlias 	:= GetNextAlias()
				cQuery 	:= "SELECT DISTINCT SB8.B8_PRODUTO "
				cQuery 	+= "FROM "+RetSqlName("SB8")+" SB8 "
				cQuery  += "JOIN "+RetSqlName('SB1')+" SB1 "
				cQuery  += "ON SB1.B1_FILIAL = '"+xFilial('SB1')+"' "
				cQuery  += " AND SB1.B1_COD = SB8.B8_PRODUTO "
				cQuery  += " AND SB1.B1_RASTRO = 'L' "
				cQuery  += " AND SB1.D_E_L_E_T_ = ' ' "
				cQuery  += "WHERE SB8.B8_FILIAL = '"+xFilial("SB8")+"' " 
				cQuery  += " AND SB8.B8_LOTECTL <> ' ' "
				cQuery  += " AND SB8.B8_NUMLOTE <> ' ' "
				cQuery  += " AND SB8.D_E_L_E_T_ = ' ' "
				cQuery  += "ORDER BY SB8.B8_PRODUTO "
				
				If !IsInUpdate .And. !lWizard
					oAtuParc2:cCaption := STR0075; oAtuParc2:Refresh() //'Selecionando Registros...'
				EndIf
				cQuery := ChangeQuery(cQuery)
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
				
				aProds := {}
				(cAlias)->(dbGoTop())
				While (cAlias)->(!Eof())
					AADD( aProds, (cAlias)->B8_PRODUTO )
					(cAlias)->(dbSkip())
				Enddo
				(cAlias)->(dbCloseArea())
				
				aRange := {}
				If Len( aProds ) > 0
					nTotRegs   := Len( aProds )
					nTotThread := Int( nTotRegs / nThreads )
					For nY := 1 To nTotRegs
						nPosIni := nY
						nPosFim := IIf( (nY + nTotThread) > nTotRegs, nTotRegs, (nY + nTotThread) )
						AADD( aRange, {aProds[nPosIni], aProds[nPosFim]} )
						nY := nPosFim
					Next nY
				Endif

				If Len( aRange ) > 0
					For nY := 1 To Len( aRange )
						cProdIni := aRange[nY][1]
						cProdFim := aRange[nY][2]
						cJobAux	 := "SB8"+StrZero(nY,2)
						cJobFile := cStartPath + CriaTrab(Nil,.F.)+".job"	//Informacoes do semaforo
						cThread	 := "WZThrSB8"
						AADD(aThreads,{cJobFile,cJobAux,cThread,cProdIni,cProdFim})
						PutGlbValue(cJobAux,"0")	//Inicializa variavel global de controle de thread
						GlbUnLock()
						If !lWizard
							ConOut(STR0112+cJobAux+STR0113+Trim(cProdIni)+STR0114+Trim(cProdFim))
						Endif
						StartJob(cThread,GetEnvServer(),lStartJob,aFilSB8,IsInUpdate,cEmpAnt,cFilAnt,cJobFile,cJobAux,cProdIni,cProdFim)
						If !IsInUpdate .And. !lWizard
							oMtParci:Set(++nAtuParci); SysRefresh()
							oAtuParc2:cCaption := STR0112+cJobAux; oAtuParc2:Refresh()	 //'Inicializando Job #'
						EndIf
					Next nY
					If !IsInUpdate .And. !lWizard
						oAtuParc2:cCaption := STR0076; oAtuParc2:Refresh() //'Processando o ajuste...'
					EndIf
					CtrlMThrd(lQuery,aThreads,cEmpAnt,cFilAnt,aFilSB8,IsInUpdate,lWizard)
					If !IsInUpdate .And. !lWizard
						oMtParci:Set(nThreads); SysRefresh() //-- Finaliza a regua de processamento
						oAtuParc2:cCaption := STR0099+'SB8'+STR0145; oAtuParc2:Refresh()	 //'Tabela SB8: Threads processadas com sucesso!'
					EndIf
					cTexto += STR0083+PULALINHA //'Ajuste da SB8 finalizado!'
					//���������������������������������������������Ŀ
					//� Atualiza o log de processamento			    �
					//�����������������������������������������������
					ProcLogAtu("MENSAGEM","Termino SB8","Termino SB8")
				Else
					cTexto += STR0081+PULALINHA //' Tabela SB8: Nenhum registro processado(*). '
				Endif
			Else
				cTexto += STR0099+'SB8'+STR0100+PULALINHA //' Tabela '#': Ajuste desabilitado via MV_UPDEST8'
			EndIf

			//����������������������������������
			//� Realiza o ajuste na tabela SD5 �
			//����������������������������������
			If lExecSD5	
				//���������������������������������������������Ŀ
				//� Atualiza o log de processamento			    �
				//�����������������������������������������������
				ProcLogAtu("MENSAGEM","Iniciando SD5","Iniciando SD5")

				//����������������������������������������Ŀ
				//� Atualiza variaveis da janela principal �
				//������������������������������������������
				If !IsInUpdate .And. !lWizard
					oMtTotal:Set(++nAtuTotal); SysRefresh()
					cItemAju           := STR0084; oItemAju:Refresh() //'Andamento do ajuste da tabela de movimentos por lote:'
					nAtuParci          := 0
					oMtParci:nTotal    := nThreads
					oAtuParc1:cCaption := STR0085; oAtuParc1:Refresh() //'Varrendo tabela SD5...'
					oAtuParc2:cCaption := ''; oAtuParc2:Refresh()
					oAtuParc3:cCaption := ''; oAtuParc3:Refresh()
				EndIf
				aThreads:= {}
				nThreads:= nThreadsAnt
				cAlias 	:= GetNextAlias()
				cQuery 	:= "SELECT DISTINCT SD5.D5_PRODUTO "
				cQuery 	+= "FROM "+RetSqlName("SD5")+" SD5 "
				cQuery  += "JOIN "+RetSqlName('SB1')+" SB1 "
				cQuery  += "ON SB1.B1_FILIAL = '"+xFilial('SB1')+"' "
				cQuery  += " AND SB1.B1_COD = SD5.D5_PRODUTO "
				cQuery  += " AND SB1.B1_RASTRO = 'L' "
				cQuery  += " AND SB1.D_E_L_E_T_ = ' ' "
				cQuery  += "WHERE SD5.D5_FILIAL = '"+xFilial("SD5")+"' " 
				cQuery  += " AND SD5.D5_LOTECTL <> ' ' "
				cQuery  += " AND SD5.D5_NUMLOTE <> ' ' "
				cQuery  += " AND SD5.D_E_L_E_T_ = ' ' "
				cQuery  += "ORDER BY SD5.D5_PRODUTO "
				
				If !IsInUpdate .And. !lWizard
					oAtuParc2:cCaption := STR0075; oAtuParc2:Refresh() //'Selecionando Registros...'
				EndIf
				cQuery := ChangeQuery(cQuery)
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
				
				aProds := {}
				(cAlias)->(dbGoTop())
				While (cAlias)->(!Eof())
					AADD( aProds, (cAlias)->D5_PRODUTO )
					(cAlias)->(dbSkip())
				Enddo
				(cAlias)->(dbCloseArea())
				
				aRange := {}
				If Len( aProds ) > 0
					nTotRegs   := Len( aProds )
					nTotThread := Int( nTotRegs / nThreads )
					For nY := 1 To nTotRegs
						nPosIni := nY
						nPosFim := IIf( (nY + nTotThread) > nTotRegs, nTotRegs, (nY + nTotThread) )
						AADD( aRange, {aProds[nPosIni], aProds[nPosFim]} )
						nY := nPosFim
					Next nY
				Endif
				
				If Len( aRange ) > 0
					For nY := 1 To Len( aRange )
						cProdIni := aRange[nY][1]
						cProdFim := aRange[nY][2]
						cJobAux	 := "SD5"+StrZero(nY,2)
						cJobFile := cStartPath + CriaTrab(Nil,.F.)+".job"	//Informacoes do semaforo
						cThread	 := "WhThrSD5"
						AADD(aThreads,{cJobFile,cJobAux,cThread,cProdIni,cProdFim})
						PutGlbValue(cJobAux,"0")	//Inicializa variavel global de controle de thread
						GlbUnLock()
						If !lWizard
							ConOut(STR0112+cJobAux+STR0113+Trim(cProdIni)+STR0114+Trim(cProdFim))
						Endif
						StartJob(cThread,GetEnvServer(),lStartJob,aFilSD5,IsInUpdate,cEmpAnt,cFilAnt,cJobFile,cJobAux,cProdIni,cProdFim)
						If !IsInUpdate .And. !lWizard
							oMtParci:Set(++nAtuParci); SysRefresh()
							oAtuParc2:cCaption := STR0112+cJobAux; oAtuParc2:Refresh()	 //'Inicializando Job #'
						EndIf
					Next nY
					If !IsInUpdate .And. !lWizard
						oAtuParc2:cCaption := STR0076; oAtuParc2:Refresh() //'Processando o ajuste...'
					EndIf
					CtrlMThrd(lQuery,aThreads,cEmpAnt,cFilAnt,aFilSD5,IsInUpdate,lWizard)
					If !IsInUpdate .And. !lWizard
						oMtParci:Set(nThreads); SysRefresh() //-- Finaliza a regua de processamento
						oAtuParc2:cCaption := STR0099+'SD5'+STR0145; oAtuParc2:Refresh()	 //'Tabela SD5: Threads processadas com sucesso!'
					EndIf
					cTexto += STR0088+PULALINHA //'Ajuste da SD5 finalizado!'
					//���������������������������������������������Ŀ
					//� Atualiza o log de processamento			    �
					//�����������������������������������������������
					ProcLogAtu("MENSAGEM","Termino SD5","Termino SD5")

				Else
					cTexto += STR0092+PULALINHA //' Tabela SD5: Nenhum registro processado(*). '
				Endif
			Else
				cTexto += STR0099+'SD5'+STR0100+PULALINHA //' Tabela '#': Ajuste desabilitado via MV_UPDEST8'
			EndIf
			
			//����������������������������������
			//� Realiza o ajuste na tabela SBJ �
			//����������������������������������
			If lExecSBJ	
				//���������������������������������������������Ŀ
				//� Atualiza o log de processamento			    �
				//�����������������������������������������������
				ProcLogAtu("MENSAGEM","Iniciando SBJ","Iniciando SBJ")

				//����������������������������������������Ŀ
				//� Atualiza variaveis da janela principal �
				//������������������������������������������
				If !IsInUpdate .And. !lWizard
					oMtTotal:Set(++nAtuTotal); SysRefresh()
					cItemAju           := STR0089; oItemAju:Refresh() //'Andamento do ajuste da tabela de saldos iniciais por lote:'
					nAtuParci          := 0
					oMtParci:nTotal    := nThreads
					oAtuParc1:cCaption := STR0090; oAtuParc1:Refresh() //'Varrendo tabela SBJ...'
					oAtuParc2:cCaption := ''; oAtuParc2:Refresh()
					oAtuParc3:cCaption := ''; oAtuParc3:Refresh()
				EndIf	
				aThreads:= {}
				nThreads:= nThreadsAnt
				cAlias 	:= GetNextAlias()
				cQuery 	:= "SELECT DISTINCT SBJ.BJ_COD "
				cQuery 	+= "FROM "+RetSqlName("SBJ")+" SBJ "
				cQuery  += "JOIN "+RetSqlName('SB1')+" SB1 "
				cQuery  += "ON SB1.B1_FILIAL = '"+xFilial('SB1')+"' "
				cQuery  += " AND SB1.B1_COD = SBJ.BJ_COD "
				cQuery  += " AND SB1.B1_RASTRO = 'L' "
				cQuery  += " AND SB1.D_E_L_E_T_ = ' ' "
				cQuery  += "WHERE SBJ.BJ_FILIAL = '"+xFilial("SBJ")+"' " 
				cQuery  += " AND SBJ.BJ_LOTECTL <> ' ' "
				cQuery  += " AND SBJ.BJ_NUMLOTE <> ' ' "
				cQuery  += " AND SBJ.D_E_L_E_T_ = ' ' "
				cQuery  += "ORDER BY SBJ.BJ_COD "
				
				If !IsInUpdate .And. !lWizard
					oAtuParc2:cCaption := STR0075; oAtuParc2:Refresh() //'Selecionando Registros...'
				EndIf
				cQuery := ChangeQuery(cQuery)
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
				
				aProds := {}
				(cAlias)->(dbGoTop())
				While (cAlias)->(!Eof())
					AADD( aProds, (cAlias)->BJ_COD )
					(cAlias)->(dbSkip())
				Enddo
				(cAlias)->(dbCloseArea())
				
				aRange := {}
				If Len( aProds ) > 0
					nTotRegs   := Len( aProds )
					nTotThread := Int( nTotRegs / nThreads )
					For nY := 1 To nTotRegs
						nPosIni := nY
						nPosFim := IIf( (nY + nTotThread) > nTotRegs, nTotRegs, (nY + nTotThread) )
						AADD( aRange, {aProds[nPosIni], aProds[nPosFim]} )
						nY := nPosFim
					Next nY
				Endif
				
				If Len( aRange ) > 0
					For nY := 1 To Len( aRange )
						cProdIni := aRange[nY][1]
						cProdFim := aRange[nY][2]
						cJobAux	 := "SBJ"+StrZero(nY,2)
						cJobFile := cStartPath + CriaTrab(Nil,.F.)+".job"	//Informacoes do semaforo
						cThread	 := "WzThrSBJ"
						AADD(aThreads,{cJobFile,cJobAux,cThread,cProdIni,cProdFim})
						PutGlbValue(cJobAux,"0")	//Inicializa variavel global de controle de thread
						GlbUnLock()
						If !lWizard
							ConOut(STR0112+cJobAux+STR0113+Trim(cProdIni)+STR0114+Trim(cProdFim))
						Endif
						StartJob(cThread,GetEnvServer(),lStartJob,aFilSBJ,IsInUpdate,cEmpAnt,cFilAnt,cJobFile,cJobAux,cProdIni,cProdFim)
						If !IsInUpdate .And. !lWizard
							oMtParci:Set(++nAtuParci); SysRefresh()
							oAtuParc2:cCaption := STR0112+cJobAux; oAtuParc2:Refresh()	 //'Inicializando Job #'
						EndIf
					Next nY
					If !IsInUpdate .And. !lWizard
						oAtuParc2:cCaption := STR0076; oAtuParc2:Refresh() //'Processando o ajuste...'
					EndIf
					CtrlMThrd(lQuery,aThreads,cEmpAnt,cFilAnt,aFilSBJ,IsInUpdate,lWIzard)
					If !IsInUpdate .And. !lWizard
						oMtParci:Set(nThreads); SysRefresh() //-- Finaliza a regua de processamento
						oAtuParc2:cCaption := STR0099+'SBJ'+STR0145; oAtuParc2:Refresh()	 //'Tabela SBJ: Threads processadas com sucesso!'
					EndIf
					cTexto += STR0093+PULALINHA //'Ajuste da SBJ finalizado!'
					//���������������������������������������������Ŀ
					//� Atualiza o log de processamento			    �
					//�����������������������������������������������
					ProcLogAtu("MENSAGEM","Termino SBJ","Termino SBJ")

				Else
					cTexto += STR0116+PULALINHA //' Tabela SBJ: Nenhum registro processado. '
				Endif
			Else
				cTexto += STR0099+'SBJ'+STR0100+PULALINHA //' Tabela '#': Ajuste desabilitado via MV_UPDEST8'
			EndIf
			
			//����������������������������������
			//� Realiza o ajuste na tabela SBF �
			//����������������������������������
			If lExecSBF
				//���������������������������������������������Ŀ
				//� Atualiza o log de processamento			    �
				//�����������������������������������������������
				ProcLogAtu("MENSAGEM","Iniciando SBF","Iniciando SBF")

				//����������������������������������������Ŀ
				//� Atualiza variaveis da janela principal �
				//������������������������������������������
				If !IsInUpdate .And. !lWizard
					oMtTotal:Set(++nAtuTotal); SysRefresh()
					cItemAju           := STR0120; oItemAju:Refresh()
					nAtuParci          := 0
					oMtParci:nTotal    := nThreads
					oAtuParc1:cCaption := STR0121; oAtuParc1:Refresh()
					oAtuParc2:cCaption := ''; oAtuParc2:Refresh()
					oAtuParc3:cCaption := ''; oAtuParc3:Refresh()
				EndIf	
				aThreads:= {}
				nThreads:= nThreadsAnt
				cAlias 	:= GetNextAlias()
				cQuery 	:= "SELECT DISTINCT SBF.BF_PRODUTO "
				cQuery 	+= "FROM "+RetSqlName("SBF")+" SBF "
				cQuery  += "JOIN "+RetSqlName('SB1')+" SB1 "
				cQuery  += "ON SB1.B1_FILIAL = '"+xFilial('SB1')+"' "
				cQuery  += " AND SB1.B1_COD = SBF.BF_PRODUTO "
				cQuery  += " AND SB1.B1_RASTRO = 'L' "
				cQuery  += " AND SB1.D_E_L_E_T_ = ' ' "
				cQuery  += "WHERE SBF.BF_FILIAL = '"+xFilial("SBF")+"' " 
				cQuery  += " AND SBF.BF_LOTECTL <> ' ' "
				cQuery  += " AND SBF.BF_NUMLOTE <> ' ' "
				cQuery  += " AND SBF.D_E_L_E_T_ = ' ' "
				cQuery  += "ORDER BY SBF.BF_PRODUTO "
				
				If !IsInUpdate .And. !lWizard
					oAtuParc2:cCaption := STR0075; oAtuParc2:Refresh() //'Selecionando Registros...'
				EndIf
				cQuery := ChangeQuery(cQuery)
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
				
				aProds := {}
				(cAlias)->(dbGoTop())
				While (cAlias)->(!Eof())
					AADD( aProds, (cAlias)->BF_PRODUTO )
					(cAlias)->(dbSkip())
				Enddo
				(cAlias)->(dbCloseArea())
				
				aRange := {}
				If Len( aProds ) > 0
					nTotRegs   := Len( aProds )
					nTotThread := Int( nTotRegs / nThreads )
					For nY := 1 To nTotRegs
						nPosIni := nY
						nPosFim := IIf( (nY + nTotThread) > nTotRegs, nTotRegs, (nY + nTotThread) )
						AADD( aRange, {aProds[nPosIni], aProds[nPosFim]} )
						nY := nPosFim
					Next nY
				Endif
				
				If Len( aRange ) > 0
					For nY := 1 To Len( aRange )
						cProdIni := aRange[nY][1]
						cProdFim := aRange[nY][2]
						cJobAux	 := "SBF"+StrZero(nY,2)
						cJobFile := cStartPath + CriaTrab(Nil,.F.)+".job"	//Informacoes do semaforo
						cThread	 := "WzThrSBF"
						AADD(aThreads,{cJobFile,cJobAux,cThread,cProdIni,cProdFim})
						PutGlbValue(cJobAux,"0")	//Inicializa variavel global de controle de thread
						GlbUnLock()
						If !lWizard
							ConOut(STR0112+cJobAux+STR0113+Trim(cProdIni)+STR0114+Trim(cProdFim))
						Endif
						StartJob(cThread,GetEnvServer(),lStartJob,aFilSBF,IsInUpdate,cEmpAnt,cFilAnt,cJobFile,cJobAux,cProdIni,cProdFim)
						If !IsInUpdate .And. !lWizard
							oMtParci:Set(++nAtuParci); SysRefresh()
							oAtuParc2:cCaption := STR0112+cJobAux; oAtuParc2:Refresh()	 //'Inicializando Job #'
						EndIf
					Next nY
					If !IsInUpdate .And. !lWizard
						oAtuParc2:cCaption := STR0076; oAtuParc2:Refresh() //'Processando o ajuste...'
					EndIf
					CtrlMThrd(lQuery,aThreads,cEmpAnt,cFilAnt,aFilSBF,IsInUpdate,lWizard)
					If !IsInUpdate .And. !lWizard
						oMtParci:Set(nThreads); SysRefresh() //-- Finaliza a regua de processamento
						oAtuParc2:cCaption := STR0099+'SBF'+STR0145; oAtuParc2:Refresh()	 //'Tabela SBF: Threads processadas com sucesso!'
					EndIf
					cTexto += STR0119+PULALINHA //'Ajuste da SBF finalizado!' 
					//���������������������������������������������Ŀ
					//� Atualiza o log de processamento			    �
					//�����������������������������������������������
					ProcLogAtu("MENSAGEM","Termino SBF","Termino SBF")				
				Else
					cTexto += STR0118+PULALINHA //' Tabela SBF: Nenhum registro processado(*). '
				Endif
			Else
				cTexto += STR0099+'SBF'+STR0100+PULALINHA //' Tabela '#': Ajuste desabilitado via MV_UPDEST8'
			EndIf
			
			//����������������������������������
			//� Realiza o ajuste na tabela SBK �
			//����������������������������������
			If lExecSBK 
				//���������������������������������������������Ŀ
				//� Atualiza o log de processamento			    �
				//�����������������������������������������������
				ProcLogAtu("MENSAGEM","Iniciando SBK","Iniciando SBK")			

				//����������������������������������������Ŀ
				//� Atualiza variaveis da janela principal �
				//������������������������������������������
				If !IsInUpdate .And. !lWizard
					oMtTotal:Set(++nAtuTotal); SysRefresh()
					cItemAju           := STR0122; oItemAju:Refresh() //'Andamento do ajuste da tabela de saldos iniciais por lote:'
					nAtuParci          := 0
					oMtParci:nTotal    := nThreads
					oAtuParc1:cCaption := STR0123; oAtuParc1:Refresh() //'Varrendo tabela SBK...'
					oAtuParc2:cCaption := ''; oAtuParc2:Refresh()
					oAtuParc3:cCaption := ''; oAtuParc3:Refresh()
				EndIf	
				aThreads:= {}
				nThreads:= nThreadsAnt
				cAlias 	:= GetNextAlias()
				cQuery 	:= "SELECT DISTINCT SBK.BK_COD "
				cQuery 	+= "FROM "+RetSqlName("SBK")+" SBK "
				cQuery  += "JOIN "+RetSqlName('SB1')+" SB1 "
				cQuery  += "ON SB1.B1_FILIAL = '"+xFilial('SB1')+"' "
				cQuery  += " AND SB1.B1_COD = SBK.BK_COD "
				cQuery  += " AND SB1.B1_RASTRO = 'L' "
				cQuery  += " AND SB1.D_E_L_E_T_ = ' ' "
				cQuery  += "WHERE SBK.BK_FILIAL = '"+xFilial("SBK")+"' " 
				cQuery  += " AND SBK.BK_LOTECTL <> ' ' "
				cQuery  += " AND SBK.BK_NUMLOTE <> ' ' "
				cQuery  += " AND SBK.D_E_L_E_T_ = ' ' "
				cQuery  += "ORDER BY SBK.BK_COD "
				
				If !IsInUpdate .And. !lWizard
					oAtuParc2:cCaption := STR0075; oAtuParc2:Refresh() //'Selecionando Registros...'
				EndIf
				cQuery := ChangeQuery(cQuery)
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
				
				aProds := {}
				(cAlias)->(dbGoTop())
				While (cAlias)->(!Eof())
					AADD( aProds, (cAlias)->BK_COD )
					(cAlias)->(dbSkip())
				Enddo
				(cAlias)->(dbCloseArea())
				
				aRange := {}
				If Len( aProds ) > 0
					nTotRegs   := Len( aProds )
					nTotThread := Int( nTotRegs / nThreads )
					For nY := 1 To nTotRegs
						nPosIni := nY
						nPosFim := IIf( (nY + nTotThread) > nTotRegs, nTotRegs, (nY + nTotThread) )
						AADD( aRange, {aProds[nPosIni], aProds[nPosFim]} )
						nY := nPosFim
					Next nY
				Endif
				
				If Len( aRange ) > 0
					For nY := 1 To Len( aRange )
						cProdIni := aRange[nY][1]
						cProdFim := aRange[nY][2]
						cJobAux	 := "SBK"+StrZero(nY,2)
						cJobFile := cStartPath + CriaTrab(Nil,.F.)+".job"	//Informacoes do semaforo
						cThread	 := "WzThrSBK"
						AADD(aThreads,{cJobFile,cJobAux,cThread,cProdIni,cProdFim})
						PutGlbValue(cJobAux,"0")	//Inicializa variavel global de controle de thread
						GlbUnLock()
						If !lWizard
							ConOut(STR0112+cJobAux+STR0113+Trim(cProdIni)+STR0114+Trim(cProdFim))
						Endif
						StartJob(cThread,GetEnvServer(),lStartJob,aFilSBK,IsInUpdate,cEmpAnt,cFilAnt,cJobFile,cJobAux,cProdIni,cProdFim)
						If !IsInUpdate .And. !lWizard
							oMtParci:Set(++nAtuParci); SysRefresh()
							oAtuParc2:cCaption := STR0112+cJobAux; oAtuParc2:Refresh()	 //'Inicializando Job #'
						EndIf
					Next nY
					If !IsInUpdate .And. !lWizard
						oAtuParc2:cCaption := STR0076; oAtuParc2:Refresh() //'Processando o ajuste...'
					EndIf
					CtrlMThrd(lQuery,aThreads,cEmpAnt,cFilAnt,aFilSBK,IsInUpdate,lWizard)
					If !IsInUpdate .And. !lWizard
						oMtParci:Set(nThreads); SysRefresh() //-- Finaliza a regua de processamento
						oAtuParc2:cCaption := STR0099+'SBK'+STR0145; oAtuParc2:Refresh()	 //'Tabela SBK: Threads processadas com sucesso!'
					EndIf
					cTexto += STR0126+PULALINHA //'Ajuste da SBK finalizado!'
					//���������������������������������������������Ŀ
					//� Atualiza o log de processamento			    �
					//�����������������������������������������������
					ProcLogAtu("MENSAGEM","Termino SBK","Termino SBK")									
				Else
					cTexto += STR0125+PULALINHA //' Tabela SBK: Nenhum registro processado. '
				Endif
			Else
				cTexto += STR0099+'SBK'+STR0100+PULALINHA //' Tabela '#': Ajuste desabilitado via MV_UPDEST8'
			EndIf
			
			//����������������������������������
			//� Realiza o ajuste na tabela SDA �
			//����������������������������������
			If lExecSDA
				//���������������������������������������������Ŀ
				//� Atualiza o log de processamento			    �
				//�����������������������������������������������
				ProcLogAtu("MENSAGEM","Iniciando SDA","Iniciando SDA")			

				//����������������������������������������Ŀ
				//� Atualiza variaveis da janela principal �
				//������������������������������������������
				If !IsInUpdate .And. !lWizard
					oMtTotal:Set(++nAtuTotal); SysRefresh()
					cItemAju           := STR0127; oItemAju:Refresh() //'Andamento do ajuste da tabela de saldos a endere�ar:'
					nAtuParci          := 0
					oMtParci:nTotal    := nThreads
					oAtuParc1:cCaption := STR0128; oAtuParc1:Refresh() //'Varrendo tabela SDA...'
					oAtuParc2:cCaption := ''; oAtuParc2:Refresh()
					oAtuParc3:cCaption := ''; oAtuParc3:Refresh()
				EndIf	
				aThreads:= {}
				nThreads:= nThreadsAnt
				cAlias 	:= GetNextAlias()
				cQuery 	:= "SELECT DISTINCT SDA.DA_PRODUTO "
				cQuery 	+= "FROM "+RetSqlName("SDA")+" SDA "
				cQuery  += "JOIN "+RetSqlName('SB1')+" SB1 "
				cQuery  += "ON SB1.B1_FILIAL = '"+xFilial('SB1')+"' "
				cQuery  += " AND SB1.B1_COD = SDA.DA_PRODUTO "
				cQuery  += " AND SB1.B1_RASTRO = 'L' "
				cQuery  += " AND SB1.D_E_L_E_T_ = ' ' "
				cQuery  += "WHERE SDA.DA_FILIAL = '"+xFilial("SDA")+"' " 
				cQuery  += " AND SDA.DA_LOTECTL <> ' ' "
				cQuery  += " AND SDA.DA_NUMLOTE <> ' ' "
				cQuery  += " AND SDA.D_E_L_E_T_ = ' ' "
				cQuery  += "ORDER BY SDA.DA_PRODUTO "
				
				If !IsInUpdate .And. !lWizard
					oAtuParc2:cCaption := STR0075; oAtuParc2:Refresh() //'Selecionando Registros...'
				EndIf
				cQuery := ChangeQuery(cQuery)
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
				
				aProds := {}
				(cAlias)->(dbGoTop())
				While (cAlias)->(!Eof())
					AADD( aProds, (cAlias)->DA_PRODUTO )
					(cAlias)->(dbSkip())
				Enddo
				(cAlias)->(dbCloseArea())
				
				aRange := {}
				If Len( aProds ) > 0
					nTotRegs   := Len( aProds )
					nTotThread := Int( nTotRegs / nThreads )
					For nY := 1 To nTotRegs
						nPosIni := nY
						nPosFim := IIf( (nY + nTotThread) > nTotRegs, nTotRegs, (nY + nTotThread) )
						AADD( aRange, {aProds[nPosIni], aProds[nPosFim]} )
						nY := nPosFim
					Next nY
				Endif
				
				If Len( aRange ) > 0
					For nY := 1 To Len( aRange )
						cProdIni := aRange[nY][1]
						cProdFim := aRange[nY][2]
						cJobAux	 := "SDA"+StrZero(nY,2)
						cJobFile := cStartPath + CriaTrab(Nil,.F.)+".job"	//Informacoes do semaforo
						cThread	 := "WhThrSDA"
						AADD(aThreads,{cJobFile,cJobAux,cThread,cProdIni,cProdFim})
						PutGlbValue(cJobAux,"0")	//Inicializa variavel global de controle de thread
						GlbUnLock()
						If !lWizard
							ConOut(STR0112+cJobAux+STR0113+Trim(cProdIni)+STR0114+Trim(cProdFim))
						Endif
						StartJob(cThread,GetEnvServer(),lStartJob,aFilSDA,IsInUpdate,cEmpAnt,cFilAnt,cJobFile,cJobAux,cProdIni,cProdFim)
						If !IsInUpdate .And. !lWizard
							oMtParci:Set(++nAtuParci); SysRefresh()
							oAtuParc2:cCaption := STR0112+cJobAux; oAtuParc2:Refresh()	 //'Inicializando Job #'
						EndIf
					Next nY
					If !IsInUpdate .And. !lWizard
						oAtuParc2:cCaption := STR0076; oAtuParc2:Refresh() //'Processando o ajuste...'
					EndIf
					CtrlMThrd(lQuery,aThreads,cEmpAnt,cFilAnt,aFilSDA,IsInUpdate,lWizard)
					If !IsInUpdate .And. !lWizard
						oMtParci:Set(nThreads); SysRefresh() //-- Finaliza a regua de processamento
						oAtuParc2:cCaption := STR0099+'SDA'+STR0145; oAtuParc2:Refresh()	 //'Tabela SDA: Threads processadas com sucesso!'
					EndIf
					cTexto += STR0131+PULALINHA //'Ajuste da SDA finalizado!'
					//���������������������������������������������Ŀ
					//� Atualiza o log de processamento			    �
					//�����������������������������������������������
					ProcLogAtu("MENSAGEM","Termino SDA","Termino SDA")									
				Else
					cTexto += STR0130+PULALINHA //' Tabela SDA: Nenhum registro processado. '
				Endif
			Else
				cTexto += STR0099+'SDA'+STR0100+PULALINHA //' Tabela '#': Ajuste desabilitado via MV_UPDEST8'
			EndIf
			
			//����������������������������������
			//� Realiza o ajuste na tabela SDB �
			//����������������������������������
			If lExecSDB
				//���������������������������������������������Ŀ
				//� Atualiza o log de processamento			    �
				//�����������������������������������������������
				ProcLogAtu("MENSAGEM","Iniciando SDB","Iniciando SDB")			

				//����������������������������������������Ŀ
				//� Atualiza variaveis da janela principal �
				//������������������������������������������
				If !IsInUpdate .And. !lWizard
					oMtTotal:Set(++nAtuTotal); SysRefresh()
					cItemAju           := STR0132; oItemAju:Refresh() //'Andamento do ajuste da tabela de movimentos por lote:'
					nAtuParci          := 0
					oMtParci:nTotal    := nThreads
					oAtuParc1:cCaption := STR0133; oAtuParc1:Refresh() //'Varrendo tabela SDB...'
					oAtuParc2:cCaption := ''; oAtuParc2:Refresh()
					oAtuParc3:cCaption := ''; oAtuParc3:Refresh()
				EndIf	
				aThreads:= {}
				nThreads:= nThreadsAnt
				cAlias 	:= GetNextAlias()
				cQuery 	:= "SELECT DISTINCT SDB.DB_PRODUTO "
				cQuery 	+= "FROM "+RetSqlName("SDB")+" SDB "
				cQuery  += "JOIN "+RetSqlName('SB1')+" SB1 "
				cQuery  += "ON SB1.B1_FILIAL = '"+xFilial('SB1')+"' "
				cQuery  += " AND SB1.B1_COD = SDB.DB_PRODUTO "
				cQuery  += " AND SB1.B1_RASTRO = 'L' "
				cQuery  += " AND SB1.D_E_L_E_T_ = ' ' "
				cQuery  += "WHERE SDB.DB_FILIAL = '"+xFilial("SDB")+"' " 
				cQuery  += " AND SDB.DB_LOTECTL <> ' ' "
				cQuery  += " AND SDB.DB_NUMLOTE <> ' ' "
				cQuery  += " AND SDB.D_E_L_E_T_ = ' ' "
				cQuery  += "ORDER BY SDB.DB_PRODUTO "
				
				If !IsInUpdate .And. !lWizard
					oAtuParc2:cCaption := STR0075; oAtuParc2:Refresh() //'Selecionando Registros...'
				EndIf
				cQuery := ChangeQuery(cQuery)
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
				
				aProds := {}
				(cAlias)->(dbGoTop())
				While (cAlias)->(!Eof())
					AADD( aProds, (cAlias)->DB_PRODUTO )
					(cAlias)->(dbSkip())
				Enddo
				(cAlias)->(dbCloseArea())
				
				aRange := {}
				If Len( aProds ) > 0
					nTotRegs   := Len( aProds )
					nTotThread := Int( nTotRegs / nThreads )
					For nY := 1 To nTotRegs
						nPosIni := nY
						nPosFim := IIf( (nY + nTotThread) > nTotRegs, nTotRegs, (nY + nTotThread) )
						AADD( aRange, {aProds[nPosIni], aProds[nPosFim]} )
						nY := nPosFim
					Next nY
				Endif
				
				If Len( aRange ) > 0
					For nY := 1 To Len( aRange )
						cProdIni := aRange[nY][1]
						cProdFim := aRange[nY][2]
						cJobAux	 := "SDB"+StrZero(nY,2)
						cJobFile := cStartPath + CriaTrab(Nil,.F.)+".job"	//Informacoes do semaforo
						cThread	 := "WhThrSDB"
						AADD(aThreads,{cJobFile,cJobAux,cThread,cProdIni,cProdFim})
						PutGlbValue(cJobAux,"0")	//Inicializa variavel global de controle de thread
						GlbUnLock()
						If !lWizard
							ConOut(STR0112+cJobAux+STR0113+Trim(cProdIni)+STR0114+Trim(cProdFim))
						Endif
						StartJob(cThread,GetEnvServer(),lStartJob,aFilSDB,IsInUpdate,cEmpAnt,cFilAnt,cJobFile,cJobAux,cProdIni,cProdFim)
						If !IsInUpdate .And. !lWizard
							oMtParci:Set(++nAtuParci); SysRefresh()
							oAtuParc2:cCaption := STR0112+cJobAux; oAtuParc2:Refresh()	 //'Inicializando Job #'
						EndIf
					Next nY
					If !IsInUpdate .And. !lWizard
						oAtuParc2:cCaption := STR0076; oAtuParc2:Refresh() //'Processando o ajuste...'
					EndIf
					CtrlMThrd(lQuery,aThreads,cEmpAnt,cFilAnt,aFilSDB,IsInUpdate,lWizard)
					If !IsInUpdate .And. !lWizard
						oMtParci:Set(nThreads); SysRefresh() //-- Finaliza a regua de processamento
						oAtuParc2:cCaption := STR0099+'SDB'+STR0145; oAtuParc2:Refresh()	 //'Tabela SDB: Threads processadas com sucesso!'
					EndIf
					cTexto += STR0144+PULALINHA //'Ajuste da SDB finalizado!'
					//���������������������������������������������Ŀ
					//� Atualiza o log de processamento			    �
					//�����������������������������������������������
					ProcLogAtu("MENSAGEM","Termino SDB","Termino SDB")									
				Else
					cTexto += STR0135+PULALINHA //' Tabela SDB: Nenhum registro processado. '
				Endif
			Else
				cTexto += STR0099+'SDB'+STR0100+PULALINHA //' Tabela '#': Ajuste desabilitado via MV_UPDEST8'
			EndIf
			
		EndIf
		
	EndIf
	
	cTexto += PULALINHA
	
	//�����������������������������������������������������������������������������������������������������������
	//� Verifica se o parametro MV_LOTEUNI foi criado para esta filial especifica (serah posteriormente apagado)�
	//�����������������������������������������������������������������������������������������������������������
	If SX6->(dbSeek(cFilAnt+'MV_LOTEUNI', .F.)) .And. aScan(aRecnoSX6, SX6->(Recno())) == 0
		aAdd(aRecnoSX6, {AllTrim(SM0->M0_CODFIL+'-'+SM0->M0_FILIAL), SX6->(Recno())})
	EndIf
Next nX
  
cTexto += PULALINHA

cTexto += STR0072+DtoC(Date())+STR0042+SubStr(Time(), 1, 5) //'>> Ajuste finalizado em '###', as '

//�����������������������������������Ŀ
//� Atualiza o log de processamento   �
//�������������������������������������
If !lWizard
	ProcLogAtu("FIM")
EndIF	

//�����������������������Ŀ
//� Exibe o LOG do ajuste �
//�������������������������
cLogUpdate := cTexto

If lWizard
	RpcClearEnv(.T.)
	Return cTexto
Endif

Return Nil

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �WizLTSB8 �Autor  �Microsiga           � Data �  01/11/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Funcao WizLTSB8                                           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function WizLTSB8(cTexto, aFilSB8, IsInUpdate, lWizard)

Local aCampos    := {}
Local aStruSB8   := SB8->(dbStruct())
Local cQuery     := ''
Local cAliasTRB  := ''
Local lUpdEst08  := ExistBlock('PEUPDE08')
Local nX         := 0
Local nContador  := 0
Local nRecsSB8   := nTotCont := Max(1, SB8->(LastRec()))
Local nTotCont   := 0
#IFNDEF TOP
	Local aRecDelSB8  := {}
	Private cCondicao := .F.
#ENDIF

Default lWizard  := .F.

//����������������������������������������Ŀ
//� Atualiza variaveis da janela principal �
//������������������������������������������
If !IsInUpdate .And. !lWizard
	oMtTotal:Set(++nAtuTotal); SysRefresh()
	cItemAju           := STR0073; oItemAju:Refresh() //'Andamento do ajuste da tabela de saldos por lote:'
	nAtuParci          := 0
	oMtParci:nTotal    := nRecsSB8
	oAtuParc1:cCaption := STR0074; oAtuParc1:Refresh() //'Varrendo tabela SB8...'
	oAtuParc2:cCaption := ''; oAtuParc2:Refresh()
	oAtuParc3:cCaption := ''; oAtuParc3:Refresh()
EndIf	


If aScan(aFilSB8, SB8->(xFilial('SB8'))) == 0
	aAdd(aFilSB8, SB8->(xFilial('SB8')))
	dbSelectArea('SB8')
	dbSetOrder(3) //-- B8_FILIAL+B8_PRODUTO+B8_LOCAL+B8_LOTECTL+B8_NUMLOTE+DTOS(B8_DTVALID)
	#IFDEF TOP
		cAliasTRB := GetNextAlias() //'TRBSB8'
		//����������������Ŀ
		//� Campos da VIEW �
		//������������������
		cQuery := "SELECT "
		cQuery += " SB8.B8_FILIAL,"
		cQuery += " SB8.B8_PRODUTO,"
		cQuery += " SB8.B8_LOCAL,"
		cQuery += " SB8.B8_LOTECTL,"
		cQuery += " SUM(SB8.B8_QTDORI) B8_QTDORI,"
		cQuery += " SUM(SB8.B8_QTDORI2) B8_QTDORI2,"
		cQuery += " MIN(SB8.B8_DATA) B8_DATA,"
		cQuery += " MAX(SB8.B8_DTVALID) B8_DTVALID,"
		cQuery += " SUM(SB8.B8_SALDO) B8_SALDO,"
		cQuery += " SUM(SB8.B8_SALDO2) B8_SALDO2,"
		cQuery += " SUM(SB8.B8_EMPENHO) B8_EMPENHO,"
		cQuery += " SUM(SB8.B8_EMPENH2) B8_EMPENH2,"
		cQuery += " SUM(SB8.B8_QEMPPRE) B8_QEMPPRE,"
		cQuery += " SUM(SB8.B8_QEPRE2) B8_QEPRE2,"
		cQuery += " SUM(SB8.B8_QACLASS) B8_QACLASS,"
		cQuery += " SUM(SB8.B8_QACLAS2) B8_QACLAS2,"
		cQuery += " MAX(SB8.B8_POTENCI) B8_POTENCI,"
		cQuery += " MAX(SB8.B8_PRCLOT) B8_PRCLOT "
		cQuery += "FROM "+RetSqlName('SB8')+" SB8 "
		
		//��������������������������������Ŀ
		//� Condicoes JOIN entre SB8 e SB1 �
		//����������������������������������
		cQuery += "JOIN "+RetSqlName('SB1')+" SB1 "
		cQuery += "ON SB1.B1_FILIAL = '"+xFilial('SB1')+"'"
		cQuery += " AND SB1.B1_COD = SB8.B8_PRODUTO"
		cQuery += " AND SB1.B1_RASTRO = 'L'"
		cQuery += " AND SB1.D_E_L_E_T_  = ' ' "
		
		//���������������Ŀ
		//� Condicoes SB8 �
		//�����������������
		cQuery += "WHERE SB8.B8_FILIAL = '"+xFilial('SB8')+"'"
		If !Empty(cFilProd)
			cQuery += " AND SB8.B8_PRODUTO IN ("+cFilProd+")"
		EndIf	
		cQuery += " AND SB8.D_E_L_E_T_  = ' ' "
		
		//�������������������������������Ŀ
		//� Clausulas GROUP BY e ORDER BY �
		//���������������������������������
		cQuery += "GROUP BY SB8.B8_FILIAL, SB8.B8_PRODUTO, SB8.B8_LOCAL, SB8.B8_LOTECTL "
		cQuery += "ORDER BY SB8.B8_FILIAL, SB8.B8_PRODUTO, SB8.B8_LOCAL, SB8.B8_LOTECTL"
		
		If !IsInUpdate .And. !lWizard
			oAtuParc2:cCaption := STR0075; oAtuParc2:Refresh() //'Selecionando Registros...'
		EndIf	
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T., 'TOPCONN', TcGenQry(,, cQuery), cAliasTRB)
		For nX := 1 To Len(aStruSB8)
			If !aStruSB8[nX, 2]$'CM' .And. !(FieldPos(aStruSB8[nX, 1])==0)
				TcSetField(cAliasTRB, aStruSB8[nX, 1], aStruSB8[nX, 2], aStruSB8[nX, 3], aStruSB8[nX, 4])
			EndIf
		Next nX
		dbSelectArea(cAliasTRB)
		dbGoTop()
	#ELSE
		cAliasTRB := 'SB8'
		dbSeek(xFilial('SB8'), .F.)
	#ENDIF
	
	If !IsInUpdate .And. !lWizard
		oAtuParc2:cCaption := STR0076; oAtuParc2:Refresh() //'Processando o ajuste...'
	EndIf	
	Do While !(cAliasTRB)->(Eof())
		
		nContador ++
		If !IsInUpdate .And. !lWizard
			oMtParci:Set(++nAtuParci); SysRefresh()
			oAtuParc2:cCaption := AllTrim(Str(nContador))+If(nContador>1,STR0077, STR0078); oAtuParc2:Refresh()	 //' registros processados...'###' registro processado...'
		EndIf	
	
		//�����������������������������������������������������������������������Ŀ
		//� Processa somente produtos com controle de rastreabilidade igual a "L" �
		//�������������������������������������������������������������������������
		#IFNDEF TOP
			If !Rastro(SB8->B8_PRODUTO, 'L')
				SB8->(dbSkip())
				Loop
			EndIf
		#ENDIF
		
		//������������������������������������������������������������������������Ŀ
		//� Guarda em array o conteudo de todos os campos deste Produto+Local+Lote �
		//��������������������������������������������������������������������������
		aCampos := Array(17)
		#IFNDEF TOP
			aFill(aCampos, CtoD('  /  /  '), 4, 2)
			aFill(aCampos, 0, 6, 12)
			aRecDelSB8 := {SB8->(Recno())}
			cCondicao  := '!SB8->(Eof()) .And. "'+SB8->(B8_FILIAL+B8_PRODUTO+B8_LOCAL+B8_LOTECTL)+'"==SB8->(B8_FILIAL+B8_PRODUTO+B8_LOCAL+B8_LOTECTL)'
		#ENDIF
		
		//����������������������������Ŀ
		//� Campos com conteudos fixos �
		//������������������������������
		aCampos[01] := (cAliasTRB)->B8_PRODUTO
		aCampos[02] := (cAliasTRB)->B8_LOCAL
		aCampos[03] := (cAliasTRB)->B8_LOTECTL
		
		//������������������������������������������Ŀ
		//� Campos com conteudos a serem aglutinados �
		//��������������������������������������������
		#IFDEF TOP
			aCampos[04] := (cAliasTRB)->B8_DATA
			aCampos[05] := (cAliasTRB)->B8_DTVALID
			aCampos[06] := (cAliasTRB)->B8_QTDORI
			aCampos[07] := (cAliasTRB)->B8_QTDORI2
			aCampos[08] := (cAliasTRB)->B8_SALDO
			aCampos[09] := (cAliasTRB)->B8_SALDO2
			aCampos[10] := (cAliasTRB)->B8_EMPENHO
			aCampos[11] := (cAliasTRB)->B8_EMPENH2
			aCampos[12] := (cAliasTRB)->B8_QEMPPRE
			aCampos[13] := (cAliasTRB)->B8_QEPRE2
			aCampos[14] := (cAliasTRB)->B8_QACLASS
			aCampos[15] := (cAliasTRB)->B8_QACLAS2
			aCampos[16] := (cAliasTRB)->B8_POTENCI
			aCampos[17] := (cAliasTRB)->B8_PRCLOT
		#ELSE
			If &cCondicao
				Do While &cCondicao
					aCampos[04] := If(Empty(aCampos[04]), (cAliasTRB)->B8_DATA, Min((cAliasTRB)->B8_DATA, aCampos[04]))
					aCampos[05] := Max((cAliasTRB)->B8_DTVALID, aCampos[05])
					aCampos[06] += (cAliasTRB)->B8_QTDORI
					aCampos[07] += (cAliasTRB)->B8_QTDORI2
					aCampos[08] += (cAliasTRB)->B8_SALDO
					aCampos[09] += (cAliasTRB)->B8_SALDO2
					aCampos[10] += (cAliasTRB)->B8_EMPENHO
					aCampos[11] += (cAliasTRB)->B8_EMPENH2
					aCampos[12] += (cAliasTRB)->B8_QEMPPRE
					aCampos[13] += (cAliasTRB)->B8_QEPRE2
					aCampos[14] += (cAliasTRB)->B8_QACLASS
					aCampos[15] += (cAliasTRB)->B8_QACLAS2
					aCampos[16] := Max((cAliasTRB)->B8_POTENCI, aCampos[16])
					aCampos[17] := Max((cAliasTRB)->B8_PRCLOT, aCampos[17])
					aAdd(aRecDelSB8, SB8->(Recno()))
					SB8->(dbSkip())
				EndDo
			EndIf
		#ENDIF
		

			//��������������������������������������������������Ŀ
			//� Deleta os registros com deste Produto+Local+Lote �
			//����������������������������������������������������
			#IFDEF TOP
					cQuery  := "DELETE FROM "+RetSqlName('SB8')+" "
					cQuery  += "WHERE B8_FILIAL = '"+xFilial('SB8')+"'"
					cQuery  += " AND B8_PRODUTO = '"+aCampos[01]+"'"
					cQuery  += " AND B8_LOCAL = '"  +aCampos[02]+"'"
					cQuery  += " AND B8_LOTECTL = '"+aCampos[03]+"'"
					cQuery  += " AND D_E_L_E_T_ = ' '"
					TCSqlExec(cQuery)
					SB8->(dbGoto(Recno()))
			#ELSE
				For nX := 1 to Len(aRecDelSB8)
					SB8->(dbGoto(aRecDelSB8[nX]))
					RecLock('SB8', .F.)
					dbDelete()
					MsUnlock()
				Next nX
			#ENDIF
			
			//�������������������������������������������������������������������������������Ŀ
			//� Inclui registro unico deste Produto+Local+Lote com as quantidades aglutinadas �
			//���������������������������������������������������������������������������������
			RecLock('SB8', .T.)
			Replace B8_FILIAL  With xFilial('SB8'), ; //-- Filial do Sistema
					B8_PRODUTO With aCampos[01], ; //-- Codigo do Produto
					B8_LOCAL   With aCampos[02], ; //-- Armazem
					B8_LOTECTL With aCampos[03], ; //-- Lote
					B8_DATA    With aCampos[04], ; //-- Data da Criacao do Lote
					B8_DTVALID With aCampos[05], ; //-- Data de Validade do Lote
					B8_QTDORI  With aCampos[06], ; //-- Quantidade Original
					B8_QTDORI2 With aCampos[07], ; //-- Quantidade Original 2a UM
					B8_SALDO   With aCampos[08], ; //-- Saldo do Lote
					B8_SALDO2  With aCampos[09], ; //-- Saldo do Lote 2a UM
					B8_EMPENHO With aCampos[10], ; //-- Empenho do Lote
					B8_EMPENH2 With aCampos[11], ; //-- Empenho do Lote 2a UM
					B8_QEMPPRE With aCampos[12], ; //-- Quantidade Empenhada Prev
					B8_QEPRE2  With aCampos[13], ; //-- Qtde Emp. Prevista 2a UM
					B8_QACLASS With aCampos[14], ; //-- Quantidade a Distribuir
					B8_QACLAS2 With aCampos[15], ; //-- Qtde a Distribuir 2a UM
					B8_POTENCI With aCampos[16], ; //-- Potencia do Lote
					B8_PRCLOT  With aCampos[17], ; //-- Preco do Lote
					B8_DOC     With 'AJUSTE'   , ; //-- Numero do Documento
					B8_SERIE   With 'UNI'      , ; //-- Serie do Documento
					B8_ORIGLAN With 'MI'           //-- Origem do Lancamento
			If lUpdEst08
				ExecBlock('PEUPDE08', .F., .F., {'SB8'})
			EndIf
			MsUnlock()
		(cAliasTRB)->(dbSkip())
	EndDo
	
	If !IsInUpdate .And. !lWizard
		oMtParci:Set(nTotCont); SysRefresh() //-- Finaliza a regua de processamento
	EndIf	
	
	#IFDEF TOP
		If Select(cAliasTRB) > 0
			dbSelectArea(cAliasTRB)
			dbCloseArea()
		EndIf
		//����������������������������������������������������������Ŀ
		//� A tabela eh fechada para restaurar o buffer da aplicacao �
		//������������������������������������������������������������
		dbSelectArea('SB8')
		dbCloseArea()
		ChkFile('SB8', .T.)
	#ENDIF
	cTexto += STR0079+AllTrim(Str(nContador))+STR0080+PULALINHA //' Tabela SB8: '###' registro(s) processado(s). '
Else
	cTexto += STR0081+PULALINHA //' Tabela SB8: Nenhum registro processado(*). '
	cTexto += STR0082+PULALINHA //' Obs.: Esta tabela possui acesso compartilhado, situacao em que o ajuste eh feito apenas 1x por empresa.'
EndIf

//����������������������������������������Ŀ
//� Atualiza variaveis da janela principal �
//������������������������������������������
If !IsInUpdate .And. !lWizard
	oAtuParc1:cCaption := STR0083; oAtuParc1:Refresh() //'Ajuste da tabela SB8 finalizado!'
	oAtuParc2:cCaption := ''; oAtuParc2:Refresh()
EndIf	

Return Nil

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �WizLTSD5 � Autor �Fernando J. Siquini    � Data �08/01/07  ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Funcao de processamento do ajuste da tabela SD5            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � WizLtUni                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function WizLTSD5(cTexto, aFilSD5, IsInUpdate, lWizard)

Local aCampos    := {}
Local aStruSD5   := SD5->(dbStruct())
Local cQuery     := ''
Local cAliasTRB  := ''
Local lUpdEst08  := ExistBlock('PEUPDE08')
Local nX         := 0
Local nContador  := 0
Local nRecsSD5   := nTotCont := Max(1, SD5->(LastRec()))
#IFNDEF TOP
	Local aRecDelSD5  := {}
	Private cCondicao := .F.
#ENDIF

Default lWizard  := .F.

//����������������������������������������Ŀ
//� Atualiza variaveis da janela principal �
//������������������������������������������
If !IsInUpdate .And. !lWizard
	oMtTotal:Set(++nAtuTotal); SysRefresh()
	cItemAju           := STR0084; oItemAju:Refresh() //'Andamento do ajuste da tabela de movimentos por lote:'
	nAtuParci          := 0
	oMtParci:nTotal    := nRecsSD5
	oAtuParc1:cCaption := STR0085; oAtuParc1:Refresh() //'Varrendo tabela SD5...'
	oAtuParc2:cCaption := ''; oAtuParc2:Refresh()
	oAtuParc3:cCaption := ''; oAtuParc3:Refresh()
EndIf	

If aScan(aFilSD5, SD5->(xFilial('SD5'))) == 0
	aAdd(aFilSD5, SD5->(xFilial('SD5')))
	dbSelectArea('SD5')
	dbSetOrder(3) //-- D5_FILIAL+D5_NUMSEQ+D5_PRODUTO+D5_LOCAL+D5_LOTECTL+D5_NUMLOTE
	#IFDEF TOP
		cAliasTRB := GetNextAlias() //'TRBSD5'
		
		//����������������Ŀ
		//� Campos da VIEW �
		//������������������
		cQuery := "SELECT "
		cQuery += " SD5.D5_FILIAL,"
		cQuery += " SD5.D5_NUMSEQ,"
		cQuery += " SD5.D5_PRODUTO,"
		cQuery += " SD5.D5_LOCAL,"
		cQuery += " SD5.D5_LOTECTL,"
		cQuery += " SD5.D5_ORIGLAN,"
		cQuery += " SD5.D5_DOC,"
		cQuery += " SD5.D5_SERIE,"
		cQuery += " SD5.D5_OP," 
		cQuery += " SD5.D5_ESTORNO,"
		cQuery += " SD5.D5_DATA,"
		cQuery += " MAX(SD5.D5_DTVALID) D5_DTVALID,"
		cQuery += " MAX(SD5.D5_POTENCI) D5_POTENCI,"
		cQuery += " SUM(SD5.D5_QUANT) D5_QUANT,"
		cQuery += " SUM(SD5.D5_QTSEGUM) D5_QTSEGUM "
		cQuery += "FROM "+RetSqlName('SD5')+" SD5 "
		
		//��������������������������������Ŀ
		//� Condicoes JOIN entre SD5 e SB1 �
		//����������������������������������
		cQuery += "JOIN "+RetSqlName('SB1')+" SB1 "
		cQuery += "ON SB1.B1_FILIAL = '"+xFilial('SB1')+"'"
		cQuery += " AND SB1.B1_COD = SD5.D5_PRODUTO"
		cQuery += " AND SB1.B1_RASTRO = 'L'"
		cQuery += " AND SB1.D_E_L_E_T_  = ' ' "
		
		//���������������Ŀ
		//� Condicoes SD5 �
		//�����������������
		cQuery += "WHERE SD5.D5_FILIAL = '"+xFilial('SD5')+"'"
		If !Empty(cFilProd)
			cQuery += " AND SD5.D5_PRODUTO IN ("+cFilProd+")"
		EndIf	
		cQuery += " AND SD5.D_E_L_E_T_  = ' ' "
		
		//�������������������������������Ŀ
		//� Clausulas GROUP BY e ORDER BY �
		//���������������������������������
		cQuery += " GROUP BY SD5.D5_FILIAL, SD5.D5_NUMSEQ, SD5.D5_PRODUTO, SD5.D5_LOCAL, SD5.D5_LOTECTL, SD5.D5_ORIGLAN, SD5.D5_DOC, SD5.D5_SERIE, SD5.D5_OP, SD5.D5_ESTORNO, SD5.D5_DATA "
		cQuery += " ORDER BY SD5.D5_FILIAL, SD5.D5_NUMSEQ, SD5.D5_PRODUTO, SD5.D5_LOCAL, SD5.D5_LOTECTL, SD5.D5_ORIGLAN, SD5.D5_DOC, SD5.D5_SERIE, SD5.D5_OP, SD5.D5_ESTORNO, SD5.D5_DATA"
		
		If !IsInUpdate .And. !lWizard
			oAtuParc2:cCaption := STR0086; oAtuParc2:Refresh() //'Selecionando registros'
		EndIf	
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T., 'TOPCONN', TcGenQry(,, cQuery), cAliasTRB)
		For nX := 1 To Len(aStruSD5)
			If !aStruSD5[nX, 2]$'CM' .And. !(FieldPos(aStruSD5[nX, 1])==0)
				TcSetField(cAliasTRB, aStruSD5[nX, 1], aStruSD5[nX, 2], aStruSD5[nX, 3], aStruSD5[nX, 4])
			EndIf
		Next nX
		dbSelectArea(cAliasTRB)
		dbGoTop()
	#ELSE
		cAliasTRB := 'SD5'
		cNomArqD5 := CriaTrab('', .F.)
		cIndD5    := 'D5_NUMSEQ+D5_PRODUTO+D5_LOCAL+D5_LOTECTL+D5_ORIGLAN+D5_DOC+D5_SERIE+D5_OP+D5_ESTORNO+DTOS(D5_DATA)'
		cFiltroD5 := 'D5_FILIAL=="'+xFilial('SD5')+'"'
		IndRegua(cAliasTRB, cNomArqD5, cIndD5,, cFiltroD5, STR0075) //'Selecionando Registros...'
		nIndD5    := RetIndex('SD5')
		dbSetIndex(cNomArqD5 + OrdBagExt())
		dbSetOrder(nIndD5 + 1)
		dbGoTop()
	#ENDIF
	
	If !IsInUpdate .And. !lWizard
		oAtuParc2:cCaption := STR0076; oAtuParc2:Refresh() //'Processando o ajuste...'
	EndIf	
	Do While !(cAliasTRB)->(Eof())
		
		nContador ++
		If !IsInUpdate .And. !lWizard
			oMtParci:Set(++nAtuParci); SysRefresh()
			oAtuParc2:cCaption := AllTrim(Str(nContador))+If(nContador>1,STR0077, STR0078); oAtuParc2:Refresh()	 //' registros processados...'###' registro processado...'
		EndIf	
		
		//�����������������������������������������������������������������������Ŀ
		//� Processa somente produtos com controle de rastreabilidade igual a "L" �
		//�������������������������������������������������������������������������
		#IFNDEF TOP
			If !Rastro(SD5->D5_PRODUTO, 'L')
				SD5->(dbSkip())
				Loop
			EndIf
		#ENDIF
		
		//������������������������������������������������������������������������Ŀ
		//� Guarda em array o conteudo de todos os campos deste Produto+Local+Lote �
		//��������������������������������������������������������������������������
		aCampos := Array(14)
		#IFNDEF TOP
			aFill(aCampos, CtoD('  /  /  '), 10, 2)
			aFill(aCampos, 0, 12, 3)
			aRecDelSD5 := {SD5->(Recno())}
			cCondicao  := '!SD5->(Eof()) .And. "'+SD5->(D5_NUMSEQ+D5_PRODUTO+D5_LOCAL+D5_LOTECTL+D5_ORIGLAN+D5_DOC+D5_SERIE+D5_OP+D5_ESTORNO+DTOS(D5_DATA))+'"==SD5->(D5_NUMSEQ+D5_PRODUTO+D5_LOCAL+D5_LOTECTL+D5_ORIGLAN+D5_DOC+D5_SERIE+D5_OP+D5_ESTORNO+DTOS(D5_DATA))'
		#ENDIF
		
		//����������������������������Ŀ
		//� Campos com conteudos fixos �
		//������������������������������
		aCampos[01] := (cAliasTRB)->D5_NUMSEQ
		aCampos[02] := (cAliasTRB)->D5_PRODUTO
		aCampos[03] := (cAliasTRB)->D5_LOCAL
		aCampos[04] := (cAliasTRB)->D5_LOTECTL
		aCampos[05] := (cAliasTRB)->D5_ORIGLAN
		aCampos[06] := (cAliasTRB)->D5_DOC
		aCampos[07] := (cAliasTRB)->D5_SERIE
		aCampos[08] := (cAliasTRB)->D5_OP
		aCampos[09] := (cAliasTRB)->D5_ESTORNO
		aCampos[10] := (cAliasTRB)->D5_DATA
		//������������������������������������������Ŀ
		//� Campos com conteudos a serem aglutinados �
		//��������������������������������������������
		#IFDEF TOP
			aCampos[11] := (cAliasTRB)->D5_DTVALID
			aCampos[12] := (cAliasTRB)->D5_QUANT
			aCampos[13] := (cAliasTRB)->D5_QTSEGUM
			aCampos[14] := (cAliasTRB)->D5_POTENCI
		#ELSE
			If &cCondicao
				Do While &cCondicao
					aCampos[11] := Max((cAliasTRB)->D5_DTVALID, aCampos[11])
					aCampos[12] += (cAliasTRB)->D5_QUANT
					aCampos[13] += (cAliasTRB)->D5_QTSEGUM
					aCampos[14] := Max((cAliasTRB)->D5_POTENCI, aCampos[14])
					aAdd(aRecDelSD5, SD5->(Recno()))
					SD5->(dbSkip())
				EndDo
			EndIf
		#ENDIF
		
			//������������������������������������������������������������������������������������Ŀ
			//� Deleta os registros com deste Numseq+Produto+Local+Lote+OrigLan+Documento+Serie+OP �
			//��������������������������������������������������������������������������������������
			#IFDEF TOP
				cQuery  := "DELETE FROM "+RetSqlName('SD5')+" "
				cQuery  += "WHERE D5_FILIAL = '"+xFilial('SD5')+"'"
				cQuery  += " AND D5_NUMSEQ = '" +aCampos[01]+"'"
				cQuery  += " AND D5_PRODUTO = '"+aCampos[02]+"'"
				cQuery  += " AND D5_LOCAL = '"  +aCampos[03]+"'"
				cQuery  += " AND D5_LOTECTL = '"+aCampos[04]+"'"
				cQuery  += " AND D5_ORIGLAN = '"+aCampos[05]+"'"
				cQuery  += " AND D5_DOC = '"    +aCampos[06]+"'"
				cQuery  += " AND D5_SERIE = '"  +aCampos[07]+"'"
				cQuery  += " AND D5_OP  = '"    +aCampos[08]+"'"
				cQuery  += " AND D5_ESTORNO = '"+aCampos[09]+"'"
				cQuery  += " AND D5_DATA = '"+DTOS(aCampos[10])+"'"
				TCSqlExec(cQuery)
				SD5->(dbGoto(Recno()))
			#ELSE
				For nX := 1 to Len(aRecDelSD5)
					SD5->(dbGoto(aRecDelSD5[nX]))
					RecLock('SD5', .F.)
					dbDelete()
					MsUnlock()
				Next nX
			#ENDIF
			
			//�����������������������������������������������������������������������������������������������������������������Ŀ
			//� Inclui registro unico deste Numseq+Produto+Local+Lote+OrigLan+Documento+Serie+OP com as quantidades aglutinadas �
			//�������������������������������������������������������������������������������������������������������������������
			RecLock('SD5', .T.)
			Replace D5_FILIAL  With xFilial('SD5'), ; //-- Filial do Sistema
					D5_NUMSEQ  With aCampos[01], ; //-- Numero Qequencial
					D5_PRODUTO With aCampos[02], ; //-- Codigo do produto
					D5_LOCAL   With aCampos[03], ; //-- Armazem
					D5_LOTECTL With aCampos[04], ; //-- Lote
					D5_ORIGLAN With aCampos[05], ; //-- Origem do lancamento
					D5_DOC     With aCampos[06], ; //-- Documento
					D5_SERIE   With aCampos[07], ; //-- Serie
					D5_OP      With aCampos[08], ; //-- Ordem de producao
					D5_ESTORNO With aCampos[09], ; //-- Movimento Estornado?
					D5_DATA    With aCampos[10], ; //-- Data de entrada
					D5_DTVALID With aCampos[11], ; //-- Data de validade
					D5_QUANT   With aCampos[12], ; //-- Quantidade
					D5_QTSEGUM With aCampos[13], ; //-- Quantidade 2UM
					D5_POTENCI With aCampos[14]    //-- Potencia do Lote
			If lUpdEst08
				ExecBlock('PEUPDE08', .F., .F., {'SD5'})
			EndIf
			MsUnlock()
		(cAliasTRB)->(dbSkip())
	EndDo
	
	If !IsInUpdate .And. !lWizard
		oMtParci:Set(nTotCont); SysRefresh() //-- Finaliza a regua de processamento
	EndIf	
	
	#IFDEF TOP
		If Select(cAliasTRB) > 0
			dbSelectArea(cAliasTRB)
			dbCloseArea()
		EndIf
		//����������������������������������������������������������Ŀ
		//� A tabela eh fechada para restaurar o buffer da aplicacao �
		//������������������������������������������������������������
		dbSelectArea('SD5')
		dbCloseArea()
		ChkFile('SD5', .T.)
	#ELSE
		If File(cNomArqD5 += OrdBagExt())
			fErase(cNomArqD5)
		EndIf			
	#ENDIF
	
	cTexto += STR0115+AllTrim(Str(nContador))+STR0080+PULALINHA
Else
	cTexto += STR0092+PULALINHA
	cTexto += STR0087+PULALINHA //'	 Obs.: Esta tabela possui acesso compartilhado, situacao em que o ajuste eh feito apenas 1x por empresa.'
EndIf

//����������������������������������������Ŀ
//� Atualiza variaveis da janela principal �
//������������������������������������������
If !IsInUpdate .And. !lWizard
	oAtuParc1:cCaption := STR0088; oAtuParc1:Refresh() //'Ajuste da SD5 finalizado!'
	oAtuParc2:cCaption := ''; oAtuParc2:Refresh()
	oAtuParc3:cCaption := ''; oAtuParc3:Refresh()
EndIf	

Return Nil

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �WizLTSBJ � Autor �Fernando J. Siquini    � Data �08/01/07  ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Funcao de processamento do ajuste da tabela SBJ            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � WizLtUni                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function WizLTSBJ(cTexto, aFilSBJ, IsInUpdate, lWizard)

Local aCampos    := {}
Local aStruSBJ   := SBJ->(dbStruct())
Local cQuery     := ''
Local cAliasTRB  := ''
Local lUpdEst08  := ExistBlock('PEUPDE08')
Local nX         := 0
Local nContador  := 0
Local nRecsSBJ   := nTotCont := Max(1, SBJ->(LastRec()))
#IFNDEF TOP
	Local aRecDelSBJ  := {}
	Private cCondicao := .F.
#ENDIF

Default lWizard  := .F.

//����������������������������������������Ŀ
//� Atualiza variaveis da janela principal �
//������������������������������������������
If !IsInUpdate .And. !lWizard
	oMtTotal:Set(++nAtuTotal); SysRefresh()
	cItemAju           := STR0089; oItemAju:Refresh() //'Andamento do ajuste da tabela de saldos iniciais por lote:'
	nAtuParci          := 0
	oMtParci:nTotal    := nRecsSBJ
	oAtuParc1:cCaption := STR0090; oAtuParc1:Refresh() //'Varrendo tabela SBJ...'
	oAtuParc2:cCaption := ''; oAtuParc2:Refresh()
	oAtuParc3:cCaption := ''; oAtuParc3:Refresh()
EndIf	

If aScan(aFilSBJ, SBJ->(xFilial('SBJ'))) == 0
	aAdd(aFilSBJ, SBJ->(xFilial('SBJ')))
	dbSelectArea('SBJ')
	dbSetOrder(1) //-- BJ_FILIAL+BJ_COD+BJ_LOCAL+BJ_LOTECTL+BJ_NUMLOTE+DTOS(BJ_DATA)
	#IFDEF TOP
		cAliasTRB := GetNextAlias() //'TRBSBJ'
		
		//����������������Ŀ
		//� Campos da VIEW �
		//������������������
		cQuery := "SELECT "
		cQuery += " SBJ.BJ_COD,"
		cQuery += " SBJ.BJ_LOCAL,"
		cQuery += " SBJ.BJ_LOTECTL,"
		cQuery += " SBJ.BJ_DATA,"
		cQuery += " MAX(SBJ.BJ_DTVALID) BJ_DTVALID,"
		cQuery += " SUM(SBJ.BJ_QINI) BJ_QINI,"
		cQuery += " SUM(SBJ.BJ_QISEGUM) BJ_QISEGUM "
		cQuery += "FROM "+RetSqlName('SBJ')+" SBJ "
		
		//��������������������������������Ŀ
		//� Condicoes JOIN entre SBJ e SB1 �
		//����������������������������������
		cQuery += "JOIN "+RetSqlName('SB1')+" SB1 "
		cQuery += "ON SB1.B1_FILIAL = '"+xFilial('SB1')+"'"
		cQuery += " AND SB1.B1_COD = SBJ.BJ_COD"
		cQuery += " AND SB1.B1_RASTRO = 'L'"
		cQuery += " AND SB1.D_E_L_E_T_  = ' ' "
		
		//���������������Ŀ
		//� Condicoes SBJ �
		//�����������������
		cQuery += "WHERE SBJ.BJ_FILIAL = '"+xFilial('SBJ')+"'"
		If !Empty(cFilProd)
			cQuery += " AND SBJ.BJ_COD IN ("+cFilProd+")"
		EndIf	
		cQuery += " AND SBJ.D_E_L_E_T_  = ' ' "
		
		//�������������������������������Ŀ
		//� Clausulas GROUP BY e ORDER BY �
		//���������������������������������
		cQuery += "GROUP BY SBJ.BJ_FILIAL, SBJ.BJ_COD, SBJ.BJ_LOCAL, SBJ.BJ_LOTECTL, SBJ.BJ_DATA "
		cQuery += "ORDER BY SBJ.BJ_FILIAL, SBJ.BJ_COD, SBJ.BJ_LOCAL, SBJ.BJ_LOTECTL, SBJ.BJ_DATA"
		
		If !IsInUpdate .And. !lWizard
			oAtuParc2:cCaption := STR0075; oAtuParc2:Refresh() //'Selecionando Registros...'
		EndIf	
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T., 'TOPCONN', TcGenQry(,, cQuery), cAliasTRB)
		For nX := 1 To Len(aStruSBJ)
			If !aStruSBJ[nX, 2]$'CM' .And. !(FieldPos(aStruSBJ[nX, 1])==0)
				TcSetField(cAliasTRB, aStruSBJ[nX, 1], aStruSBJ[nX, 2], aStruSBJ[nX, 3], aStruSBJ[nX, 4])
			EndIf
		Next nX
		dbSelectArea(cAliasTRB)
		dbGoTop()
	#ELSE
		cAliasTRB := 'SBJ'
		dbSeek(xFilial('SBJ'), .F.)
	#ENDIF
	
	If !IsInUpdate .And. !lWizard
		oAtuParc2:cCaption := STR0076; oAtuParc2:Refresh() //'Processando o ajuste...'
	EndIf	
	Do While !(cAliasTRB)->(Eof())
		
		nContador ++
		If !IsInUpdate .And. !lWizard
			oMtParci:Set(++nAtuParci); SysRefresh()
			oAtuParc2:cCaption := AllTrim(Str(nContador))+If(nContador>1,STR0077, STR0078); oAtuParc2:Refresh()	 //' registros processados...'###' registro processado...'
		EndIf	
		
		//�����������������������������������������������������������������������Ŀ
		//� Processa somente produtos com controle de rastreabilidade igual a "L" �
		//�������������������������������������������������������������������������
		#IFNDEF TOP
			If !Rastro(SBJ->BJ_COD, 'L')
				SBJ->(dbSkip())
				Loop
			EndIf
		#ENDIF
		
		//������������������������������������������������������������������������Ŀ
		//� Guarda em array o conteudo de todos os campos deste Produto+Local+Lote �
		//��������������������������������������������������������������������������
		aCampos := Array(7)
		#IFNDEF TOP
			aFill(aCampos, CtoD('  /  /  '), 4, 2)
			aFill(aCampos, 0, 6, 2)
			aRecDelSBJ := {SBJ->(Recno())}
			cCondicao  := '!SBJ->(Eof()) .And. "'+SBJ->(BJ_FILIAL+BJ_COD+BJ_LOCAL+BJ_LOTECTL+DTOS(BJ_DATA))+'"==SBJ->(BJ_FILIAL+BJ_COD+BJ_LOCAL+BJ_LOTECTL+DTOS(BJ_DATA))'
		#ENDIF
		
		//����������������������������Ŀ
		//� Campos com conteudos fixos �
		//������������������������������
		aCampos[01] := (cAliasTRB)->BJ_COD
		aCampos[02] := (cAliasTRB)->BJ_LOCAL
		aCampos[03] := (cAliasTRB)->BJ_LOTECTL
		aCampos[04] := (cAliasTRB)->BJ_DATA
		
		//������������������������������������������Ŀ
		//� Campos com conteudos a serem aglutinados �
		//��������������������������������������������
		#IFDEF TOP
			aCampos[05] := (cAliasTRB)->BJ_DTVALID
			aCampos[06] := (cAliasTRB)->BJ_QINI
			aCampos[07] := (cAliasTRB)->BJ_QISEGUM
		#ELSE
			If &cCondicao
				Do While &cCondicao
					aCampos[05] := Max((cAliasTRB)->BJ_DTVALID, aCampos[05])
					aCampos[06] += (cAliasTRB)->BJ_QINI
					aCampos[07] += (cAliasTRB)->BJ_QISEGUM
					aAdd(aRecDelSBJ, SBJ->(Recno()))
					SBJ->(dbSkip())
				EndDo
			EndIf
		#ENDIF
		
			//��������������������������������������������������Ŀ
			//� Deleta os registros com deste Produto+Local+Lote �
			//����������������������������������������������������
			#IFDEF TOP
				cQuery  := "DELETE FROM "+RetSqlName('SBJ')+" "
				cQuery  += "WHERE BJ_FILIAL = '"+xFilial('SBJ')+"'"
				cQuery  += " AND BJ_COD = '"    +aCampos[01]+"'"
				cQuery  += " AND BJ_LOCAL = '"  +aCampos[02]+"'"
				cQuery  += " AND BJ_LOTECTL = '"+aCampos[03]+"'"
				cQuery  += " AND BJ_DATA = '"+DTOS(aCampos[04])+"'"
				cQuery  += " AND D_E_L_E_T_ = ' '"
				TCSqlExec(cQuery)
				SBJ->(dbGoto(Recno()))
			#ELSE
				For nX := 1 to Len(aRecDelSBJ)
					SBJ->(dbGoto(aRecDelSBJ[nX]))
					RecLock('SBJ', .F.)
					dbDelete()
					MsUnlock()
				Next nX
			#ENDIF
			
			//�������������������������������������������������������������������������������Ŀ
			//� Inclui registro unico deste Produto+Local+Lote com as quantidades aglutinadas �
			//���������������������������������������������������������������������������������
			RecLock('SBJ', .T.)
			Replace BJ_FILIAL  With xFilial('SBJ'), ; //-- Filial do Sistema
					BJ_COD     With aCampos[01], ; //-- Codigo do Produto
					BJ_LOCAL   With aCampos[02], ; //-- Armazem
					BJ_LOTECTL With aCampos[03], ; //-- Lote
					BJ_DATA    With aCampos[04], ; //-- Data da Criacao do lote
					BJ_DTVALID With aCampos[05], ; //-- Data de Validade do lote
					BJ_QINI    With aCampos[06], ; //-- Quantidade inicial do lote
					BJ_QISEGUM With aCampos[07]    //-- Quantidade inicial 2UM
			If lUpdEst08
				ExecBlock('PEUPDE08', .F., .F., {'SBJ'})
			EndIf
			MsUnlock()
		(cAliasTRB)->(dbSkip())
	EndDo
	
	If !IsInUpdate .And. !lWizard
		oMtParci:Set(nTotCont); SysRefresh() //-- Finaliza a regua de processamento
	EndIf	
	
	#IFDEF TOP
		If Select(cAliasTRB) > 0
			dbSelectArea(cAliasTRB)
			dbCloseArea()
		EndIf
		//����������������������������������������������������������Ŀ
		//� A tabela eh fechada para restaurar o buffer da aplicacao �
		//������������������������������������������������������������
		dbSelectArea('SBJ')
		dbCloseArea()
		ChkFile('SBJ', .T.)
	#ENDIF
	
	cTexto += STR0091+AllTrim(Str(nContador))+STR0080+PULALINHA //' Tabela SBJ: '###' registro(s) processado(s). '
Else
	cTexto += STR0116+PULALINHA //' Tabela SBJ: Nenhum registro processado. '
	cTexto += STR0082+PULALINHA //' Obs.: Esta tabela possui acesso compartilhado, situacao em que o ajuste eh feito apenas 1x por empresa.'
EndIf

//����������������������������������������Ŀ
//� Atualiza variaveis da janela principal �
//������������������������������������������
If !IsInUpdate
	oAtuParc1:cCaption := STR0093; oAtuParc1:Refresh() //'Ajuste da tabela SBJ finalizado!'
	oAtuParc2:cCaption := ''; oAtuParc2:Refresh()
	oAtuParc3:cCaption := ''; oAtuParc3:Refresh()
EndIf	

Return Nil

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �WizLTSBF � Autor �Emerson R. Oliveira    � Data �13/01/10  ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Funcao de processamento do ajuste da tabela SBF            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � WizLtUni                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function WizLTSBF(cTexto, aFilSBF, IsInUpdate, lWizard)

Local aCampos    := {}
Local aStruSBF   := SBF->(dbStruct())
Local cQuery     := ''
Local cAliasTRB  := ''
Local lUpdEst08  := ExistBlock('PEUPDE08')
Local nX         := 0
Local nContador  := 0
Local nRecsSBF   := nTotCont := Max(1, SBF->(LastRec()))   
#IFNDEF TOP
	Local aRecDelSBF  := {}
	Private cCondicao := .F.
#ENDIF

Default lWizard  := .F.

//����������������������������������������Ŀ
//� Atualiza variaveis da janela principal �
//������������������������������������������
If !IsInUpdate .And. !lWizard
	oMtTotal:Set(++nAtuTotal); SysRefresh()
	cItemAju           := STR0120; oItemAju:Refresh()
	nAtuParci          := 0
	oMtParci:nTotal    := nRecsSBF
	oAtuParc1:cCaption := STR0121; oAtuParc1:Refresh()
	oAtuParc2:cCaption := ''; oAtuParc2:Refresh()
	oAtuParc3:cCaption := ''; oAtuParc3:Refresh()
EndIf	

If aScan(aFilSBF, SBF->(xFilial('SBF'))) == 0
	aAdd(aFilSBF, SBF->(xFilial('SBF')))
	dbSelectArea('SBF')
	dbSetOrder(2) //-- BF_FILIAL+BF_PRODUTO+BF_LOCAL+BF_LOTECTL+BF_NUMLOTE+BF_PRIOR+BF_LOCALIZ+BF_NUMSERI
	#IFDEF TOP
		cAliasTRB := GetNextAlias() //'TRBSBF'
		//����������������Ŀ
		//� Campos da VIEW �
		//������������������
		cQuery := "SELECT "
		cQuery += " SBF.BF_FILIAL,"
		cQuery += " SBF.BF_PRODUTO,"
		cQuery += " SBF.BF_LOCAL,"
		cQuery += " SBF.BF_LOCALIZ,"
		cQuery += " SBF.BF_NUMSERI,"
		cQuery += " SBF.BF_ESTFIS,"
		cQuery += " SBF.BF_LOTECTL,"
		cQuery += " SUM(SBF.BF_QUANT) BF_QUANT,"
		cQuery += " SUM(SBF.BF_EMPENHO) BF_EMPENHO,"
		cQuery += " SUM(SBF.BF_QEMPPRE) BF_QEMPPRE,"
		cQuery += " SUM(SBF.BF_QTSEGUM) BF_QTSEGUM,"
		cQuery += " SUM(SBF.BF_EMPEN2) BF_EMPEN2,"
		cQuery += " SUM(SBF.BF_QEPRE2) BF_QEPRE2,"
		cQuery += " MAX(SBF.BF_DATAVEN) BF_DATAVEN,"
		cQuery += " MIN(SBF.BF_PRIOR) BF_PRIOR"
		cQuery += " FROM "+RetSqlName('SBF')+" SBF "
		
		//��������������������������������Ŀ
		//� Condicoes JOIN entre SBF e SB1 �
		//����������������������������������
		cQuery += "JOIN "+RetSqlName('SB1')+" SB1 "
		cQuery += "ON SB1.B1_FILIAL = '"+xFilial('SB1')+"'"
		cQuery += " AND SB1.B1_COD = SBF.BF_PRODUTO"
		cQuery += " AND SB1.B1_RASTRO  = 'L'"
		cQuery += " AND SB1.B1_LOCALIZ = 'S'"
		cQuery += " AND SB1.D_E_L_E_T_ = ' ' "
		
		//���������������Ŀ
		//� Condicoes SB8 �
		//�����������������
		cQuery += "WHERE SBF.BF_FILIAL = '"+xFilial('SBF')+"'"
		If !Empty(cFilProd)
			cQuery += " AND SBF.BF_PRODUTO IN ("+cFilProd+")"
		EndIf	
		cQuery += " AND SBF.D_E_L_E_T_  = ' ' "
		cQuery += " AND SBF.BF_LOTECTL <> ' ' "
		cQuery += " AND SBF.BF_NUMLOTE <> ' ' "
		
		//�������������������������������Ŀ
		//� Clausulas GROUP BY e ORDER BY �
		//���������������������������������
		cQuery += " GROUP BY SBF.BF_FILIAL, SBF.BF_PRODUTO, SBF.BF_LOCAL, SBF.BF_LOCALIZ, SBF.BF_NUMSERI, SBF.BF_ESTFIS, SBF.BF_LOTECTL "
		cQuery += " ORDER BY SBF.BF_FILIAL, SBF.BF_PRODUTO, SBF.BF_LOCAL, SBF.BF_LOCALIZ, SBF.BF_NUMSERI, SBF.BF_ESTFIS, SBF.BF_LOTECTL "
		
		If !IsInUpdate .And. !lWizard
			oAtuParc2:cCaption := STR0075; oAtuParc2:Refresh() //'Selecionando Registros...'
		EndIf	
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T., 'TOPCONN', TcGenQry(,, cQuery), cAliasTRB)
		For nX := 1 To Len(aStruSBF)
			If !aStruSBF[nX, 2]$'CM' .And. !(FieldPos(aStruSBF[nX, 1])==0)
				TcSetField(cAliasTRB, aStruSBF[nX, 1], aStruSBF[nX, 2], aStruSBF[nX, 3], aStruSBF[nX, 4])
			EndIf
		Next nX
		dbSelectArea(cAliasTRB)
		dbGoTop()
	#ELSE
		cAliasTRB := 'SBF'
		dbSeek(xFilial('SBF'), .F.)
	#ENDIF
	
	If !IsInUpdate .And. !lWizard
		oAtuParc2:cCaption := STR0076; oAtuParc2:Refresh() //'Processando o ajuste...'
	EndIf	
	Do While !(cAliasTRB)->(Eof())
		
		nContador ++
		If !IsInUpdate .And. !lWizard
			oMtParci:Set(++nAtuParci); SysRefresh()
			oAtuParc2:cCaption := AllTrim(Str(nContador))+If(nContador>1,STR0077, STR0078); oAtuParc2:Refresh()	 //' registros processados...'###' registro processado...'
		EndIf	
	
		//�����������������������������������������������������������������������Ŀ
		//� Processa somente produtos com controle de rastreabilidade igual a "L" �
		//�������������������������������������������������������������������������
		#IFNDEF TOP
			If !Rastro(SBF->BF_PRODUTO, 'L')
				SBF->(dbSkip())
				Loop
			EndIf
		#ENDIF
		
		//������������������������������������������������������������������������Ŀ
		//� Guarda em array o conteudo de todos os campos deste Produto+Local+Lote �
		//��������������������������������������������������������������������������
		aCampos := Array(13)
		#IFNDEF TOP
			aFill(aCampos, CtoD('  /  /  '), 13, 1)
			aFill(aCampos, 0, 7, 6)
			aRecDelSBF := {SBF->(Recno())}
			cCondicao  := '!SBF->(Eof()) .And. "'+SBF->(BF_FILIAL+BF_PRODUTO+BF_LOCAL+BF_LOCALIZ+BF_NUMSERI+BF_ESTFIS+BF_LOTECTL)+'"==SBF->(BF_FILIAL+BF_PRODUTO+BF_LOCAL+BF_LOCALIZ+BF_NUMSERI+BF_ESTFIS+BF_LOTECTL)'
		#ENDIF
		
		//����������������������������Ŀ
		//� Campos com conteudos fixos �
		//������������������������������
		aCampos[01] := (cAliasTRB)->BF_PRODUTO
		aCampos[02] := (cAliasTRB)->BF_LOCAL
		aCampos[03] := (cAliasTRB)->BF_LOCALIZ
		aCampos[04] := (cAliasTRB)->BF_NUMSERI
		aCampos[05] := (cAliasTRB)->BF_ESTFIS
		aCampos[06] := (cAliasTRB)->BF_LOTECTL
		
		//������������������������������������������Ŀ
		//� Campos com conteudos a serem aglutinados �
		//��������������������������������������������
		#IFDEF TOP
			aCampos[07] := (cAliasTRB)->BF_QUANT
			aCampos[08] := (cAliasTRB)->BF_EMPENHO
			aCampos[09] := (cAliasTRB)->BF_QEMPPRE
			aCampos[10] := (cAliasTRB)->BF_QTSEGUM
			aCampos[11] := (cAliasTRB)->BF_EMPEN2
			aCampos[12] := (cAliasTRB)->BF_QEPRE2
			aCampos[13] := (cAliasTRB)->BF_DATAVEN
		#ELSE
			If &cCondicao
				Do While &cCondicao
					aCampos[07] += (cAliasTRB)->BF_QUANT
					aCampos[08] += (cAliasTRB)->BF_EMPENHO
					aCampos[09] += (cAliasTRB)->BF_QEMPPRE
					aCampos[10] += (cAliasTRB)->BF_QTSEGUM
					aCampos[11] += (cAliasTRB)->BF_EMPEN2
					aCampos[12] += (cAliasTRB)->BF_QEPRE2
					aCampos[13] := If(Empty(aCampos[13]), (cAliasTRB)->BF_DATAVEN, Max((cAliasTRB)->BF_DATAVEN, aCampos[13]))
					aAdd(aRecDelSBF, SBF->(Recno()))
					SBF->(dbSkip())
				EndDo
			EndIf
		#ENDIF
		
			//��������������������������������������������������Ŀ
			//� Deleta os registros com deste Produto+Local+Lote �
			//����������������������������������������������������
			#IFDEF TOP
				cQuery  := "DELETE FROM "+RetSqlName('SBF')+" "
				cQuery  += "WHERE BF_FILIAL = '"+xFilial('SBF')+"'"
				cQuery  += " AND BF_PRODUTO = '"+aCampos[01]+"'"
				cQuery  += " AND BF_LOCAL = '" +aCampos[02]+"'"
				cQuery  += " AND BF_LOCALIZ = '" +aCampos[03]+"'"
				cQuery  += " AND BF_NUMSERI = '" +aCampos[04]+"'"
				cQuery  += " AND BF_ESTFIS = '" +aCampos[05]+"'"
				cQuery  += " AND BF_LOTECTL = '"+aCampos[06]+"'"
				cQuery  += " AND D_E_L_E_T_ = ' '"
				TCSqlExec(cQuery)
				SBF->(dbGoto(Recno()))
			#ELSE
				For nX := 1 to Len(aRecDelSBF)
					SBF->(dbGoto(aRecDelSBF[nX]))
					RecLock('SBF', .F.)
					dbDelete()
					MsUnlock()
				Next nX
			#ENDIF
			
			//�������������������������������������������������������������������������������Ŀ
			//� Inclui registro unico deste Produto+Local+Lote com as quantidades aglutinadas �
			//���������������������������������������������������������������������������������
			RecLock('SBF', .T.)
			Replace BF_FILIAL  With xFilial('SBF'), ; //-- Filial do Sistema
					BF_PRODUTO With aCampos[01], ; //-- Codigo do Produto
					BF_LOCAL   With aCampos[02], ; //-- Armazem
					BF_LOCALIZ With aCampos[03], ; //-- Endereco
					BF_NUMSERI With aCampos[04], ; //-- Numero de serie
					BF_ESTFIS  With aCampos[05], ; //-- Estrutura fisica (WMS)
					BF_LOTECTL With aCampos[06], ; //-- Lote
					BF_QUANT   With aCampos[07], ; //-- Quantidade
					BF_EMPENHO With aCampos[08], ; //-- Empenho
					BF_QEMPPRE With aCampos[09], ; //-- Empenho previsto
					BF_QTSEGUM With aCampos[10], ; //-- Qtd. 2a UM
					BF_EMPEN2  With aCampos[11], ; //-- Empenho 2a UM
					BF_QEPRE2  With aCampos[12], ; //-- Empenho previsto 2a UM
					BF_DATAVEN With aCampos[13]    //-- Data de vencimento
			If lUpdEst08
				ExecBlock('PEUPDE08', .F., .F., {'SBF'})
			EndIf
			MsUnlock()
		(cAliasTRB)->(dbSkip())
	EndDo
	
	If !IsInUpdate .And. !lWizard
		oMtParci:Set(nTotCont); SysRefresh() //-- Finaliza a regua de processamento
	EndIf	
	
	#IFDEF TOP
		If Select(cAliasTRB) > 0
			dbSelectArea(cAliasTRB)
			dbCloseArea()
		EndIf
		//����������������������������������������������������������Ŀ
		//� A tabela eh fechada para restaurar o buffer da aplicacao �
		//������������������������������������������������������������
		dbSelectArea('SBF')
		dbCloseArea()
		ChkFile('SBF', .T.)
	#ENDIF
	cTexto += STR0117+AllTrim(Str(nContador))+STR0080+PULALINHA //' Tabela SBF: '###' registro(s) processado(s). '
Else
	cTexto += STR0118+PULALINHA //' Tabela SBF: Nenhum registro processado(*). '
	cTexto += STR0082+PULALINHA //' Obs.: Esta tabela possui acesso compartilhado, situacao em que o ajuste eh feito apenas 1x por empresa.'
EndIf

//����������������������������������������Ŀ
//� Atualiza variaveis da janela principal �
//������������������������������������������
If !IsInUpdate .And. !lWizard
	oAtuParc1:cCaption := STR0119; oAtuParc1:Refresh() //'Ajuste da tabela SB8 finalizado!'
	oAtuParc2:cCaption := ''; oAtuParc2:Refresh()
EndIf	

Return Nil

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �WizLTSBK � Autor �Emerson R. Oliveira    � Data �13/01/10  ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Funcao de processamento do ajuste da tabela SBK            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � WizLtUni                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function WizLTSBK(cTexto, aFilSBK, IsInUpdate, lWizard)

Local aCampos    := {}
Local aStruSBK   := SBK->(dbStruct())
Local cQuery     := ''
Local cAliasTRB  := ''
Local lUpdEst08  := ExistBlock('PEUPDE08')
Local nX         := 0
Local nContador  := 0
Local nRecsSBK   := nTotCont := Max(1, SBK->(LastRec()))
#IFNDEF TOP
	Local aRecDelSBK  := {}
	Private cCondicao := .F.
#ENDIF

Default lWizard  := .F.

//����������������������������������������Ŀ
//� Atualiza variaveis da janela principal �
//������������������������������������������
If !IsInUpdate .And. !lWizard
	oMtTotal:Set(++nAtuTotal); SysRefresh()
	cItemAju           := STR0122; oItemAju:Refresh() //'Andamento do ajuste da tabela de saldos iniciais por lote:'
	nAtuParci          := 0
	oMtParci:nTotal    := nRecsSBK
	oAtuParc1:cCaption := STR0123; oAtuParc1:Refresh() //'Varrendo tabela SBJ...'
	oAtuParc2:cCaption := ''; oAtuParc2:Refresh()
	oAtuParc3:cCaption := ''; oAtuParc3:Refresh()
EndIf	

If aScan(aFilSBK, SBK->(xFilial('SBK'))) == 0
	aAdd(aFilSBK, SBK->(xFilial('SBK')))
	dbSelectArea('SBK')
	dbSetOrder(1) //-- BK_FILIAL+BK_COD+BK_LOCAL+BK_LOTECTL+BK_NUMLOTE+BK_LOCALIZ+BK_NUMSERI+DTOS(BK_DATA)
	#IFDEF TOP
		cAliasTRB := GetNextAlias() //'TRBSBK'
		
		//����������������Ŀ
		//� Campos da VIEW �
		//������������������
		cQuery := "SELECT "
		cQuery += " SBK.BK_COD,"
		cQuery += " SBK.BK_LOCAL,"
		cQuery += " SBK.BK_LOCALIZ,"
		cQuery += " SBK.BK_NUMSERI,"
		cQuery += " SBK.BK_LOTECTL,"
		cQuery += " SBK.BK_DATA,"
		cQuery += " SUM(SBK.BK_QINI) BK_QINI,"
		cQuery += " SUM(SBK.BK_QISEGUM) BK_QISEGUM,"
		cQuery += " MIN(SBK.BK_PRIOR) BK_PRIOR"
		cQuery += " FROM "+RetSqlName('SBK')+" SBK "
		
		//��������������������������������Ŀ
		//� Condicoes JOIN entre SBJ e SB1 �
		//����������������������������������
		cQuery += "JOIN "+RetSqlName('SB1')+" SB1 "
		cQuery += "ON SB1.B1_FILIAL = '"+xFilial('SB1')+"'"
		cQuery += " AND SB1.B1_COD = SBK.BK_COD"
		cQuery += " AND SB1.B1_RASTRO = 'L'"
		cQuery += " AND SB1.D_E_L_E_T_  = ' ' "
		
		//���������������Ŀ
		//� Condicoes SBJ �
		//�����������������
		cQuery += "WHERE SBK.BK_FILIAL = '"+xFilial('SBK')+"'"
		If !Empty(cFilProd)
			cQuery += " AND SBK.BK_COD IN ("+cFilProd+")"
		EndIf	
		cQuery += " AND SBK.D_E_L_E_T_  = ' ' "
		cQuery += " AND SBK.BK_LOTECTL <> ' ' "
		cQuery += " AND SBK.BK_NUMLOTE <> ' ' "
		
		//�������������������������������Ŀ
		//� Clausulas GROUP BY e ORDER BY �
		//���������������������������������
		cQuery += "GROUP BY SBK.BK_FILIAL, SBK.BK_COD, SBK.BK_LOCAL, SBK.BK_LOCALIZ, SBK.BK_NUMSERI, SBK.BK_LOTECTL, SBK.BK_DATA "
		cQuery += "ORDER BY SBK.BK_FILIAL, SBK.BK_COD, SBK.BK_LOCAL, SBK.BK_LOCALIZ, SBK.BK_NUMSERI, SBK.BK_LOTECTL, SBK.BK_DATA "
		
		If !IsInUpdate .And. !lWizard
			oAtuParc2:cCaption := STR0075; oAtuParc2:Refresh() //'Selecionando Registros...'
		EndIf	
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T., 'TOPCONN', TcGenQry(,, cQuery), cAliasTRB)
		For nX := 1 To Len(aStruSBK)
			If !aStruSBK[nX, 2]$'CM' .And. !(FieldPos(aStruSBK[nX, 1])==0)
				TcSetField(cAliasTRB, aStruSBK[nX, 1], aStruSBK[nX, 2], aStruSBK[nX, 3], aStruSBK[nX, 4])
			EndIf
		Next nX
		dbSelectArea(cAliasTRB)
		dbGoTop()
	#ELSE
		cAliasTRB := 'SBK'
		dbSeek(xFilial('SBK'), .F.)
	#ENDIF
	
	If !IsInUpdate .And. !lWizard
		oAtuParc2:cCaption := STR0076; oAtuParc2:Refresh() //'Processando o ajuste...'
	EndIf	
	Do While !(cAliasTRB)->(Eof())
		
		nContador ++
		If !IsInUpdate .And. !lWizard
			oMtParci:Set(++nAtuParci); SysRefresh()
			oAtuParc2:cCaption := AllTrim(Str(nContador))+If(nContador>1,STR0077, STR0078); oAtuParc2:Refresh()	 //' registros processados...'###' registro processado...'
		EndIf	
		
		//�����������������������������������������������������������������������Ŀ
		//� Processa somente produtos com controle de rastreabilidade igual a "L" �
		//�������������������������������������������������������������������������
		#IFNDEF TOP
			If !Rastro(SBK->BK_COD, 'L')
				SBK->(dbSkip())
				Loop
			EndIf
		#ENDIF
		
		//������������������������������������������������������������������������Ŀ
		//� Guarda em array o conteudo de todos os campos deste Produto+Local+Lote �
		//��������������������������������������������������������������������������
		aCampos := Array(9)
		#IFNDEF TOP
			aFill(aCampos, CtoD('  /  /  '), 6, 1)
			aFill(aCampos, 0, 7, 3)
			aRecDelSBK := {SBK->(Recno())}
			cCondicao  := '!SBK->(Eof()) .And. "'+SBK->(BK_FILIAL+BK_COD+BK_LOCAL+BK_LOCALIZ+BK_NUMSERI+BK_LOTECTL+DTOS(BK_DATA))+'"==SBK->(BK_FILIAL+BK_COD+BK_LOCAL+BK_LOCALIZ+BK_NUMSERI+BK_LOTECTL+DTOS(BK_DATA))'
		#ENDIF
		
		//����������������������������Ŀ
		//� Campos com conteudos fixos �
		//������������������������������
		aCampos[01] := (cAliasTRB)->BK_COD
		aCampos[02] := (cAliasTRB)->BK_LOCAL
		aCampos[03] := (cAliasTRB)->BK_LOCALIZ
		aCampos[04] := (cAliasTRB)->BK_NUMSERI
		aCampos[05] := (cAliasTRB)->BK_LOTECTL
		aCampos[06] := (cAliasTRB)->BK_DATA
		
		//������������������������������������������Ŀ
		//� Campos com conteudos a serem aglutinados �
		//��������������������������������������������
		#IFDEF TOP
			aCampos[07] := (cAliasTRB)->BK_QINI
			aCampos[08] := (cAliasTRB)->BK_QISEGUM
			aCampos[09] := (cAliasTRB)->BK_PRIOR
		#ELSE
			If &cCondicao
				Do While &cCondicao
					aCampos[07] += (cAliasTRB)->BK_QINI
					aCampos[08] += (cAliasTRB)->BK_QISEGUM
					aCampos[09] := Min((cAliasTRB)->BK_PRIOR, aCampos[085])
					aAdd(aRecDelSBK, SBK->(Recno()))
					SBK->(dbSkip())
				EndDo
			EndIf
		#ENDIF
		
			//��������������������������������������������������Ŀ
			//� Deleta os registros com deste Produto+Local+Lote �
			//����������������������������������������������������
			#IFDEF TOP
				cQuery  := "DELETE FROM "+RetSqlName('SBK')+" "
				cQuery  += "WHERE BK_FILIAL = '"+xFilial('SBK')+"'"
				cQuery  += " AND BK_COD = '" +aCampos[01]+"'"
				cQuery  += " AND BK_LOCAL = '" +aCampos[02]+"'"
				cQuery  += " AND BK_LOCALIZ = '" +aCampos[03]+"'"
				cQuery  += " AND BK_NUMSERI = '" +aCampos[04]+"'"
				cQuery  += " AND BK_LOTECTL = '"+aCampos[05]+"'"
				cQuery  += " AND BK_DATA = '"+DTOS(aCampos[06])+"'"
				cQuery  += " AND D_E_L_E_T_ = ' '"
				TCSqlExec(cQuery)
				SBK->(dbGoto(Recno()))
			#ELSE
				For nX := 1 to Len(aRecDelSBK)
					SBK->(dbGoto(aRecDelSBK[nX]))
					RecLock('SBK', .F.)
					dbDelete()
					MsUnlock()
				Next nX
			#ENDIF
			
			//�������������������������������������������������������������������������������Ŀ
			//� Inclui registro unico deste Produto+Local+Lote com as quantidades aglutinadas �
			//���������������������������������������������������������������������������������
			RecLock('SBK', .T.)
			Replace BK_FILIAL  With xFilial('SBK'), ; //-- Filial do Sistema
					BK_COD     With aCampos[01], ; //-- Codigo do Produto
					BK_LOCAL   With aCampos[02], ; //-- Armazem
					BK_LOCALIZ With aCampos[03], ; //-- Endereco
					BK_NUMSERI With aCampos[04], ; //-- Numero de serie
					BK_LOTECTL With aCampos[05], ; //-- Lote
					BK_DATA    With aCampos[06], ; //-- Data da Criacao do lote
					BK_QINI    With aCampos[07], ; //-- Quantidade inicial do lote
					BK_QISEGUM With aCampos[08], ; //-- Quantidade inicial 2UM
					BK_PRIOR   With aCampos[09]    //-- Prioridade do endereco
			If lUpdEst08
				ExecBlock('PEUPDE08', .F., .F., {'SBK'})
			EndIf
			MsUnlock()
		(cAliasTRB)->(dbSkip())
	EndDo
	
	If !IsInUpdate .And. !lWizard
		oMtParci:Set(nTotCont); SysRefresh() //-- Finaliza a regua de processamento
	EndIf	
	
	#IFDEF TOP
		If Select(cAliasTRB) > 0
			dbSelectArea(cAliasTRB)
			dbCloseArea()
		EndIf
		//����������������������������������������������������������Ŀ
		//� A tabela eh fechada para restaurar o buffer da aplicacao �
		//������������������������������������������������������������
		dbSelectArea('SBK')
		dbCloseArea()
		ChkFile('SBK', .T.)
	#ENDIF
	
	cTexto += STR0124+AllTrim(Str(nContador))+STR0080+PULALINHA //' Tabela SBK: '###' registro(s) processado(s). '
Else
	cTexto += STR0125+PULALINHA //' Tabela SBK: Nenhum registro processado. '
	cTexto += STR0082+PULALINHA //' Obs.: Esta tabela possui acesso compartilhado, situacao em que o ajuste eh feito apenas 1x por empresa.'
EndIf

//����������������������������������������Ŀ
//� Atualiza variaveis da janela principal �
//������������������������������������������
If !IsInUpdate .And. !lWizard
	oAtuParc1:cCaption := STR0126; oAtuParc1:Refresh() //'Ajuste da tabela SBK finalizado!'
	oAtuParc2:cCaption := ''; oAtuParc2:Refresh()
	oAtuParc3:cCaption := ''; oAtuParc3:Refresh()
EndIf	

Return Nil

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �WizLTSDA � Autor �Emerson R. Oliveira    � Data �13/01/10  ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Funcao de processamento do ajuste da tabela SDA            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � WizLtUni                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function WizLTSDA(cTexto, aFilSDA, IsInUpdate, lWizard)

Local cQuery     := ''
Local cAliasTRB  := ''
Local lUpdEst08  := ExistBlock('PEUPDE08')
Local nContador  := 0
Local nRecsSDA   := nTotCont := Max(1, SDA->(LastRec()))
Local cTamSLote  := Space(TamSX3("B8_NUMLOTE")[1])
#IFNDEF TOP
	Local cIndDA      := ''
	Local cFiltroDA   := ''
	Local cNomArqDA   := ''
	Local nIndDA      := 0
	Private cCondicao := .F.
#ENDIF

Default lWizard  := .F.

//����������������������������������������Ŀ
//� Atualiza variaveis da janela principal �
//������������������������������������������
If !IsInUpdate .And. !lWizard
	oMtTotal:Set(++nAtuTotal); SysRefresh()
	cItemAju           := STR0127; oItemAju:Refresh() //'Andamento do ajuste da tabela de saldos a endere�ar:'
	nAtuParci          := 0
	oMtParci:nTotal    := nRecsSDA
	oAtuParc1:cCaption := STR0128; oAtuParc1:Refresh() //'Varrendo tabela SDA...'
	oAtuParc2:cCaption := ''; oAtuParc2:Refresh()
	oAtuParc3:cCaption := ''; oAtuParc3:Refresh()
EndIf	

If aScan(aFilSDA, SDA->(xFilial('SDA'))) == 0
	aAdd(aFilSDA, SDA->(xFilial('SDA')))
	dbSelectArea('SDA')
	dbSetOrder(1) //-- DA_FILIAL+DA_PRODUTO+DA_LOCAL+DA_NUMSEQ+DA_DOC+DA_SERIE+DA_CLIFOR+DA_LOJA
	#IFDEF TOP
		cAliasTRB := GetNextAlias() //'TRBSBK'
		
		//����������������Ŀ
		//� Campos da VIEW �
		//������������������
		cQuery := "SELECT SDA.R_E_C_N_O_  DA_RECNO "
		cQuery += "FROM "+RetSqlName('SDA')+" SDA "
		
		//��������������������������������Ŀ
		//� Condicoes JOIN entre SDA e SB1 �
		//����������������������������������
		cQuery += "JOIN "+RetSqlName('SB1')+" SB1 "
		cQuery += "ON SB1.B1_FILIAL = '"+xFilial('SB1')+"'"
		cQuery += " AND SB1.B1_COD = SDA.DA_PRODUTO"
		cQuery += " AND SB1.B1_RASTRO = 'L'"
		cQuery += " AND SB1.D_E_L_E_T_  = ' ' "
		
		//���������������Ŀ
		//� Condicoes SDA �
		//�����������������
		cQuery += "WHERE SDA.DA_FILIAL = '"+xFilial('SDA')+"'"
		If !Empty(cFilProd)
			cQuery += " AND SDA.DA_PRODUTO IN ("+cFilProd+")"
		EndIf	
		cQuery += " AND SDA.D_E_L_E_T_  = ' ' "
		cQuery += " AND SDA.DA_LOTECTL <> ' ' "
		cQuery += " AND SDA.DA_NUMLOTE <> ' ' "
		
		//�������������������������������Ŀ
		//� Clausulas GROUP BY e ORDER BY �
		//���������������������������������
		cQuery += " ORDER BY SDA.R_E_C_N_O_ "

		If !IsInUpdate .And. !lWizard
			oAtuParc2:cCaption := STR0075; oAtuParc2:Refresh() //'Selecionando Registros...'
		EndIf	
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T., 'TOPCONN', TcGenQry(,, cQuery), cAliasTRB)
		dbSelectArea(cAliasTRB)
		dbGoTop()
	#ELSE
		cAliasTRB := 'SDA'
		cNomArqDA := CriaTrab('', .F.)
		cIndDA    := 'DA_PRODUTO+DA_LOCAL+DA_LOTECTL+DA_NUMLOTE+DA_NUMSEQ'
		cFiltroDA := 'DA_FILIAL=="'+xFilial('SDA')+'" .And. !Empty(DA_NUMLOTE)'
		IndRegua(cAliasTRB, cNomArqDA, cIndDA,, cFiltroDA, STR0075) //'Selecionando Registros...'
		nIndDA    := RetIndex('SDA')
		dbSetIndex(cNomArqDA + OrdBagExt())
		dbSetOrder(nIndDA + 1)
		dbGoTop()
	#ENDIF
	
	If !IsInUpdate .And. !lWizard 
		oAtuParc2:cCaption := STR0076; oAtuParc2:Refresh() //'Processando o ajuste...'
	EndIf	
	Do While !(cAliasTRB)->(Eof())
		
		nContador ++
		If !IsInUpdate .And. !lWizard
			oMtParci:Set(++nAtuParci); SysRefresh()
			oAtuParc2:cCaption := AllTrim(Str(nContador))+If(nContador>1,STR0077, STR0078); oAtuParc2:Refresh()	 //' registros processados...'###' registro processado...'
		EndIf	
		
		//�����������������������������������������������������������������������Ŀ
		//� Processa somente produtos com controle de rastreabilidade igual a "L" �
		//�������������������������������������������������������������������������
		#IFNDEF TOP
			If !Rastro(SDA->DA_PRODUTO, 'L')
				SDA->(dbSkip())
				Loop
			EndIf

			cCondicao  := '!SDA->(Eof())"'
		#ENDIF
		
			//������������������������������������������������Ŀ
			//� Atualiza os registros deste Produto+Local+Lote �
			//��������������������������������������������������
			#IFDEF TOP
				cQuery := "UPDATE "+RetSqlName('SDA')+" "
				cQuery += " SET DA_NUMLOTE = '"+cTamSLote+"' "
				cQuery += " WHERE R_E_C_N_O_ = "+LTrim(Str((cAliasTRB)->DA_RECNO))+""
				TCSqlExec(cQuery)
				SDA->(dbGoto(Recno()))
			#ELSE
				If &cCondicao
					Do While &cCondicao
						RecLock('SDA', .F.)
						Replace DA_NUMLOTE With cTamSLote
						MsUnlock()
						SDA->(dbSkip())
					EndDo
				EndIf
			#ENDIF
			
			If lUpdEst08
				ExecBlock('PEUPDE08', .F., .F., {'SDA'})
			EndIf
			MsUnlock()
		(cAliasTRB)->(dbSkip())
	EndDo
	
	If !IsInUpdate .And. !lWizard
		oMtParci:Set(nTotCont); SysRefresh() //-- Finaliza a regua de processamento
	EndIf	
	
	#IFDEF TOP
		If Select(cAliasTRB) > 0
			dbSelectArea(cAliasTRB)
			dbCloseArea()
		EndIf
		//����������������������������������������������������������Ŀ
		//� A tabela eh fechada para restaurar o buffer da aplicacao �
		//������������������������������������������������������������
		dbSelectArea('SDA')
		dbCloseArea()
		ChkFile('SDA', .T.)
	#ELSE
		If File(cNomArqDA += OrdBagExt())
			fErase(cNomArqDA)
		EndIf			
	#ENDIF
	
	cTexto += STR0129+AllTrim(Str(nContador))+STR0080+PULALINHA //' Tabela SDA: '###' registro(s) processado(s). '
Else
	cTexto += STR0130+PULALINHA //' Tabela SDA: Nenhum registro processado. '
	cTexto += STR0082+PULALINHA //' Obs.: Esta tabela possui acesso compartilhado, situacao em que o ajuste eh feito apenas 1x por empresa.'
EndIf

//����������������������������������������Ŀ
//� Atualiza variaveis da janela principal �
//������������������������������������������
If !IsInUpdate
	oAtuParc1:cCaption := STR0131; oAtuParc1:Refresh() //'Ajuste da tabela SDA finalizado!'
	oAtuParc2:cCaption := ''; oAtuParc2:Refresh()
	oAtuParc3:cCaption := ''; oAtuParc3:Refresh()
EndIf	

Return Nil

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �WizLTSDB � Autor �Emerson R. Oliveira    � Data �13/01/10  ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Funcao de processamento do ajuste da tabela SDB            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � WizLtUni                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function WizLTSDB(cTexto, aFilSDB, IsInUpdate, lWizard)

Local cQuery     := ''
Local cAliasTRB  := ''
Local lUpdEst08  := ExistBlock('PEUPDE08')
Local nContador  := 0
Local nRecsSDB   := nTotCont := Max(1, SDB->(LastRec()))   
Local cTamSLote  := Space(TamSX3("B8_NUMLOTE")[1])
#IFNDEF TOP
	Local cIndDB      := ''
	Local cFiltroDB   := ''
	Local cNomArqDB   := ''
	Local nIndDB      := 0
	Private cCondicao := .F.
#ENDIF

Default lWizard  := .F.

//����������������������������������������Ŀ
//� Atualiza variaveis da janela principal �
//������������������������������������������
If !IsInUpdate .And. !lWizard
	oMtTotal:Set(++nAtuTotal); SysRefresh()
	cItemAju           := STR0132; oItemAju:Refresh() //'Andamento do ajuste da tabela de movimentos por lote:'
	nAtuParci          := 0
	oMtParci:nTotal    := nRecsSDB
	oAtuParc1:cCaption := STR0133; oAtuParc1:Refresh() //'Varrendo tabela SDB...'
	oAtuParc2:cCaption := ''; oAtuParc2:Refresh()
	oAtuParc3:cCaption := ''; oAtuParc3:Refresh()
EndIf	

If aScan(aFilSDB, SDB->(xFilial('SDB'))) == 0
	aAdd(aFilSDB, SDB->(xFilial('SDB')))
	dbSelectArea('SDB')
	dbSetOrder(2) //-- DB_FILIAL+DB_PRODUTO+DB_LOCAL+DB_LOTECTL+DB_NUMLOTE+DB_NUMSERI+DB_LOCALIZ+DB_NUMSEQ
	#IFDEF TOP
		cAliasTRB := GetNextAlias() //'TRBSDB'
		
		//����������������Ŀ
		//� Campos da VIEW �
		//������������������
		cQuery := "SELECT SDB.R_E_C_N_O_  DB_RECNO "
		cQuery += "FROM "+RetSqlName('SDB')+" SDB "
		
		//��������������������������������Ŀ
		//� Condicoes JOIN entre SDA e SB1 �
		//����������������������������������
		cQuery += "JOIN "+RetSqlName('SB1')+" SB1 "
		cQuery += "ON SB1.B1_FILIAL = '"+xFilial('SB1')+"'"
		cQuery += " AND SB1.B1_COD = SDB.DB_PRODUTO"
		cQuery += " AND SB1.B1_RASTRO = 'L'"
		cQuery += " AND SB1.D_E_L_E_T_  = ' ' "
		
		//���������������Ŀ
		//� Condicoes SDB �
		//�����������������
		cQuery += "WHERE SDB.DB_FILIAL = '"+xFilial('SDB')+"'"
		If !Empty(cFilProd)
			cQuery += " AND SDB.DB_PRODUTO IN ("+cFilProd+")"
		EndIf	
		cQuery += " AND SDB.D_E_L_E_T_  = ' ' "
		cQuery += " AND SDB.DB_LOTECTL <> ' ' "
		cQuery += " AND SDB.DB_NUMLOTE <> ' ' "

		//�������������������������������Ŀ
		//� Clausulas GROUP BY e ORDER BY �
		//���������������������������������
		cQuery += " ORDER BY SDB.R_E_C_N_O_ "
		
		If !IsInUpdate .And. !lWizard
			oAtuParc2:cCaption := STR0086; oAtuParc2:Refresh() //'Selecionando registros'
		EndIf	
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T., 'TOPCONN', TcGenQry(,, cQuery), cAliasTRB)
		dbSelectArea(cAliasTRB)
		dbGoTop()
	#ELSE
		cAliasTRB := 'SDB'
		cNomArqDB := CriaTrab('', .F.)
		cIndDB    := 'DB_PRODUTO+DB_LOCAL+DB_LOTECTL+DB_NUMLOTE+DB_NUMSEQ'
		cFiltroDB := 'DB_FILIAL=="'+xFilial('SDB')+'" .And. !Empty(DB_NUMLOTE)'
		IndRegua(cAliasTRB, cNomArqDB, cIndDB,, cFiltroDB, STR0075) //'Selecionando Registros...'
		nIndDB    := RetIndex('SDB')
		dbSetIndex(cNomArqDB + OrdBagExt())
		dbSetOrder(nIndDB + 1)
		dbGoTop()
	#ENDIF
	
	If !IsInUpdate .And. !lWizard
		oAtuParc2:cCaption := STR0076; oAtuParc2:Refresh() //'Processando o ajuste...'
	EndIf	
	Do While !(cAliasTRB)->(Eof())
		
		nContador ++
		If !IsInUpdate .And. !lWizard
			oMtParci:Set(++nAtuParci); SysRefresh()
			oAtuParc2:cCaption := AllTrim(Str(nContador))+If(nContador>1,STR0077, STR0078); oAtuParc2:Refresh()	 //' registros processados...'###' registro processado...'
		EndIf	
		
		//�����������������������������������������������������������������������Ŀ
		//� Processa somente produtos com controle de rastreabilidade igual a "L" �
		//�������������������������������������������������������������������������
		#IFNDEF TOP
			If !Rastro(SDB->DB_PRODUTO, 'L')
				SDB->(dbSkip())
				Loop
			EndIf
		#ENDIF
		
		//������������������������������������������������������������������������Ŀ
		//� Guarda em array o conteudo de todos os campos deste Produto+Local+Lote �
		//��������������������������������������������������������������������������
		#IFNDEF TOP
			cCondicao  := '!SDB->(Eof())'
		#ENDIF
		
			//������������������������������������������������Ŀ
			//� Atualiza os registros deste Produto+Local+Lote �
			//��������������������������������������������������
			#IFDEF TOP
				cQuery := "UPDATE "+RetSqlName('SDB')+" "
				cQuery += " SET DB_NUMLOTE = '"+cTamSLote+"' "
				cQuery += "WHERE R_E_C_N_O_ = "+Str((cAliasTRB)->DB_RECNO)+""
				TCSqlExec(cQuery)
				SDB->(dbGoto(Recno()))
			#ELSE
				If &cCondicao
					Do While &cCondicao
						RecLock('SDB', .F.)
						Replace DB_NUMLOTE With cTamSLote
						MsUnlock()
						SDB->(dbSkip())
					EndDo
				EndIf
			#ENDIF

			If lUpdEst08
				ExecBlock('PEUPDE08', .F., .F., {'SDB'})
			EndIf
			MsUnlock()
		(cAliasTRB)->(dbSkip())
	EndDo
	
	If !IsInUpdate .And. !lWizard
		oMtParci:Set(nTotCont); SysRefresh() //-- Finaliza a regua de processamento
	EndIf	
	
	#IFDEF TOP
		If Select(cAliasTRB) > 0
			dbSelectArea(cAliasTRB)
			dbCloseArea()
		EndIf
		//����������������������������������������������������������Ŀ
		//� A tabela eh fechada para restaurar o buffer da aplicacao �
		//������������������������������������������������������������
		dbSelectArea('SDB')
		dbCloseArea()
		ChkFile('SDB', .T.)
	#ELSE
		If File(cNomArqDB += OrdBagExt())
			fErase(cNomArqDB)
		EndIf			
	#ENDIF
	
	cTexto += STR0134+AllTrim(Str(nContador))+STR0080+PULALINHA
Else
	cTexto += STR0135+PULALINHA //' Tabela SDB: Nenhum registro processado. '
	cTexto += STR0087+PULALINHA //'	 Obs.: Esta tabela possui acesso compartilhado, situacao em que o ajuste eh feito apenas 1x por empresa.'
EndIf

//����������������������������������������Ŀ
//� Atualiza variaveis da janela principal �
//������������������������������������������
If !IsInUpdate .And. !lWizard
	oAtuParc1:cCaption := STR0144; oAtuParc1:Refresh() //'Ajuste da SDB finalizado!'
	oAtuParc2:cCaption := ''; oAtuParc2:Refresh()
	oAtuParc3:cCaption := ''; oAtuParc3:Refresh()
EndIf	

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �OpenSM0    � Autor �Sergio Silveira       � Data �07/01/2003���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Efetua a abertura do SM0 exclusivo                         ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Atualizacao EST                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function OpenSM0(lCompart)

Local lOpen      := .F.
Local nLoop      := 0

If Select('SM0') > 0
	dbSelectArea('SM0')
	dbCloseArea()
EndIf

For nLoop := 1 To 20
	OpenSM0Excl()
	If !Empty(Select("SM0"))
		lOpen := .T.
		dbSetOrder(1)
		Exit
	EndIf
	Sleep(500)
Next nLoop

Return lOpen

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �AbreEmpre �Autor  �Microsiga           � Data �  01/18/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function AbreEmpre(cCodEmp, cCodFil, cModulo)

RpcSetType(3) //-- Nao consome licensas
RpcSetEnv(cCodEmp, cCodFil,,,cModulo) //-- Inicializa as variaveis genericas e abre a empresa/filial

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �Concordo  �Autor  �Microsiga           � Data �  01/18/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function Concordo(lConcordo)

If lConcordo
	oBtnAvanca:lActive    := .T.
Else
	oBtnAvanca:lActive    := .F.
EndIf

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �GravaLog  �Autor  �Microsiga           � Data �  01/26/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function GravaLog(lSalvaUsu, cTexto, lRet, IsInUpdate)

Local cFile := ''
Local cMask      := 'Arquivos de Log (*.LOG) |*.log|'
Local nOcorr     := 0

Default IsInUpdate := .F.

If !lRet

	If lSalvaUsu
		cFile := cGetFile(cMask, '')
	EndIf	
	
	If Empty(cFile)
		cFile := 'UPE8'+Right(CriaTrab(, .F.), 4)+'.LOG'
		Do While File(cFile)
			cFile := 'UPE8'+Right(CriaTrab(, .F.), 4)+'.LOG'
		EndDo
		nOcorr := 1
	ElseIf !(Upper(Right(cFile, 4))=='.LOG')
		cFile += '.LOG'
		nOcorr := 2
	EndIf
	
	lRet := MemoWrite(cFile, cTexto)
	
	If !IsInUpdate
		If nOcorr == 1
			Aviso('Wizard - Lote Unico', STR0094+cFile+STR0095, {'Ok'}) //'Este LOG foi salvo automaticamente como '###' no diretorio dos SXs.'
		ElseIf nOcorr == 2
			Aviso('Wizard - Lote Unico', STR0096+cFile+').', {'Ok'}) //'A extencao .LOG foi adicionada ao arquivo, que foi salvo do diretorio escolhido ('
		EndIf
	EndIf	
	
EndIf	

Return Nil

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �CtrlMThrd � Autor � Emerson R. Oliveira   � Data � 15.01.10 ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Controla a execucao de Multiplas Threads                    ���
�������������������������������������������������������������������������Ĵ��
���Uso       �UPDEST08                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function CtrlMThrd(lQuery,aThreads,cEmp,cFil,aFil,IsInUpdate,lWizard)

Local cStartPath	:= GetSrvProfString("Startpath","")
Local nX			:= 0
Local nHdl			:= 0
Local nRetry_0		:= 0
Local nRetry_1		:= 0
Local nRetry_2		:= 0
Local nRetry_3		:= 0

Local cMens			:= ""
Local cJobFile		:= ""
Local cJobAux 		:= ""
Local cThread		:= ""
Local cProdIni		:= ""
Local cProdFim		:= ""
Local lStartJob		:= .T.

Private __cInterNet

Default lWizard		:= .F.

For nX := 1 To Len( aThreads )

	// Informacoes do semaforo
	cJobFile  := aThreads[nX][1]
	cJobAux   := aThreads[nX][2]
	cThread   := aThreads[nX][3]
	cProdIni  := aThreads[nX][4]
	cProdFim  := aThreads[nX][5]
	
	nHdl      := 0  // Endereco do arquivo de semaforo
	nRetry_0  := 0  // Numero de tentativas de execucao
	nRetry_1  := 0  // Numero de tentativas de execucao
	nRetry_2  := 0  // Numero de tentativas de execucao
	nRetry_3  := 0  // Numero de tentativas de execucao
			
	//��������������������������������������������������������������Ŀ
	//� Analise das Threads em Execucao                              �
	//����������������������������������������������������������������
	While .T.
		Do Case
			// TRATAMENTO PARA ERRO DE SUBIDA DE THREAD
			Case GetGlbValue(cJobAux) == "0"
				If nRetry_0 > 50
					// Nao foi possivel incializar a thread
					cMens := (OemToAnsi(STR0136)+cJobAux)	
					If !lWizard
						ProcLogAtu("MENSAGEM",cMens,cMens,"UPDEST08")
						Final(OemToAnsi(STR0136)+cJobAux)
					Endif
				Else
	            	nRetry_0++
				EndIf
	
			// TRATAMENTO PARA ERRO DE CONEXAO
			Case GetGlbValue(cJobAux) == "1"
				If FCreate(cJobFile) # -1
					If nRetry_1 > 5
						// Erro de conexao na thread ## Numero de tentativas excedidas
						cMens := (OemToAnsi(STR0137)+cJobAux)
						If !lWizard
							ProcLogAtu("MENSAGEM",cMens,OemToAnsi(STR0138),"UPDEST08")
							Final(OemToAnsi(STR0137)+cJobAux)
						Endif
					Else
		    			// Inicializa variavel global de controle de Job
						PutGlbValue(cJobAux,"0")
						GlbUnLock()
						
						// Erro de conexao na thread ## Reiniciando a thread:
						cMens := (OemToAnsi(STR0137)+cJobAux)
						ProcLogAtu("MENSAGEM",cMens,OemToAnsi(STR0139)+cJobAux,"UPDEST08")
						
						// Nome do arquivo para nova thread
						cJobFile := cStartPath + CriaTrab(Nil,.F.)+".job"	
						
						//���������������������������������������������Ŀ
						//� Dispara a thread novamente                  �
						//�����������������������������������������������
						StartJob(cThread,GetEnvServer(),lStartJob,aFil,IsInUpdate,cEmp,cFil,cJobFile,cJobAux,cProdIni,cProdFim)
					EndIf
					nRetry_1++ 
				EndIf
	
			// TRATAMENTO PARA ERRO DE APLICACAO
			Case GetGlbValue(cJobAux) == "2"
				If FCreate(cJobFile) # -1
					If nRetry_2 > 5
						// Erro de conexao na thread ## Erro de aplicacao na thread
						cMens := (OemToAnsi(STR0137)+cJobAux)
						If !lWizard
							ProcLogAtu("MENSAGEM",cMens,OemToAnsi(STR0140)+cJobAux,"UPDEST08")
							Final(OemToAnsi(STR0140)+cJobAux)
						Endif
					Endif
					nRetry_2++
				EndIf
	
			// THREAD PROCESSADA CORRETAMENTE
			Case GetGlbValue(cJobAux) == "3"
				//�������������������������������������Ŀ
				//� Finalizando JOB                     �
				//���������������������������������������
				cMens := OemToAnsi(STR0141)+cJobAux
				If !lWizard
					ProcLogAtu("MENSAGEM",cMens,cMens,"UPDEST08")
					ConOut( cMens )
				Endif
				Exit
		EndCase
		Sleep(500)
	Enddo
	// Fecha o arquivo da thread
	FClose(nHdl)
	// Apaga arquivo da thread
	If File(cJobFile)
		FErase(cJobFile)
	EndIf
Next 

Return


/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �WzThrSB8 � Autor � Emerson R. Oliveira   � Data � 15.01.10 ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Funcao de processamento do ajuste da tabela SB8             ���
�������������������������������������������������������������������������Ĵ��
���Uso       �UPDEST08                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function WzThrSB8(aFilSB8, IsInUpdate, cEmp, cFil, cJobFile, cJobAux, cProdIni, cProdFim)

Local aCampos    := {}
Local aStruSB8   := {}
Local cQuery     := ''
Local cAliasTRB  := ''
Local lUpdEst08  := ExistBlock('PEUPDE08')
Local nX         := 0
Local nContador  := 0
Local nRecsSB8   := 0
Local nHd1

Private __cInterNet

// Apaga arquivo ja existente
If File(cJobFile)
	fErase(cJobFile)
EndIf

// Criacao do arquivo de controle de jobs
nHd1 := MSFCreate(cJobFile)

// STATUS 1 - Iniciando execucao do Job
PutGlbValue(cJobAux,"1")
GlbUnLock()

// Seta job para nao consumir licencas
RpcSetType(3)

// Seta job para empresa filial desejada
RpcSetEnv(cEmp,cFil,,,"EST")

// STATUS 2 - Conexao efetuada com sucesso
PutGlbValue(cJobAux,"2")
GlbUnLock()

//��������������������Ŀ
//� Inicializando JOB  �
//����������������������
cMens := OemToAnsi(STR0143)+"("+cJobAux+")"
ProcLogAtu("MENSAGEM",cMens,cMens,"UPDEST08")

dbSelectArea("SB8")
aStruSB8 := SB8->(dbStruct())
nRecsSB8 := Max(1, SB8->(LastRec()))

If aScan(aFilSB8, SB8->(xFilial('SB8'))) == 0
	aAdd(aFilSB8, SB8->(xFilial('SB8')))
	dbSelectArea('SB8')
	dbSetOrder(3) //-- B8_FILIAL+B8_PRODUTO+B8_LOCAL+B8_LOTECTL+B8_NUMLOTE+DTOS(B8_DTVALID)

	cAliasTRB := GetNextAlias() //'TRBSB8'
	//����������������Ŀ
	//� Campos da VIEW �
	//������������������
	cQuery := "SELECT "
	cQuery += " SB8.B8_FILIAL,"
	cQuery += " SB8.B8_PRODUTO,"
	cQuery += " SB8.B8_LOCAL,"
	cQuery += " SB8.B8_LOTECTL,"
	cQuery += " SUM(SB8.B8_QTDORI) B8_QTDORI,"
	cQuery += " SUM(SB8.B8_QTDORI2) B8_QTDORI2,"
	cQuery += " MIN(SB8.B8_DATA) B8_DATA,"
	cQuery += " MAX(SB8.B8_DTVALID) B8_DTVALID,"
	cQuery += " SUM(SB8.B8_SALDO) B8_SALDO,"
	cQuery += " SUM(SB8.B8_SALDO2) B8_SALDO2,"
	cQuery += " SUM(SB8.B8_EMPENHO) B8_EMPENHO,"
	cQuery += " SUM(SB8.B8_EMPENH2) B8_EMPENH2,"
	cQuery += " SUM(SB8.B8_QEMPPRE) B8_QEMPPRE,"
	cQuery += " SUM(SB8.B8_QEPRE2) B8_QEPRE2,"
	cQuery += " SUM(SB8.B8_QACLASS) B8_QACLASS,"
	cQuery += " SUM(SB8.B8_QACLAS2) B8_QACLAS2,"
	cQuery += " MAX(SB8.B8_POTENCI) B8_POTENCI,"
	cQuery += " MAX(SB8.B8_PRCLOT) B8_PRCLOT "
	cQuery += "FROM "+RetSqlName('SB8')+" SB8 "
	
	//��������������������������������Ŀ
	//� Condicoes JOIN entre SB8 e SB1 �
	//����������������������������������
	cQuery += "JOIN "+RetSqlName('SB1')+" SB1 "
	cQuery += "ON SB1.B1_FILIAL = '"+xFilial('SB1')+"'"
	cQuery += " AND SB1.B1_COD = SB8.B8_PRODUTO"
	cQuery += " AND SB1.B1_RASTRO = 'L'"
	cQuery += " AND SB1.D_E_L_E_T_  = ' ' "
	
	//���������������Ŀ
	//� Condicoes SB8 �
	//�����������������
	cQuery += "WHERE SB8.B8_FILIAL = '"+xFilial('SB8')+"'"
	cQuery += " AND SB8.B8_PRODUTO BETWEEN '"+cProdIni+"' AND '"+cProdFim+"' "
	cQuery += " AND SB8.B8_LOTECTL <> ' ' "
	cQuery += " AND SB8.B8_NUMLOTE <> ' ' "
	cQuery += " AND SB8.D_E_L_E_T_  = ' ' "
	
	//�������������������������������Ŀ
	//� Clausulas GROUP BY e ORDER BY �
	//���������������������������������
	cQuery += "GROUP BY SB8.B8_FILIAL, SB8.B8_PRODUTO, SB8.B8_LOCAL, SB8.B8_LOTECTL "
	cQuery += "ORDER BY SB8.B8_FILIAL, SB8.B8_PRODUTO, SB8.B8_LOCAL, SB8.B8_LOTECTL"
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T., 'TOPCONN', TcGenQry(,, cQuery), cAliasTRB)
	For nX := 1 To Len(aStruSB8)
		If !aStruSB8[nX, 2]$'CM' .And. !(FieldPos(aStruSB8[nX, 1])==0)
			TcSetField(cAliasTRB, aStruSB8[nX, 1], aStruSB8[nX, 2], aStruSB8[nX, 3], aStruSB8[nX, 4])
		EndIf
	Next nX
	dbSelectArea(cAliasTRB)
	dbGoTop()
	
	Do While !(cAliasTRB)->(Eof())
		
		nContador ++
		
		//������������������������������������������������������������������������Ŀ
		//� Guarda em array o conteudo de todos os campos deste Produto+Local+Lote �
		//��������������������������������������������������������������������������
		aCampos := Array(17)
		
		//����������������������������Ŀ
		//� Campos com conteudos fixos �
		//������������������������������
		aCampos[01] := (cAliasTRB)->B8_PRODUTO
		aCampos[02] := (cAliasTRB)->B8_LOCAL
		aCampos[03] := (cAliasTRB)->B8_LOTECTL
		
		//������������������������������������������Ŀ
		//� Campos com conteudos a serem aglutinados �
		//��������������������������������������������
		aCampos[04] := (cAliasTRB)->B8_DATA
		aCampos[05] := (cAliasTRB)->B8_DTVALID
		aCampos[06] := (cAliasTRB)->B8_QTDORI
		aCampos[07] := (cAliasTRB)->B8_QTDORI2
		aCampos[08] := (cAliasTRB)->B8_SALDO
		aCampos[09] := (cAliasTRB)->B8_SALDO2
		aCampos[10] := (cAliasTRB)->B8_EMPENHO
		aCampos[11] := (cAliasTRB)->B8_EMPENH2
		aCampos[12] := (cAliasTRB)->B8_QEMPPRE
		aCampos[13] := (cAliasTRB)->B8_QEPRE2
		aCampos[14] := (cAliasTRB)->B8_QACLASS
		aCampos[15] := (cAliasTRB)->B8_QACLAS2
		aCampos[16] := (cAliasTRB)->B8_POTENCI
		aCampos[17] := (cAliasTRB)->B8_PRCLOT
		
		//��������������������������������������������������Ŀ
		//� Deleta os registros com deste Produto+Local+Lote �
		//����������������������������������������������������
		cQuery  := "DELETE FROM "+RetSqlName('SB8')+" "
		cQuery  += "WHERE B8_FILIAL = '"+xFilial('SB8')+"'"
		cQuery  +=  " AND B8_PRODUTO = '"+aCampos[01]+"'"
		cQuery  +=  " AND B8_LOCAL = '"  +aCampos[02]+"'"
		cQuery  +=  " AND B8_LOTECTL = '"+aCampos[03]+"'"
		cQuery  +=  " AND D_E_L_E_T_ = ' '"
		TCSqlExec(cQuery)
		SB8->(dbGoto(Recno()))
		
		//�������������������������������������������������������������������������������Ŀ
		//� Inclui registro unico deste Produto+Local+Lote com as quantidades aglutinadas �
		//���������������������������������������������������������������������������������
		RecLock('SB8', .T.)
		Replace B8_FILIAL  With xFilial('SB8'), ; //-- Filial do Sistema
				B8_PRODUTO With aCampos[01], ; //-- Codigo do Produto
				B8_LOCAL   With aCampos[02], ; //-- Armazem
				B8_LOTECTL With aCampos[03], ; //-- Lote
				B8_DATA    With aCampos[04], ; //-- Data da Criacao do Lote
				B8_DTVALID With aCampos[05], ; //-- Data de Validade do Lote
				B8_QTDORI  With aCampos[06], ; //-- Quantidade Original
				B8_QTDORI2 With aCampos[07], ; //-- Quantidade Original 2a UM
				B8_SALDO   With aCampos[08], ; //-- Saldo do Lote
				B8_SALDO2  With aCampos[09], ; //-- Saldo do Lote 2a UM
				B8_EMPENHO With aCampos[10], ; //-- Empenho do Lote
				B8_EMPENH2 With aCampos[11], ; //-- Empenho do Lote 2a UM
				B8_QEMPPRE With aCampos[12], ; //-- Quantidade Empenhada Prev
				B8_QEPRE2  With aCampos[13], ; //-- Qtde Emp. Prevista 2a UM
				B8_QACLASS With aCampos[14], ; //-- Quantidade a Distribuir
				B8_QACLAS2 With aCampos[15], ; //-- Qtde a Distribuir 2a UM
				B8_POTENCI With aCampos[16], ; //-- Potencia do Lote
				B8_PRCLOT  With aCampos[17], ; //-- Preco do Lote
				B8_DOC     With 'AJUSTE'   , ; //-- Numero do Documento
				B8_SERIE   With 'UNI'      , ; //-- Serie do Documento
				B8_ORIGLAN With 'MI'           //-- Origem do Lancamento
		If lUpdEst08
			ExecBlock('PEUPDE08', .F., .F., {'SB8'})
		EndIf
		MsUnlock()

		(cAliasTRB)->(dbSkip())
	EndDo
	
	If Select(cAliasTRB) > 0
		dbSelectArea(cAliasTRB)
		dbCloseArea()
	EndIf
	//����������������������������������������������������������Ŀ
	//� A tabela eh fechada para restaurar o buffer da aplicacao �
	//������������������������������������������������������������
	dbSelectArea('SB8')
	dbCloseArea()
	ChkFile('SB8', .T.)
EndIf

PutGlbValue(cJobAux,"3")
GlbUnLock()
RpcClearEnv()
FClose(nHd1)

Return Nil

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �WhThrSD5 � Autor � Emerson R. Oliveira   � Data � 15.01.10 ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Funcao de processamento do ajuste da tabela SD5             ���
�������������������������������������������������������������������������Ĵ��
���Uso       �UPDEST08                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function WhThrSD5(aFilSD5, IsInUpdate, cEmp, cFil, cJobFile, cJobAux, cProdIni, cProdFim)

Local aCampos    := {}
Local aStruSD5   := {}
Local cQuery     := ''
Local cAliasTRB  := ''
Local lUpdEst08  := ExistBlock('PEUPDE08')
Local nX         := 0
Local nContador  := 0
Local nRecsSD5   := 0
Local nHd1

Private __cInterNet

// Apaga arquivo ja existente
If File(cJobFile)
	fErase(cJobFile)
EndIf

// Criacao do arquivo de controle de jobs
nHd1 := MSFCreate(cJobFile)

// STATUS 1 - Iniciando execucao do Job
PutGlbValue(cJobAux,"1")
GlbUnLock()

// Seta job para nao consumir licencas
RpcSetType(3)

// Seta job para empresa filial desejada
RpcSetEnv(cEmp,cFil,,,"EST")

// STATUS 2 - Conexao efetuada com sucesso
PutGlbValue(cJobAux,"2")
GlbUnLock()

//��������������������Ŀ
//� Inicializando JOB  �
//����������������������
cMens := OemToAnsi(STR0143)+"("+cJobAux+")"
ProcLogAtu("MENSAGEM",cMens,cMens,"UPDEST08")

dbSelectArea("SD5")
aStruSD5 := SD5->(dbStruct())
nRecsSD5 := Max(1, SD5->(LastRec()))

If aScan(aFilSD5, SD5->(xFilial('SD5'))) == 0
	aAdd(aFilSD5, SD5->(xFilial('SD5')))
	dbSelectArea('SD5')
	dbSetOrder(3) //-- D5_FILIAL+D5_NUMSEQ+D5_PRODUTO+D5_LOCAL+D5_LOTECTL+D5_NUMLOTE
	cAliasTRB := GetNextAlias() //'TRBSD5'
	
	//����������������Ŀ
	//� Campos da VIEW �
	//������������������
	cQuery := "SELECT "
	cQuery += " SD5.D5_FILIAL,"
	cQuery += " SD5.D5_NUMSEQ,"
	cQuery += " SD5.D5_PRODUTO,"
	cQuery += " SD5.D5_LOCAL,"
	cQuery += " SD5.D5_LOTECTL,"
	cQuery += " SD5.D5_ORIGLAN,"
	cQuery += " SD5.D5_DOC,"
	cQuery += " SD5.D5_SERIE,"
	cQuery += " SD5.D5_OP," 
	cQuery += " SD5.D5_ESTORNO,"
	cQuery += " SD5.D5_DATA,"
	cQuery += " MAX(SD5.D5_DTVALID) D5_DTVALID,"
	cQuery += " MAX(SD5.D5_POTENCI) D5_POTENCI,"
	cQuery += " SUM(SD5.D5_QUANT) D5_QUANT,"
	cQuery += " SUM(SD5.D5_QTSEGUM) D5_QTSEGUM "
	cQuery += "FROM "+RetSqlName('SD5')+" SD5 "
	
	//��������������������������������Ŀ
	//� Condicoes JOIN entre SD5 e SB1 �
	//����������������������������������
	cQuery += "JOIN "+RetSqlName('SB1')+" SB1 "
	cQuery += "ON SB1.B1_FILIAL = '"+xFilial('SB1')+"' "
	cQuery += " AND SB1.B1_COD = SD5.D5_PRODUTO"
	cQuery += " AND SB1.B1_RASTRO = 'L' "
	cQuery += " AND SB1.D_E_L_E_T_  = ' ' "
	
	//���������������Ŀ
	//� Condicoes SD5 �
	//�����������������
	cQuery += "WHERE SD5.D5_FILIAL = '"+xFilial('SD5')+"' "
	cQuery += " AND SD5.D5_PRODUTO BETWEEN '"+cProdIni+"' AND '"+cProdFim+"' "
	cQuery += " AND SD5.D5_LOTECTL <> ' ' "
	cQuery += " AND SD5.D5_NUMLOTE <> ' ' "
	cQuery += " AND SD5.D_E_L_E_T_  = ' ' "
	
	//�������������������������������Ŀ
	//� Clausulas GROUP BY e ORDER BY �
	//���������������������������������
	cQuery += " GROUP BY SD5.D5_FILIAL, SD5.D5_NUMSEQ, SD5.D5_PRODUTO, SD5.D5_LOCAL, SD5.D5_LOTECTL, SD5.D5_ORIGLAN, SD5.D5_DOC, SD5.D5_SERIE, SD5.D5_OP, SD5.D5_ESTORNO, SD5.D5_DATA "
	cQuery += " ORDER BY SD5.D5_FILIAL, SD5.D5_NUMSEQ, SD5.D5_PRODUTO, SD5.D5_LOCAL, SD5.D5_LOTECTL, SD5.D5_ORIGLAN, SD5.D5_DOC, SD5.D5_SERIE, SD5.D5_OP, SD5.D5_ESTORNO, SD5.D5_DATA "
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T., 'TOPCONN', TcGenQry(,, cQuery), cAliasTRB)
	For nX := 1 To Len(aStruSD5)
		If !aStruSD5[nX, 2]$'CM' .And. !(FieldPos(aStruSD5[nX, 1])==0)
			TcSetField(cAliasTRB, aStruSD5[nX, 1], aStruSD5[nX, 2], aStruSD5[nX, 3], aStruSD5[nX, 4])
		EndIf
	Next nX
	dbSelectArea(cAliasTRB)
	dbGoTop()
	
	Do While !(cAliasTRB)->(Eof())
		
		nContador ++
		
		//������������������������������������������������������������������������Ŀ
		//� Guarda em array o conteudo de todos os campos deste Produto+Local+Lote �
		//��������������������������������������������������������������������������
		aCampos := Array(14)
		
		//����������������������������Ŀ
		//� Campos com conteudos fixos �
		//������������������������������
		aCampos[01] := (cAliasTRB)->D5_NUMSEQ
		aCampos[02] := (cAliasTRB)->D5_PRODUTO
		aCampos[03] := (cAliasTRB)->D5_LOCAL
		aCampos[04] := (cAliasTRB)->D5_LOTECTL
		aCampos[05] := (cAliasTRB)->D5_ORIGLAN
		aCampos[06] := (cAliasTRB)->D5_DOC
		aCampos[07] := (cAliasTRB)->D5_SERIE
		aCampos[08] := (cAliasTRB)->D5_OP
		aCampos[09] := (cAliasTRB)->D5_ESTORNO
		aCampos[10] := (cAliasTRB)->D5_DATA

		//������������������������������������������Ŀ
		//� Campos com conteudos a serem aglutinados �
		//��������������������������������������������
		aCampos[11] := (cAliasTRB)->D5_DTVALID
		aCampos[12] := (cAliasTRB)->D5_QUANT
		aCampos[13] := (cAliasTRB)->D5_QTSEGUM
		aCampos[14] := (cAliasTRB)->D5_POTENCI
		
		//������������������������������������������������������������������������������������Ŀ
		//� Deleta os registros com deste Numseq+Produto+Local+Lote+OrigLan+Documento+Serie+OP �
		//��������������������������������������������������������������������������������������
		cQuery  := "DELETE FROM "+RetSqlName('SD5')+" "
		cQuery  += "WHERE D5_FILIAL = '"+xFilial('SD5')+"'"
		cQuery  += " AND D5_NUMSEQ = '" +aCampos[01]+"'"
		cQuery  += " AND D5_PRODUTO = '"+aCampos[02]+"'"
		cQuery  += " AND D5_LOCAL = '"  +aCampos[03]+"'"
		cQuery  += " AND D5_LOTECTL = '"+aCampos[04]+"'"
		cQuery  += " AND D5_ORIGLAN = '"+aCampos[05]+"'"
		cQuery  += " AND D5_DOC = '"    +aCampos[06]+"'"
		cQuery  += " AND D5_SERIE = '"  +aCampos[07]+"'"
		cQuery  += " AND D5_OP  = '"    +aCampos[08]+"'"
		cQuery  += " AND D5_ESTORNO = '"+aCampos[09]+"'"
		cQuery  += " AND D5_DATA = '"+DTOS(aCampos[10])+"'"
		TCSqlExec(cQuery)
		SD5->(dbGoto(Recno()))
			
			//�����������������������������������������������������������������������������������������������������������������Ŀ
			//� Inclui registro unico deste Numseq+Produto+Local+Lote+OrigLan+Documento+Serie+OP com as quantidades aglutinadas �
			//�������������������������������������������������������������������������������������������������������������������
			RecLock('SD5', .T.)
			Replace D5_FILIAL  With xFilial('SD5'), ; //-- Filial do Sistema
					D5_NUMSEQ  With aCampos[01], ; //-- Numero Qequencial
					D5_PRODUTO With aCampos[02], ; //-- Codigo do produto
					D5_LOCAL   With aCampos[03], ; //-- Armazem
					D5_LOTECTL With aCampos[04], ; //-- Lote
					D5_ORIGLAN With aCampos[05], ; //-- Origem do lancamento
					D5_DOC     With aCampos[06], ; //-- Documento
					D5_SERIE   With aCampos[07], ; //-- Serie
					D5_OP      With aCampos[08], ; //-- Ordem de producao
					D5_ESTORNO With aCampos[09], ; //-- Movimento Estornado?
					D5_DATA    With aCampos[10], ; //-- Data de entrada
					D5_DTVALID With aCampos[11], ; //-- Data de validade
					D5_QUANT   With aCampos[12], ; //-- Quantidade
					D5_QTSEGUM With aCampos[13], ; //-- Quantidade 2UM
					D5_POTENCI With aCampos[14]    //-- Potencia do Lote
			If lUpdEst08
				ExecBlock('PEUPDE08', .F., .F., {'SD5'})
			EndIf
			MsUnlock()
		(cAliasTRB)->(dbSkip())
	EndDo
	
	If Select(cAliasTRB) > 0
		dbSelectArea(cAliasTRB)
		dbCloseArea()
	EndIf
	//����������������������������������������������������������Ŀ
	//� A tabela eh fechada para restaurar o buffer da aplicacao �
	//������������������������������������������������������������
	dbSelectArea('SD5')
	dbCloseArea()
	ChkFile('SD5', .T.)
EndIf

PutGlbValue(cJobAux,"3")
GlbUnLock()
FClose(nHd1)
RpcClearEnv()

Return Nil

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �WzThrSBJ � Autor � Emerson R. Oliveira   � Data � 15.01.10 ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Funcao de processamento do ajuste da tabela SBJ             ���
�������������������������������������������������������������������������Ĵ��
���Uso       �UPDEST08                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function WzThrSBJ(aFilSBJ, IsInUpdate, cEmp, cFil, cJobFile, cJobAux, cProdIni, cProdFim)

Local aCampos    := {}
Local aStruSBJ   := {}
Local cQuery     := ''
Local cAliasTRB  := ''
Local lUpdEst08  := ExistBlock('PEUPDE08')
Local nX         := 0
Local nContador  := 0
Local nRecsSBJ   := 0
Local nHd1

Private __cInterNet

// Apaga arquivo ja existente
If File(cJobFile)
	fErase(cJobFile)
EndIf

// Criacao do arquivo de controle de jobs
nHd1 := MSFCreate(cJobFile)

// STATUS 1 - Iniciando execucao do Job
PutGlbValue(cJobAux,"1")
GlbUnLock()

// Seta job para nao consumir licencas
RpcSetType(3)

// Seta job para empresa filial desejada
RpcSetEnv(cEmp,cFil,,,"EST")

// STATUS 2 - Conexao efetuada com sucesso
PutGlbValue(cJobAux,"2")
GlbUnLock()

//��������������������Ŀ
//� Inicializando JOB  �
//����������������������
cMens := OemToAnsi(STR0143)+"("+cJobAux+")"
ProcLogAtu("MENSAGEM",cMens,cMens,"UPDEST08")

dbSelectArea("SBJ")
aStruSBJ := SBJ->(dbStruct())
nRecsSBJ := Max(1, SBJ->(LastRec()))

If aScan(aFilSBJ, SBJ->(xFilial('SBJ'))) == 0
	aAdd(aFilSBJ, SBJ->(xFilial('SBJ')))
	dbSelectArea('SBJ')
	dbSetOrder(1) //-- BJ_FILIAL+BJ_COD+BJ_LOCAL+BJ_LOTECTL+BJ_NUMLOTE+DTOS(BJ_DATA)
	cAliasTRB := GetNextAlias() //'TRBSBJ'
	
	//����������������Ŀ
	//� Campos da VIEW �
	//������������������
	cQuery := "SELECT "
	cQuery += " SBJ.BJ_COD,"
	cQuery += " SBJ.BJ_LOCAL,"
	cQuery += " SBJ.BJ_LOTECTL,"
	cQuery += " SBJ.BJ_DATA,"
	cQuery += " MAX(SBJ.BJ_DTVALID) BJ_DTVALID,"
	cQuery += " SUM(SBJ.BJ_QINI) BJ_QINI,"
	cQuery += " SUM(SBJ.BJ_QISEGUM) BJ_QISEGUM "
	cQuery += "FROM "+RetSqlName('SBJ')+" SBJ "
	
	//��������������������������������Ŀ
	//� Condicoes JOIN entre SBJ e SB1 �
	//����������������������������������
	cQuery += "JOIN "+RetSqlName('SB1')+" SB1 "
	cQuery += "ON SB1.B1_FILIAL = '"+xFilial('SB1')+"'"
	cQuery += " AND SB1.B1_COD = SBJ.BJ_COD"
	cQuery += " AND SB1.B1_RASTRO = 'L'"
	cQuery += " AND SB1.D_E_L_E_T_  = ' ' "
	
	//���������������Ŀ
	//� Condicoes SBJ �
	//�����������������
	cQuery += "WHERE SBJ.BJ_FILIAL = '"+xFilial('SBJ')+"'"
	cQuery += " AND SBJ.BJ_COD BETWEEN '"+cProdIni+"' AND '"+cProdFim+"' "
	cQuery += " AND SBJ.BJ_LOTECTL <> ' ' "
	cQuery += " AND SBJ.BJ_NUMLOTE <> ' ' "
	cQuery += " AND SBJ.D_E_L_E_T_  = ' ' "
	
	//�������������������������������Ŀ
	//� Clausulas GROUP BY e ORDER BY �
	//���������������������������������
	cQuery += "GROUP BY SBJ.BJ_FILIAL, SBJ.BJ_COD, SBJ.BJ_LOCAL, SBJ.BJ_LOTECTL, SBJ.BJ_DATA "
	cQuery += "ORDER BY SBJ.BJ_FILIAL, SBJ.BJ_COD, SBJ.BJ_LOCAL, SBJ.BJ_LOTECTL, SBJ.BJ_DATA"
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T., 'TOPCONN', TcGenQry(,, cQuery), cAliasTRB)
	For nX := 1 To Len(aStruSBJ)
		If !aStruSBJ[nX, 2]$'CM' .And. !(FieldPos(aStruSBJ[nX, 1])==0)
			TcSetField(cAliasTRB, aStruSBJ[nX, 1], aStruSBJ[nX, 2], aStruSBJ[nX, 3], aStruSBJ[nX, 4])
		EndIf
	Next nX
	dbSelectArea(cAliasTRB)
	dbGoTop()
	
	Do While !(cAliasTRB)->(Eof())
		
		nContador ++
		
		//������������������������������������������������������������������������Ŀ
		//� Guarda em array o conteudo de todos os campos deste Produto+Local+Lote �
		//��������������������������������������������������������������������������
		aCampos := Array(7)
		
		//����������������������������Ŀ
		//� Campos com conteudos fixos �
		//������������������������������
		aCampos[01] := (cAliasTRB)->BJ_COD
		aCampos[02] := (cAliasTRB)->BJ_LOCAL
		aCampos[03] := (cAliasTRB)->BJ_LOTECTL
		aCampos[04] := (cAliasTRB)->BJ_DATA
		
		//������������������������������������������Ŀ
		//� Campos com conteudos a serem aglutinados �
		//��������������������������������������������
		aCampos[05] := (cAliasTRB)->BJ_DTVALID
		aCampos[06] := (cAliasTRB)->BJ_QINI
		aCampos[07] := (cAliasTRB)->BJ_QISEGUM

		//��������������������������������������������������Ŀ
		//� Deleta os registros com deste Produto+Local+Lote �
		//����������������������������������������������������
		cQuery  := "DELETE FROM "+RetSqlName('SBJ')+" "
		cQuery  += "WHERE BJ_FILIAL = '"+xFilial('SBJ')+"'"
		cQuery  += " AND BJ_COD = '"    +aCampos[01]+"'"
		cQuery  += " AND BJ_LOCAL = '"  +aCampos[02]+"'"
		cQuery  += " AND BJ_LOTECTL = '"+aCampos[03]+"'"
		cQuery  += " AND BJ_DATA = '"+DTOS(aCampos[04])+"'"
		cQuery  += " AND D_E_L_E_T_ = ' '"
		TCSqlExec(cQuery)
		SBJ->(dbGoto(Recno()))

			
			//�������������������������������������������������������������������������������Ŀ
			//� Inclui registro unico deste Produto+Local+Lote com as quantidades aglutinadas �
			//���������������������������������������������������������������������������������
			RecLock('SBJ', .T.)
			Replace BJ_FILIAL  With xFilial('SBJ'), ; //-- Filial do Sistema
					BJ_COD     With aCampos[01], ; //-- Codigo do Produto
					BJ_LOCAL   With aCampos[02], ; //-- Armazem
					BJ_LOTECTL With aCampos[03], ; //-- Lote
					BJ_DATA    With aCampos[04], ; //-- Data da Criacao do lote
					BJ_DTVALID With aCampos[05], ; //-- Data de Validade do lote
					BJ_QINI    With aCampos[06], ; //-- Quantidade inicial do lote
					BJ_QISEGUM With aCampos[07]    //-- Quantidade inicial 2UM
			If lUpdEst08
				ExecBlock('PEUPDE08', .F., .F., {'SBJ'})
			EndIf
			MsUnlock()
		(cAliasTRB)->(dbSkip())
	EndDo
	
	If Select(cAliasTRB) > 0
		dbSelectArea(cAliasTRB)
		dbCloseArea()
	EndIf
	//����������������������������������������������������������Ŀ
	//� A tabela eh fechada para restaurar o buffer da aplicacao �
	//������������������������������������������������������������
	dbSelectArea('SBJ')
	dbCloseArea()
	ChkFile('SBJ', .T.)
EndIf

PutGlbValue(cJobAux,"3")
GlbUnLock()
RpcClearEnv()
FClose(nHd1)

Return Nil

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �WzThrSBF � Autor �Emerson R. Oliveira    � Data �13/01/10  ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Funcao de processamento do ajuste da tabela SBF            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � UPDEST08                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function WzThrSBF(aFilSBF, IsInUpdate, cEmp, cFil, cJobFile, cJobAux, cProdIni, cProdFim)

Local aCampos    := {}
Local aStruSBF   := {}
Local cQuery     := ''
Local cAliasTRB  := ''
Local lUpdEst08  := ExistBlock('PEUPDE08')
Local nX         := 0
Local nContador  := 0
Local nRecsSBF   := 0
Local nHd1

Private __cInterNet

// Apaga arquivo ja existente
If File(cJobFile)
	fErase(cJobFile)
EndIf

// Criacao do arquivo de controle de jobs
nHd1 := MSFCreate(cJobFile)

// STATUS 1 - Iniciando execucao do Job
PutGlbValue(cJobAux,"1")
GlbUnLock()

// Seta job para nao consumir licencas
RpcSetType(3)

// Seta job para empresa filial desejada
RpcSetEnv(cEmp,cFil,,,"EST")

// STATUS 2 - Conexao efetuada com sucesso
PutGlbValue(cJobAux,"2")
GlbUnLock()

//��������������������Ŀ
//� Inicializando JOB  �
//����������������������
cMens := OemToAnsi(STR0143)+"("+cJobAux+")"
ProcLogAtu("MENSAGEM",cMens,cMens,"UPDEST08")

dbSelectArea("SBF")
aStruSBF := SBF->(dbStruct())
nRecsSBF := Max(1, SBF->(LastRec()))

If aScan(aFilSBF, SBF->(xFilial('SBF'))) == 0
	aAdd(aFilSBF, SBF->(xFilial('SBF')))
	dbSelectArea('SBF')
	dbSetOrder(2) //-- BF_FILIAL+BF_PRODUTO+BF_LOCAL+BF_LOTECTL+BF_NUMLOTE+BF_PRIOR+BF_LOCALIZ+BF_NUMSERI
	cAliasTRB := GetNextAlias() //'TRBSBF'
	//����������������Ŀ
	//� Campos da VIEW �
	//������������������
	cQuery := "SELECT "
	cQuery += " SBF.BF_FILIAL, "
	cQuery += " SBF.BF_PRODUTO, "
	cQuery += " SBF.BF_LOCAL, "
	cQuery += " SBF.BF_LOCALIZ, "
	cQuery += " SBF.BF_NUMSERI, "
	cQuery += " SBF.BF_ESTFIS, "
	cQuery += " SBF.BF_LOTECTL, "
	cQuery += " SUM(SBF.BF_QUANT) BF_QUANT, "
	cQuery += " SUM(SBF.BF_EMPENHO) BF_EMPENHO, "
	cQuery += " SUM(SBF.BF_QEMPPRE) BF_QEMPPRE, "
	cQuery += " SUM(SBF.BF_QTSEGUM) BF_QTSEGUM, "
	cQuery += " SUM(SBF.BF_EMPEN2) BF_EMPEN2, "
	cQuery += " SUM(SBF.BF_QEPRE2) BF_QEPRE2, "
	cQuery += " MAX(SBF.BF_DATAVEN) BF_DATAVEN, "
	cQuery += " MIN(SBF.BF_PRIOR) BF_PRIOR "
	cQuery += "FROM "+RetSqlName('SBF')+" SBF "
	
	//��������������������������������Ŀ
	//� Condicoes JOIN entre SBF e SB1 �
	//����������������������������������
	cQuery += " JOIN "+RetSqlName('SB1')+" SB1 "
	cQuery += " ON SB1.B1_FILIAL = '"+xFilial('SB1')+"'"
	cQuery += " AND SB1.B1_COD = SBF.BF_PRODUTO"
	cQuery += " AND SB1.B1_RASTRO  = 'L'"
	cQuery += " AND SB1.B1_LOCALIZ = 'S'"
	cQuery += " AND SB1.D_E_L_E_T_ = ' ' "
	
	//���������������Ŀ
	//� Condicoes SBF �
	//�����������������
	cQuery += "WHERE SBF.BF_FILIAL = '"+xFilial('SBF')+"' "
	cQuery += " AND SBF.BF_PRODUTO BETWEEN '"+cProdIni+"' AND '"+cProdFim+"' "
	cQuery += " AND SBF.D_E_L_E_T_  = ' ' "
	cQuery += " AND SBF.BF_LOTECTL <> ' ' "
	cQuery += " AND SBF.BF_NUMLOTE <> ' ' "
	
	//�������������������������������Ŀ
	//� Clausulas GROUP BY e ORDER BY �
	//���������������������������������
	cQuery += " GROUP BY SBF.BF_FILIAL, SBF.BF_PRODUTO, SBF.BF_LOCAL, SBF.BF_LOCALIZ, SBF.BF_NUMSERI, SBF.BF_ESTFIS, SBF.BF_LOTECTL "
	cQuery += " ORDER BY SBF.BF_FILIAL, SBF.BF_PRODUTO, SBF.BF_LOCAL, SBF.BF_LOCALIZ, SBF.BF_NUMSERI, SBF.BF_ESTFIS, SBF.BF_LOTECTL "
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T., 'TOPCONN', TcGenQry(,, cQuery), cAliasTRB)
	For nX := 1 To Len(aStruSBF)
		If !aStruSBF[nX, 2]$'CM' .And. !(FieldPos(aStruSBF[nX, 1])==0)
			TcSetField(cAliasTRB, aStruSBF[nX, 1], aStruSBF[nX, 2], aStruSBF[nX, 3], aStruSBF[nX, 4])
		EndIf
	Next nX
	dbSelectArea(cAliasTRB)
	dbGoTop()
	
	Do While !(cAliasTRB)->(Eof())
		
		nContador ++
		
		//������������������������������������������������������������������������Ŀ
		//� Guarda em array o conteudo de todos os campos deste Produto+Local+Lote �
		//��������������������������������������������������������������������������
		aCampos := Array(13)
		
		//����������������������������Ŀ
		//� Campos com conteudos fixos �
		//������������������������������
		aCampos[01] := (cAliasTRB)->BF_PRODUTO
		aCampos[02] := (cAliasTRB)->BF_LOCAL
		aCampos[03] := (cAliasTRB)->BF_LOCALIZ
		aCampos[04] := (cAliasTRB)->BF_NUMSERI
		aCampos[05] := (cAliasTRB)->BF_ESTFIS
		aCampos[06] := (cAliasTRB)->BF_LOTECTL
		
		//������������������������������������������Ŀ
		//� Campos com conteudos a serem aglutinados �
		//��������������������������������������������
		aCampos[07] := (cAliasTRB)->BF_QUANT
		aCampos[08] := (cAliasTRB)->BF_EMPENHO
		aCampos[09] := (cAliasTRB)->BF_QEMPPRE
		aCampos[10] := (cAliasTRB)->BF_QTSEGUM
		aCampos[11] := (cAliasTRB)->BF_EMPEN2
		aCampos[12] := (cAliasTRB)->BF_QEPRE2
		aCampos[13] := (cAliasTRB)->BF_DATAVEN
		
		//��������������������������������������������������Ŀ
		//� Deleta os registros com deste Produto+Local+Lote �
		//����������������������������������������������������
		cQuery  := "DELETE FROM "+RetSqlName('SBF')+" "
		cQuery  += "WHERE BF_FILIAL = '"+xFilial('SBF')+"'"
		cQuery  += " AND BF_PRODUTO = '"+aCampos[01]+"'"
		cQuery  += " AND BF_LOCAL = '" +aCampos[02]+"'"
		cQuery  += " AND BF_LOCALIZ = '" +aCampos[03]+"'"
		cQuery  += " AND BF_NUMSERI = '" +aCampos[04]+"'"
		cQuery  += " AND BF_ESTFIS = '" +aCampos[05]+"'"
		cQuery  += " AND BF_LOTECTL = '"+aCampos[06]+"'"
		cQuery  += " AND D_E_L_E_T_ = ' '"
		TCSqlExec(cQuery)
		SBF->(dbGoto(Recno()))
			
			//�������������������������������������������������������������������������������Ŀ
			//� Inclui registro unico deste Produto+Local+Lote com as quantidades aglutinadas �
			//���������������������������������������������������������������������������������
			RecLock('SBF', .T.)
			Replace BF_FILIAL  With xFilial('SBF'), ; //-- Filial do Sistema
					BF_PRODUTO With aCampos[01], ; //-- Codigo do Produto
					BF_LOCAL   With aCampos[02], ; //-- Armazem
					BF_LOCALIZ With aCampos[03], ; //-- Endereco
					BF_NUMSERI With aCampos[04], ; //-- Numero de serie
					BF_ESTFIS  With aCampos[05], ; //-- Estrutura fisica (WMS)
					BF_LOTECTL With aCampos[06], ; //-- Lote
					BF_QUANT   With aCampos[07], ; //-- Quantidade
					BF_EMPENHO With aCampos[08], ; //-- Empenho
					BF_QEMPPRE With aCampos[09], ; //-- Empenho previsto
					BF_QTSEGUM With aCampos[10], ; //-- Qtd. 2a UM
					BF_EMPEN2  With aCampos[11], ; //-- Empenho 2a UM
					BF_QEPRE2  With aCampos[12], ; //-- Empenho previsto 2a UM
					BF_DATAVEN With aCampos[13]    //-- Data de vencimento
			If lUpdEst08
				ExecBlock('PEUPDE08', .F., .F., {'SBF'})
			EndIf
			MsUnlock()
		(cAliasTRB)->(dbSkip())
	EndDo
	
	If Select(cAliasTRB) > 0
		dbSelectArea(cAliasTRB)
		dbCloseArea()
	EndIf
	//����������������������������������������������������������Ŀ
	//� A tabela eh fechada para restaurar o buffer da aplicacao �
	//������������������������������������������������������������
	dbSelectArea('SBF')
	dbCloseArea()
	ChkFile('SBF', .T.)
EndIf

PutGlbValue(cJobAux,"3")
GlbUnLock()
RpcClearEnv()
FClose(nHd1)

Return Nil

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �WzThrSBK � Autor �Emerson R. Oliveira    � Data �13/01/10  ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Funcao de processamento do ajuste da tabela SBK            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � UPDEST08                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function WzThrSBK(aFilSBK, IsInUpdate, cEmp, cFil, cJobFile, cJobAux, cProdIni, cProdFim)

Local aCampos    := {}
Local aStruSBK   := {}
Local cQuery     := ''
Local cAliasTRB  := ''
Local lUpdEst08 := ExistBlock('PEUPDE08')
Local nX         := 0
Local nContador  := 0
Local nRecsSBK   := 0
Local nHd1

Private __cInterNet

// Apaga arquivo ja existente
If File(cJobFile)
	fErase(cJobFile)
EndIf

// Criacao do arquivo de controle de jobs
nHd1 := MSFCreate(cJobFile)

// STATUS 1 - Iniciando execucao do Job
PutGlbValue(cJobAux,"1")
GlbUnLock()

// Seta job para nao consumir licencas
RpcSetType(3)

// Seta job para empresa filial desejada
RpcSetEnv(cEmp,cFil,,,"EST")

// STATUS 2 - Conexao efetuada com sucesso
PutGlbValue(cJobAux,"2")
GlbUnLock()

//��������������������Ŀ
//� Inicializando JOB  �
//����������������������
cMens := OemToAnsi(STR0143)+"("+cJobAux+")"
ProcLogAtu("MENSAGEM",cMens,cMens,"UPDEST08")

dbSelectArea("SBK")
aStruSBK := SBK->(dbStruct())
nRecsSBK := Max(1, SBK->(LastRec()))

If aScan(aFilSBK, SBK->(xFilial('SBK'))) == 0
	aAdd(aFilSBK, SBK->(xFilial('SBK')))
	dbSelectArea('SBK')
	dbSetOrder(1) //-- BK_FILIAL+BK_COD+BK_LOCAL+BK_LOTECTL+BK_NUMLOTE+BK_LOCALIZ+BK_NUMSERI+DTOS(BK_DATA)
	cAliasTRB := GetNextAlias() //'TRBSBK'
	
	//����������������Ŀ
	//� Campos da VIEW �
	//������������������
	cQuery := "SELECT "
	cQuery += " SBK.BK_COD, "
	cQuery += " SBK.BK_LOCAL, "
	cQuery += " SBK.BK_LOCALIZ, "
	cQuery += " SBK.BK_NUMSERI, "
	cQuery += " SBK.BK_LOTECTL, "
	cQuery += " SBK.BK_DATA, "
	cQuery += " SUM(SBK.BK_QINI) BK_QINI, "
	cQuery += " SUM(SBK.BK_QISEGUM) BK_QISEGUM, "
	cQuery += " MIN(SBK.BK_PRIOR) BK_PRIOR "
	cQuery += "FROM "+RetSqlName('SBK')+" SBK "
	
	//��������������������������������Ŀ
	//� Condicoes JOIN entre SBK e SB1 �
	//����������������������������������
	cQuery += " JOIN "+RetSqlName('SB1')+" SB1 "
	cQuery += " ON SB1.B1_FILIAL = '"+xFilial('SB1')+"' "
	cQuery += " AND SB1.B1_COD = SBK.BK_COD "
	cQuery += " AND SB1.B1_RASTRO = 'L' "
	cQuery += " AND SB1.D_E_L_E_T_  = ' ' "
	
	//���������������Ŀ
	//� Condicoes SBK �
	//�����������������
	cQuery += "WHERE SBK.BK_FILIAL = '"+xFilial('SBK')+"' "
	cQuery += " AND SBK.BK_COD BETWEEN '"+cProdIni+"' AND '"+cProdFim+"' "
	cQuery += " AND SBK.D_E_L_E_T_  = ' ' "
	cQuery += " AND SBK.BK_LOTECTL <> ' ' "
	cQuery += " AND SBK.BK_NUMLOTE <> ' ' "
	
	//�������������������������������Ŀ
	//� Clausulas GROUP BY e ORDER BY �
	//���������������������������������
	cQuery += " GROUP BY SBK.BK_FILIAL, SBK.BK_COD, SBK.BK_LOCAL, SBK.BK_LOCALIZ, SBK.BK_NUMSERI, SBK.BK_LOTECTL, SBK.BK_DATA "
	cQuery += " ORDER BY SBK.BK_FILIAL, SBK.BK_COD, SBK.BK_LOCAL, SBK.BK_LOCALIZ, SBK.BK_NUMSERI, SBK.BK_LOTECTL, SBK.BK_DATA "
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T., 'TOPCONN', TcGenQry(,, cQuery), cAliasTRB)
	For nX := 1 To Len(aStruSBK)
		If !aStruSBK[nX, 2]$'CM' .And. !(FieldPos(aStruSBK[nX, 1])==0)
			TcSetField(cAliasTRB, aStruSBK[nX, 1], aStruSBK[nX, 2], aStruSBK[nX, 3], aStruSBK[nX, 4])
		EndIf
	Next nX
	dbSelectArea(cAliasTRB)
	dbGoTop()
	
	Do While !(cAliasTRB)->(Eof())
		
		nContador ++
		
		//������������������������������������������������������������������������Ŀ
		//� Guarda em array o conteudo de todos os campos deste Produto+Local+Lote �
		//��������������������������������������������������������������������������
		aCampos := Array(9)
		
		//����������������������������Ŀ
		//� Campos com conteudos fixos �
		//������������������������������
		aCampos[01] := (cAliasTRB)->BK_COD
		aCampos[02] := (cAliasTRB)->BK_LOCAL
		aCampos[03] := (cAliasTRB)->BK_LOCALIZ
		aCampos[04] := (cAliasTRB)->BK_NUMSERI
		aCampos[05] := (cAliasTRB)->BK_LOTECTL
		aCampos[06] := (cAliasTRB)->BK_DATA
		
		//������������������������������������������Ŀ
		//� Campos com conteudos a serem aglutinados �
		//��������������������������������������������
		aCampos[07] := (cAliasTRB)->BK_QINI
		aCampos[08] := (cAliasTRB)->BK_QISEGUM
		aCampos[09] := (cAliasTRB)->BK_PRIOR
		
		//��������������������������������������������������Ŀ
		//� Deleta os registros com deste Produto+Local+Lote �
		//����������������������������������������������������
		cQuery  := "DELETE FROM "+RetSqlName('SBK')+" "
		cQuery  += "WHERE BK_FILIAL = '"+xFilial('SBK')+"'"
		cQuery  += " AND BK_COD = '" +aCampos[01]+"'"
		cQuery  += " AND BK_LOCAL = '" +aCampos[02]+"'"
		cQuery  += " AND BK_LOCALIZ = '" +aCampos[03]+"'"
		cQuery  += " AND BK_NUMSERI = '" +aCampos[04]+"'"
		cQuery  += " AND BK_LOTECTL = '"+aCampos[05]+"'"
		cQuery  += " AND BK_DATA = '"+DTOS(aCampos[06])+"'"
		cQuery  += " AND D_E_L_E_T_ = ' '"
		TCSqlExec(cQuery)
		SBK->(dbGoto(Recno()))
			
			//�������������������������������������������������������������������������������Ŀ
			//� Inclui registro unico deste Produto+Local+Lote com as quantidades aglutinadas �
			//���������������������������������������������������������������������������������
			RecLock('SBK', .T.)
			Replace BK_FILIAL  With xFilial('SBK'), ; //-- Filial do Sistema
					BK_COD     With aCampos[01], ; //-- Codigo do Produto
					BK_LOCAL   With aCampos[02], ; //-- Armazem
					BK_LOCALIZ With aCampos[03], ; //-- Endereco
					BK_NUMSERI With aCampos[04], ; //-- Numero de serie
					BK_LOTECTL With aCampos[05], ; //-- Lote
					BK_DATA    With aCampos[06], ; //-- Data da Criacao do lote
					BK_QINI    With aCampos[07], ; //-- Quantidade inicial do lote
					BK_QISEGUM With aCampos[08], ; //-- Quantidade inicial 2UM
					BK_PRIOR   With aCampos[09]    //-- Prioridade do endereco
			If lUpdEst08
				ExecBlock('PEUPDE08', .F., .F., {'SBK'})
			EndIf
			MsUnlock()
		(cAliasTRB)->(dbSkip())
	EndDo
	
	If Select(cAliasTRB) > 0
		dbSelectArea(cAliasTRB)
		dbCloseArea()
	EndIf
	//����������������������������������������������������������Ŀ
	//� A tabela eh fechada para restaurar o buffer da aplicacao �
	//������������������������������������������������������������
	dbSelectArea('SBK')
	dbCloseArea()
	ChkFile('SBK', .T.)
EndIf

PutGlbValue(cJobAux,"3")
GlbUnLock()
RpcClearEnv()
FClose(nHd1)

Return Nil

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �WhThrSDA � Autor �Emerson R. Oliveira    � Data �13/01/10  ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Funcao de processamento do ajuste da tabela SDA            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � WizLtUni                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function WhThrSDA(aFilSDA, IsInUpdate, cEmp, cFil, cJobFile, cJobAux, cProdIni, cProdFim)

Local cQuery     := ''
Local cAliasTRB  := ''
Local cTamSLote  := ''
Local lUpdEst08  := ExistBlock('PEUPDE08')
Local nContador  := 0
Local nHd1

Private __cInterNet

// Apaga arquivo ja existente
If File(cJobFile)
	fErase(cJobFile)
EndIf

// Criacao do arquivo de controle de jobs
nHd1 := MSFCreate(cJobFile)

// STATUS 1 - Iniciando execucao do Job
PutGlbValue(cJobAux,"1")
GlbUnLock()

// Seta job para nao consumir licencas
RpcSetType(3)

// Seta job para empresa filial desejada
RpcSetEnv(cEmp,cFil,,,"EST")

// STATUS 2 - Conexao efetuada com sucesso
PutGlbValue(cJobAux,"2")
GlbUnLock()

//��������������������Ŀ
//� Inicializando JOB  �
//����������������������
cMens := OemToAnsi(STR0143)+"("+cJobAux+")"
ProcLogAtu("MENSAGEM",cMens,cMens,"WizLtUni")

cTamSLote := Space(TamSX3("B8_NUMLOTE")[1])

If aScan(aFilSDA, SDA->(xFilial('SDA'))) == 0
	aAdd(aFilSDA, SDA->(xFilial('SDA')))
	dbSelectArea('SDA')
	dbSetOrder(1) //-- DA_FILIAL+DA_PRODUTO+DA_LOCAL+DA_NUMSEQ+DA_DOC+DA_SERIE+DA_CLIFOR+DA_LOJA
	cAliasTRB := GetNextAlias() //'TRBSBK'
	
	//����������������Ŀ
	//� Campos da VIEW �
	//������������������
	cQuery := "SELECT SDA.R_E_C_N_O_  DA_RECNO "
	cQuery += "FROM "+RetSqlName('SDA')+" SDA "
	
	//��������������������������������Ŀ
	//� Condicoes JOIN entre SDA e SB1 �
	//����������������������������������
	cQuery += " JOIN "+RetSqlName('SB1')+" SB1 "
	cQuery += " ON SB1.B1_FILIAL = '"+xFilial('SB1')+"' "
	cQuery += " AND SB1.B1_COD = SDA.DA_PRODUTO "
	cQuery += " AND SB1.B1_RASTRO = 'L' "
	cQuery += " AND SB1.D_E_L_E_T_  = ' ' "
	
	//���������������Ŀ
	//� Condicoes SDA �
	//�����������������
	cQuery += "WHERE SDA.DA_FILIAL = '"+xFilial('SDA')+"' "
	cQuery += " AND SDA.DA_PRODUTO BETWEEN '"+cProdIni+"' AND '"+cProdFim+"' "
	cQuery += " AND SDA.D_E_L_E_T_  = ' ' "
	cQuery += " AND SDA.DA_LOTECTL <> ' ' "
	cQuery += " AND SDA.DA_NUMLOTE <> ' ' "
	
	//�������������������������������Ŀ
	//� Clausulas GROUP BY e ORDER BY �
	//���������������������������������
	cQuery += " ORDER BY SDA.R_E_C_N_O_ "

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T., 'TOPCONN', TcGenQry(,, cQuery), cAliasTRB)
	dbSelectArea(cAliasTRB)
	dbGoTop()
	
	Do While !(cAliasTRB)->(Eof())

		nContador ++

		//������������������������������������������������Ŀ
		//� Atualiza os registros deste Produto+Local+Lote �
		//��������������������������������������������������
		cQuery := "UPDATE "+RetSqlName('SDA')+" "
		cQuery += " SET DA_NUMLOTE = '"+cTamSLote+"' "
		cQuery += " WHERE R_E_C_N_O_ = "+Str((cAliasTRB)->DA_RECNO)+""
		TCSqlExec(cQuery)
		SDA->(dbGoto(Recno()))

		If lUpdEst08
			ExecBlock('PEUPDE08', .F., .F., {'SDA'})
		EndIf

		MsUnlock()

		(cAliasTRB)->(dbSkip())
	EndDo
	
	If Select(cAliasTRB) > 0
		dbSelectArea(cAliasTRB)
		dbCloseArea()
	EndIf
	//����������������������������������������������������������Ŀ
	//� A tabela eh fechada para restaurar o buffer da aplicacao �
	//������������������������������������������������������������
	dbSelectArea('SDA')
	dbCloseArea()
	ChkFile('SDA', .T.)
EndIf

PutGlbValue(cJobAux,"3")
GlbUnLock()
RpcClearEnv()
FClose(nHd1)

Return Nil

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �WhThrSDB � Autor �Emerson R. Oliveira    � Data �13/01/10  ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Funcao de processamento do ajuste da tabela SDB            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � WizLtUni                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function WhThrSDB(aFilSDB, IsInUpdate, cEmp, cFil, cJobFile, cJobAux, cProdIni, cProdFim)

Local cQuery     := ''
Local cAliasTRB  := ''
Local cTamSLote  := ''
Local lUpdEst08  := ExistBlock('PEUPDE08')
Local nContador  := 0
Local nHd1

Private __cInterNet

// Apaga arquivo ja existente
If File(cJobFile)
	fErase(cJobFile)
EndIf

// Criacao do arquivo de controle de jobs
nHd1 := MSFCreate(cJobFile)

// STATUS 1 - Iniciando execucao do Job
PutGlbValue(cJobAux,"1")
GlbUnLock()

// Seta job para nao consumir licencas
RpcSetType(3)

// Seta job para empresa filial desejada
RpcSetEnv(cEmp,cFil,,,"EST")

// STATUS 2 - Conexao efetuada com sucesso
PutGlbValue(cJobAux,"2")
GlbUnLock()

//��������������������Ŀ
//� Inicializando JOB  �
//����������������������
cMens := OemToAnsi(STR0143)+"("+cJobAux+")"
ProcLogAtu("MENSAGEM",cMens,cMens,STR0147)

cTamSLote := Space(TamSX3("B8_NUMLOTE")[1])

If aScan(aFilSDB, SDB->(xFilial('SDB'))) == 0
	aAdd(aFilSDB, SDB->(xFilial('SDB')))
	dbSelectArea('SDB')
	dbSetOrder(2) //-- DB_FILIAL+DB_PRODUTO+DB_LOCAL+DB_LOTECTL+DB_NUMLOTE+DB_NUMSERI+DB_LOCALIZ+DB_NUMSEQ
	cAliasTRB := GetNextAlias() //'TRBSDB'
	
	//����������������Ŀ
	//� Campos da VIEW �
	//������������������
	cQuery := "SELECT SDB.R_E_C_N_O_  DB_RECNO "
	cQuery += "FROM "+RetSqlName('SDB')+" SDB "
	
	//��������������������������������Ŀ
	//� Condicoes JOIN entre SDB e SB1 �
	//����������������������������������
	cQuery += " JOIN "+RetSqlName('SB1')+" SB1 "
	cQuery += " ON SB1.B1_FILIAL = '"+xFilial('SB1')+"' "
	cQuery += " AND SB1.B1_COD = SDB.DB_PRODUTO"
	cQuery += " AND SB1.B1_RASTRO = 'L'"
	cQuery += " AND SB1.D_E_L_E_T_  = ' ' "
	
	//���������������Ŀ
	//� Condicoes SDB �
	//�����������������
	cQuery += "WHERE SDB.DB_FILIAL = '"+xFilial('SDB')+"' "
	cQuery += " AND SDB.DB_PRODUTO BETWEEN '"+cProdIni+"' AND '"+cProdFim+"' "
	cQuery += " AND SDB.D_E_L_E_T_  = ' ' "
	cQuery += " AND SDB.DB_LOTECTL <> ' ' "
	cQuery += " AND SDB.DB_NUMLOTE <> ' ' "

	//�������������������������������Ŀ
	//� Clausulas GROUP BY e ORDER BY �
	//���������������������������������
	cQuery += " ORDER BY SDB.R_E_C_N_O_ "
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T., 'TOPCONN', TcGenQry(,, cQuery), cAliasTRB)
	dbSelectArea(cAliasTRB)
	dbGoTop()
	
	Do While !(cAliasTRB)->(Eof())
		
		nContador ++
		
		//������������������������������������������������Ŀ
		//� Atualiza os registros deste Produto+Local+Lote �
		//��������������������������������������������������
		cQuery := "UPDATE "+RetSqlName('SDB')+" "
		cQuery += " SET DB_NUMLOTE = '"+cTamSLote+"' "
		cQuery += " WHERE R_E_C_N_O_ = "+Str((cAliasTRB)->DB_RECNO)+""
		TCSqlExec(cQuery)
		SDB->(dbGoto(Recno()))
	
		If lUpdEst08
			ExecBlock('PEUPDE08', .F., .F., {'SDB'})
		EndIf
		MsUnlock()

		(cAliasTRB)->(dbSkip())
	EndDo
	
	If Select(cAliasTRB) > 0
		dbSelectArea(cAliasTRB)
		dbCloseArea()
	EndIf
	//����������������������������������������������������������Ŀ
	//� A tabela eh fechada para restaurar o buffer da aplicacao �
	//������������������������������������������������������������
	dbSelectArea('SDB')
	dbCloseArea()
	ChkFile('SDB', .T.)
EndIf

PutGlbValue(cJobAux,"3")
GlbUnLock()
RpcClearEnv()
FClose(nHd1)

Return Nil
