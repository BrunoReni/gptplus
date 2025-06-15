#INCLUDE "PROTHEUS.CH"   
#INCLUDE "LOJA0049.CH"

// O protheus necessita ter ao menos uma fun��o p�blica para que o fonte seja exibido na inspe��o de fontes do RPO.
Function LOJA0049() ; Return

/*                               
Static Function TstLJMM()
	Local oLJCMessageManager := GetLJCMessageManager()
	Public __cInternet	
	
	__cInternet := "AUTOMATICO"
	
	If oLJCMessageManager:HasMessage()
		ConOut("Falhou")
	Else
		ConOut("Passou")
	EndIf
	
	oLJCMessageManager:ThrowMessage( LJCMessage():New( "ErroA", 1, "Ocorreu o erro no TCP" ) )	
	If oLJCMessageManager:HasMessage()
		ConOut("Passou")
	Else
		ConOut("Falhou")
	EndIf	
	
	oLJCMessageManager:ThrowMessage( LJCMessage():New( "ErroB", 1, "N�o foi possivel efetuar o download." ) )	
	If oLJCMessageManager:HasMessage( "ErroB" )
		ConOut("Passou")
	Else
		ConOut("Falhou")
	EndIf		
	
	oLJCMessageManager:ThrowMessage( LJCMessage():New( "ErroC", 2, "N�o foi possivel efetuar carga" ) )	
	If oLJCMessageManager:HasWarning()
		ConOut("Passou")
	Else
		ConOut("Falhou")
	EndIf			
	
	If oLJCMessageManager:HasWarning( "ErroC" )
		ConOut("Passou")
	Else
		ConOut("Falhou")
	EndIf	
	
	If oLJCMessageManager:HasInformation( "ErroC" )
		ConOut("Falhou")
	Else
		ConOut("Passou")		
	EndIf		
	
	oLJCMessageManager:Show( "H� uma mensagem" )
	                              
	ConOut( oLJCMessageManager:Serialize() )	
	
	oLJCMessageManager:Clear()
	If oLJCMessageManager:HasMessage()
		ConOut("Falhou")
	Else
		ConOut("Passou")
	EndIf  
Return    
*/

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     Fun��o: � GetLJCMessageManager              � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Pega o gerenciador de mensagens global.                                ���
���             �                                                                        ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � Nenhum.                                                                ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � Nil                                                                    ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Function GetLJCMessageManager()
	Public _oLJCMessageManager
	
	If _oLJCMessageManager == Nil
		_oLJCMessageManager := LJCMessageManager():New()
	EndIf                                     
Return _oLJCMessageManager 

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     Fun��o: � SetLJCMessageManager              � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Configura o gerenciador de mensagens global.                           ���
���             �                                                                        ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � Nenhum.                                                                ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � Ni                                                                     ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Function SetLJCMessageManager( oLJCMessageManager )
	Public _oLJCMessageManager
	_oLJCMessageManager := oLJCMessageManager
Return

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     Classe: � LJCMessageManager                 � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Gerenciador de troca de mensagens, utilizada para a troca de           ���
���             � mensagens entre fun��es.                                               ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Class LJCMessageManager From FWSerialize
	Data oMessage
	
	Method New()
	Method HasMessage()
	Method HasError()
	Method HasWarning()
	Method HasInformation()
	Method ThrowMessage()
	Method Clear()
	Method Show()
EndClass

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � New                               � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Construtor.                                                            ���
���             �                                                                        ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � Nenhum.                                                                ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � Nil                                                                    ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method New() Class LJCMessageManager
Return
                     
/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � HasMessage                        � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Se � uma mensagem e/ou se tem alguma mensagem interna com o nome       ���
���             � passado pelo par�metro.                                                ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � cMessageName: Nome da mensagem a ser identificada. (Opcional)          ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � lHasMessage: .T. se h� alguma mensagem ou a mensagem questionada.      ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method HasMessage( cMessageName ) Class LJCMessageManager
	Local lHasMessage	:= .F.

	If Self:oMessage != Nil
		If cMessageName == Nil
			lHasMessage := .T.
		Else
			lHasMessage := Self:oMessage:HasMessage( cMessageName )
		EndIf
	EndIf
Return lHasMessage

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � HasError                          � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Se � uma mensagem do tipo erro e/ou se tem alguma mensagem interna do  ���
���             � tipo erro com o nome passado pelo par�metro.                           ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � cMessageName: Nome da mensagem a ser identificada. (Opcional)          ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � lHasMessage: .T. se h� alguma mensagem ou a mensagem questionada.      ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method HasError( cMessageName ) Class LJCMessageManager
	Local lHasMessage	:= .F.

	If Self:oMessage != Nil
		If cMessageName == Nil
			lHasMessage := .T.
		Else
			lHasMessage := Self:oMessage:HasError( cMessageName )
		EndIf
	EndIf
Return lHasMessage  

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � HasWarning                        � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Se � uma mensagem do tipo aviso e/ou se tem alguma mensagem interna do ���
���             � tipo aviso com o nome passado pelo par�metro.                          ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � cMessageName: Nome da mensagem a ser identificada. (Opcional)          ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � lHasMessage: .T. se h� alguma mensagem ou a mensagem questionada.      ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method HasWarning( cMessageName ) Class LJCMessageManager
	Local lHasMessage	:= .F.

	If Self:oMessage != Nil
		If cMessageName == Nil
			lHasMessage := .T.
		Else
			lHasMessage := Self:oMessage:HasWarning( cMessageName )
		EndIf
	EndIf
Return lHasMessage

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � HasInformation                    � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Se � uma mensagem do tipo informa��o e/ou se tem alguma mensagem       ���
���             � interna do tipo informa��o com o nome passado pelo par�metro.          ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � cMessageName: Nome da mensagem a ser identificada. (Opcional)          ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � lHasMessage: .T. se h� alguma mensagem ou a mensagem questionada.      ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method HasInformation( cMessageName ) Class LJCMessageManager
	Local lHasMessage	:= .F.

	If Self:oMessage != Nil
		If cMessageName == Nil
			lHasMessage := .T.
		Else
			lHasMessage := Self:oMessage:HasInformation( cMessageName )
		EndIf
	EndIf
Return lHasMessage

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � ThrowMessage                      � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Grava uma mensagem no gerenciador de mensagens.                        ���
���             �                                                                        ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � oMessage: Objeto LJCMessage com a mensagem.                            ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � Nil                                                                    ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method ThrowMessage( oMessage ) Class LJCMessageManager
	oMessage:oInnerMessage := Self:oMessage
	Self:oMessage := oMessage
	If oMessage != Nil
		LjGrvLog("LJCMessageManager" , oMessage:ToString())
	EndIf
Return

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � Clear                             � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Limpa a cadeia de mensagens existente no gerenciador de mensagem.      ���
���             �                                                                        ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � Nenhum.                                                                ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � Nil                                                                    ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method Clear() Class LJCMessageManager
	Self:oMessage := Nil
Return

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � Show                              � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Exibe a mensagem e suas mensagens internas.                            ���
���             �                                                                        ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � cMessage: Texto de exibi��o principal.                                 ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � Nil                                                                    ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method Show( cMessage ) Class LJCMessageManager
	Local oDlgII				:= Nil
	Local oFntTit				:= Nil
	Local oFntMsg				:= Nil
	Local oBmp					:= Nil
	Local oMsgDet				:= Nil
	Local lTelaDetalhe			:= .F.
	Local lExibeBotaoDetalhe	:= .F.
	
	If IsBlind()
		ConOut( STR0001 + ": " + cMessage ) // "Mensagem"
		If Self:oMessage != Nil
			ConOut( STR0002 + ": " + Self:oMessage:ToString() ) // "Detalhes"
		EndIf
	Else
		If Self:HasMessage() .And. Self:oMessage != Nil
			lExibeBotaoDetalhe := .T.
		EndIf
		
		DEFINE MSDIALOG oDlgII TITLE STR0001 FROM 0,0 TO 130,600 PIXEL // "Mensagem"
		
		DEFINE FONT oFntTit NAME "Arial"  SIZE 6,16	BOLD
		DEFINE FONT oFntMsg NAME "Arial"  SIZE 5,15
		
		@ 0,0  BITMAP oBmp RESNAME "LOGIN" oF oDlgII SIZE 100,600 NOBORDER WHEN .F. PIXEL // "Integra��o com Exchange"
		@05,50 TO 45,300 PROMPT STR0003 PIXEL // "Informa��o"
		@11,52 GET cMessage FONT oFntMsg MULTILINE NOBORDER READONLY HSCROLL SIZE 245,30 PIXEL
		
		@50,200 BUTTON "OK" PIXEL ACTION oDlgII:End()
		
		If lExibeBotaoDetalhe .And. Self:oMessage != Nil
			@50,230 BUTTON STR0002 PIXEL ACTION If(	!lTelaDetalhe,;  // "Detalhes"
			(oDlgII:ReadClientCoors(.T.),oDlgII:Move(oDlgII:nTop,oDlgII:nLeft,oDlgII:nWidth,oDlgII:nHeight+165,,.T.),lTelaDetalhe:=.T.),;
			(oDlgII:ReadClientCoors(.T.),oDlgII:Move(oDlgII:nTop,oDlgII:nLeft,oDlgII:nWidth,oDlgII:nHeight-165,,.T.),lTelaDetalhe:=.F.))		
			@ 67,50 TO 140,300 PROMPT STR0004 PIXEL // "Detalhes da informa��o:"
			@ 73,52 GET oMsgDet VAR Self:oMessage:ToString() FONT oFntMsg MULTILINE NOBORDER READONLY HSCROLL SIZE 245,65 PIXEL
		EndIf
		
		ACTIVATE MSDIALOG oDlgII CENTERED
	EndIf
Return

