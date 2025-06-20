#INCLUDE "TMKA510G.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TCBROWSE.CH"
#INCLUDE "TBICONN.CH"

Static oObj := HelpDeskQuery():New()

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Classe    �TeleServiceUserDialog �Autor� Vendas Clientes � Data �  12/11/07   ���
��������������������������������������������������������������������������������͹��
���Desc.     |Classe que contempla as funcionalidades da tela do atendimento do  ��� 
���          �usuario.                                                           ���
��������������������������������������������������������������������������������͹��
���Uso       � MP10                                                              ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������     
*/
Class HelpDeskQuery From TeleServiceUserDialog
        
Method New() Constructor  
Method openBrowse(xAutoCab,xAutoItens,nOpcAuto, xRegCode, aRotOpc)
EndClass    

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �openBrowse   �Autor  � Vendas Clientes � Data �  09/11/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Exibe a tela de escolha do modelo de atendimento.           ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method openBrowse(xAutoCab,xAutoItens,nOpcAuto, xRegCode, aRotOpc, cFiltra) Class HelpDeskQuery
Local cAliasUser	:= "" 		// Alias da tabela Master (a partir do configurador)
Local cAt503Fil		:= ""		// Filtro fornecido pelo ponto de entrada
Local bFiltraBrw	:= {||}		// Bloco de c�digo para execu��o do filtro
Local aIndex		:= {}		// Indice da tabela
Local cTeleServID	:= ""		// Armazena o codigo do TeleAtendimento associado ao Grupo do Operador.
             
Default cFiltra		:= ""			// Filtro utilizado no bloco de c�digo executado para ativar o filtro
Default aRotOpc		:= MenuDef()	// Carrega o aRotinas padr�o para tela de TeleAtendimento

Private aRotina		:= aRotOpc		// Variavel utilizada no mBrowse da tela
Private aCores 		:= {} 

//���������������������������������Ŀ
//� Carrega o modelo de atendimento �
//�����������������������������������
cTeleServID := Self:GetModel()
If !Empty(cTeleServID)
	If Self:service:load(cTeleServID)
		cAliasUser := Self:service:tableStructureInfo:master:alias
		 
		DbSelectArea(cAliasUser)  
		DbSetOrder(1)
		
		//��������������������������������������������������������������Ŀ
		//� Verifica a existencia de Filtros na MBrowse                  �
		//����������������������������������������������������������������
		If Empty(cFiltra) .AND. (ExistBlock("TK510GFIL"))
			cAt503Fil := ExecBlock("TK510GFIL",.F.,.F.)
			If ( ValType(cAt503Fil) == "C" ) .And. !Empty(cAt503Fil)
				cFiltra := cAt503Fil
			EndIf
		EndIf
		
		If !Empty(cFiltra)
			bFiltraBrw 	:= {|| FilBrowse(cAliasUser,@aIndex,@cFiltra) }
			Eval(bFiltraBrw)
		EndIf
		
		//��������������������������������������������������������������Ŀ
		//� Endereca a funcao de BROWSE                                  �
		//����������������������������������������������������������������
		If nOpcAuto == Nil 
			DbSetOrder(1)
			DbSeek(xFilial(cAliasUser))
			//MBrowse(,,,,cAliasUser,,,,,,aCores,,,,)
			MsgRun(STR0001, STR0002, {|| MBrowse(,,,,cAliasUser,,,,,,aCores,,,,)})   //"Aguarde...Carregando informa��es" # "Teleatendimento"
		Else
			Private lTk503Auto		:= .T.
			Private aAutoCab		:= xAutoCab
			Private aAutoItens		:= xAutoItens
			Private xRegisterCode 
			MBrowseAuto(nOpcAuto,Aclone(aAutoCab),cAliasUser)
			xRegCode := xRegisterCode	
		EndIf		
		
		//������������������������������������������������������������������������Ŀ
		//� Finaliza o uso da funcao FilBrowse e retorna os indices padroes.       �
		//��������������������������������������������������������������������������
		If !Empty( cFiltra ) .AND. Len( aIndex ) > 0
			EndFilBrw( cAliasUser, aIndex )
		EndIf
	Else
		Help( " ",1,"TSOPERAD",,STR0003 + CRLF + STR0004 + CRLF + STR0005 + CRLF  + CRLF + STR0006  + CRLF + STR0007,1,1) // "- Operador relacionado a um " # "Grupo de Atendimento que n�o atende o " # "TeleAtendimento. " # "- Verificar as configura��es do" # "Grupo de Atendimento"
	EndIf
EndIf
Return Nil 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �New          �Autor  � Vendas Clientes � Data �  12/11/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo construtor da classe.                                ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method New() Class HelpDeskQuery	
Self:lReadOnly := .F.
Self:service := TeleServicing():New() 
Self:cEntValue	:= "" 
Self:cEntName	:= ""
Self:cContValue	:= "" 
Self:cCodLig 	:= "" 
Self:nOpc		:= 0
Self:aParScript:= {}
Return Self

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � TMKA503A � Autor � IP - Vendas Clientes  � Data � 26/10/07 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Modelo de Teleatendimento (TeleServiceUserDialog)          ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MP10                                                       ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function TMKA510G(xAutoCab,xAutoItens,nOpcAuto,cDefFilter, aRotina ) 

Default aRotina := MenuDef()

oObj:openBrowse(xAutoCab,xAutoItens,nOpcAuto, Nil, aRotina,cDefFilter)

Return .T.   

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    |MenuDef	� Autor � Vendas Cliente        � Data �18/12/07  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao de defini��o do aRotina                             ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � aRotina   retorna a array com lista de aRotina             ���
�������������������������������������������������������������������������Ĵ��
���Uso       � SIGALOJA                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef() 
Local aRotina
               
aRotina		:= {	{ STR0008		,"AxPesqui"  ,0,1 },; 	// 	"Pesquisar" //"Pesquisar"
				 	{ STR0009 		,"TK503AOpc" ,0,2 }}//,; 	// 	"Visualizar" //"Visualizar"
Return(aRotina)