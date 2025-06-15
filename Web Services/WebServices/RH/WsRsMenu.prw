#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "WSRSMENU.CH"

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PortalCand�Autor  �                     � Data �    /  /     ���
��������������������������������������������������������������������������͹��
���Desc.     � WebServices responsavel pelo menu do portal do candidato.   ���
��������������������������������������������������������������������������͹��
���Parametros�                                                             ���
��������������������������������������������������������������������������͹��
���Uso       � Portal do Candidato                                         ���
��������������������������������������������������������������������������͹��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                      	   ���
��������������������������������������������������������������������������͹��
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
WSSERVICE RhMenu DESCRIPTION STR0001 //"Servi�o de controle e atualiza��o dos usu�rios de portais <b>(Menu)</b>"

	WSDATA HeaderType 		As String
	WSDATA Header 			As Array Of BrwHeader
	WSDATA PortalCode 		AS String
	WSDATA ListMenu 		AS Array Of LoginMenu
	
	WSMETHOD PrtHeader 		DESCRIPTION STR0002 //"M�todo que descreve as estruturas de retorno do servi�o "
	WSMETHOD PrtListMenu 	DESCRIPTION STR0003 //"M�todo de listagem do menu dos portais. <br><br><i> Este m�todo demonstra o menu do usu�rio conforme os direitos de acesso aos web services publicados no sistema</i>"

ENDWSSERVICE

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PrtHeader �Autor  �                     � Data �    /  /     ���
��������������������������������������������������������������������������͹��
���Desc.     � Metodo que retorna o header do menu do portal do candidato. ���
��������������������������������������������������������������������������͹��
���Parametros�                                                             ���
��������������������������������������������������������������������������͹��
���Uso       � Portal do Candidato                                         ���
��������������������������������������������������������������������������͹��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                      	   ���
��������������������������������������������������������������������������͹��
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
WSMETHOD PrtHeader WSRECEIVE HeaderType WSSEND Header WSSERVICE RhMenu

Local lRetorno := .T.

::HeaderType := Upper( ::HeaderType )

If ::HeaderType == "LOGINMENU"
	WsPutHead( ::Header, "AI8_CODMNU", "CODE" )
	WsPutHead( ::Header, "AI8_TEXTO", "DESCRIPTION" )
	WsPutHead( ::Header, "AI8_CODPAI", "SUPERIORCODE" )
	WsPutHead( ::Header, "AI8_WEBSRV", "WEBSERVICE" )
	WsPutHead( ::Header, "AI8_ROTINA", "PROCEDURECALL" )
Endif

Return lRetorno

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PrtListMen�Autor  �                     � Data �    /  /     ���
��������������������������������������������������������������������������͹��
���Desc.     � Metodo que retorna o menu do portal do candidatoandidato.   ���
��������������������������������������������������������������������������͹��
���Parametros�                                                             ���
��������������������������������������������������������������������������͹��
���Uso       � Portal do Candidato                                         ���
��������������������������������������������������������������������������͹��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                      	   ���
��������������������������������������������������������������������������͹��
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
WSMETHOD PrtListMenu WSRECEIVE PortalCode WSSEND ListMenu WSSERVICE RhMenu

Local cAlias 	:= "AI8"
Local nX 		:= 0
Local aArea 	:= GetArea()
Local lQuery 	:= .F.
Local lRetorno 	:= .T.
Local cQuery   := ""

If RA0-> ( FieldPos("RA0_UTIL") ) == 0 
	SetSoapFault( "PRTLISTMENU", STR0004 ) //" *** Necessario executar o Atualizador do SIGARSP (U_UPDRSP) atraves do Remote *** "
	Return .F.
endif

::PortalCode := PadR( ::PortalCode, Len( AI8->AI8_PORTAL ) )

lQuery := .T.
cAlias := "PRTLISTMENU"

cQuery := "SELECT * "
cQuery += "FROM " + RetSqlName( "AI8" ) + " AI8 "
cQuery += "WHERE AI8.AI8_FILIAL = '" + xFilial( "AI8" ) + "' AND "
cQuery += "AI8.AI8_PORTAL = '" + ::PortalCode+"' AND "
cQuery += "AI8.D_E_L_E_T_=' ' "

cQuery := ChangeQuery( cQuery )

DbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAlias )

While 	!( cAlias )->( EOF() ) .AND. ( cAlias )->AI8_FILIAL == xFilial( "AI8" ) .AND.;
		( cAlias )->AI8_PORTAL == ::PortalCode

	nX++
	
	AAdd( ::ListMenu, WsClassNew( "LoginMenu" ) )
	
	::ListMenu[nX]:Code 			:= ( cAlias )->AI8_CODMNU
	::ListMenu[nX]:Description 		:= MenuDesc(cAlias)  //Traz a op��o no Idioma
	::ListMenu[nX]:SuperiorCode 	:= ( cAlias )->AI8_CODPAI
	::ListMenu[nX]:WebService 		:= ( cAlias )->AI8_WEBSRV
	::ListMenu[nX]:ProcedureCall 	:= ( cAlias )->AI8_ROTINA
		
	If AI8->(FieldPos("AI8_ORDEM"))<>0
		::ListMenu[nX]:Order:= (cAlias)->AI8_ORDEM
	else
		::ListMenu[nX]:Order:= 0
	endif

	::ListMenu[nX]:MenuIsBlocked 	:= (cAlias)->AI8_MSBLQL == "1" // 1-Bloqueado 2-N�o Bloqueado

	( cAlias )->( DbSkip() )
EndDo

If lQuery
	DbSelectArea( cAlias )
	DbCloseArea()
	DbSelectArea( "AI8" )
EndIf

If nX == 0
	lRetorno := .F.
	SetSoapFault( "PRTLISTMENU", STR0005 ) //"Menu n�o encontrado"
EndIf

RestArea( aArea )

Return lRetorno

Function WsRsMenu()
Return Nil
