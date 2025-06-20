#INCLUDE "plsa405.ch"
#Include "Protheus.Ch"
#include "PLSMGER.CH"
                                  
/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    � PLSA405 � Autor � Geraldo Felix Junior   � Data � 14.02.07 ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Bloqueia horarios da agenda da marcacao de cons / recepcao.����
�������������������������������������������������������������������������Ĵ���
���Sintaxe   � PLSA405()                                                  ����
�������������������������������������������������������������������������Ĵ���
��� Uso      � Advanced Protheus                                          ����
�������������������������������������������������������������������������Ĵ���
��� Alteracoes desde sua construcao inicial.                              ����
�������������������������������������������������������������������������Ĵ���
��� Data     � BOPS � Programador � Breve Descricao                       ����
��������������������������������������������������������������������������ٱ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/

Function Plsa405

PRIVATE aRotina 	:= MenuDef()
Private cCadastro 	:= "Lancamentos Datas/Horarios De Cancelamento de Atendimento"
             
BBQ->(DbSetOrder(1))
BBQ->(DbSeek(xFilial("BBQ")))
BBQ->(mBrowse(06,01,22,75,"BBQ"))

Return .T.

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    � PLSA405Mov � Autor �Geraldo Felix Junior.� Data � 01.09.03 ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Chama funcao para efetuar alteracao/exclusao de Lancamentos����
��������������������������������������������������������������������������ٱ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Function PLSA405Mov(cAlias, nReg, nOpc)
LOCAL aButtons := {}

Aadd(aButtons, {"RELATORIO"    	, {||PLS405TOk(.T.)},"Verifica agendas no periodo","Verifica"} )

If nOpc = K_Incluir 
   	AxInclui(cAlias,nReg,nOpc,,,,"PLS405TOk(.F.)",,,aButtons)

ElseIf nOpc = K_Alterar
	AxAltera(cAlias,nReg,nOpc,,,,,"PLS405TOk(.F.)",,,aButtons)

ElseIf nOpc = K_Visualizar                               
	AxVisual(cAlias, nReg, nOpc,,,,,aButtons)

ElseIf nOpc = K_Excluir
	RegToMemory(cAlias)
	AxDeleta(cAlias,nReg,nOpc)
Endif

Return .T.



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PLSA405   �Autor  �Microsiga           � Data �  01/10/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function PLS405TOk(lDireto)
LOCAL lRet 		:= .T.
LOCAL aCabec	:= { {"Matricula","@!",80},{"Data da agenda","@!",50},{"Hora da agenda","@D",050},{"Local","@C",020},{"Especialidade","@C",020}}
LOCAL aDados	:= {}
Local cSql 		:= ''        
LOCAL nReg		:= BBQ->( Recno() )

cSql := "SELECT * FROM "+RetSqlName("BBD")+" WHERE BBD_CODINT = '"+M->BBQ_CODINT+"' "
	cSql += "AND BBD_CODIGO = '"+M->BBQ_CODRDA+"' "
	cSql += "AND BBD_LOCAL = '"+M->BBQ_CODLOC+"' "
	cSql += "AND BBD_CODESP = '"+M->BBQ_CODESP+"' "
	cSql += "AND BBD_DATA >= '"+dTos(M->BBQ_DATDE) +"' "
	cSql += "AND BBD_DATA <= '"+dTos(M->BBQ_DATATE)+"' "
	cSql += "AND BBD_HORA >= '"+M->BBQ_HORDE +"' "
	cSql += "AND BBD_HORA <= '"+M->BBQ_HORATE+"' "
	cSql += "AND BBD_DATCAN = ' ' "
	cSql += "AND D_E_L_E_T_ = ' ' "
PlsQuery(cSql, "TRB")

If !TRB->( Eof() ) .and. !lDireto
	If !MsgYesNo("Existem pacientes agendados no per�odo que esta sendo bloqueado. Caso tenha certeza de que deseja continuar, "+;
			 " confirme esta mensagem para visualizar a lista de pacientes para serem remarcados ou cancelados manualmente. Deseja continuar ?")
		lRet := .F.
	Endif
Elseif TRB->( Eof() ) .and. lDireto
	MsgAlert("Nao existe pacientes agendados no perido do bloqueio!")
	
Endif
     
// Relaciona os pacientes agendado no periodo do bloqueio
If lRet .and. !TRB->( Eof() )
	While !TRB->( Eof() )
		aadd(aDados,{TRB->BBD_CODPAC,TRB->BBD_DATA, TRB->BBD_HORA, TRB->BBD_LOCAL, TRB->BBD_CODESP})
		
		TRB->( dbSkip() )
	Enddo
	
	If Len(aDados) > 0
		PLSCRIGEN(aDados,aCabec,"Lista de pacientes agendados.")		
	Endif
Endif	
	        
TRB->( dbClosearea() )	 

dbSelectArea("BBQ")
BBQ->( dbGoto(nReg) )

Return(lRet)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Darcio R. Sporl       � Data �03/04/2007���
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
���          �	  1 - Pesquisa e Posiciona em um Banco de Dados           ���
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
Private aRotina := {	{ STRPL01		, 'AxPesqui'	, 0 , K_Pesquisar	, 0 , .F.},;
						{ STRPL02	, 'PLSA405Mov'	, 0 , K_Visualizar 	, 0 , Nil},;
						{ STRPL03  	, 'PLSA405Mov'	, 0 , K_Incluir    	, 0 , Nil},;
						{ STRPL04	    , 'PLSA405Mov'	, 0 , K_Alterar    	, 0 , Nil},;
						{ STRPL05 	, 'PLSA405Mov'	, 0 , K_Excluir    	, 0 , Nil} } 
Return(aRotina)
