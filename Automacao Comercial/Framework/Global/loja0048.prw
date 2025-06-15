#INCLUDE "PROTHEUS.CH"  

// O protheus necessita ter ao menos uma fun��o p�blica para que o fonte seja exibido na inspe��o de fontes do RPO.
Function LOJA0048() ; Return

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     Classe: � LJCMessage                        � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Classe que representa uma mensagem utilizada pela classe               ���
���             � LJCMessageManager.                                                     ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/                               
Class LJCMessage From FWSerialize
	Data cName
	Data cMessage
	Data cCallStack
	Data nType
	Data oInnerMessage
	
	Method New() 
	Method HasMessage()
	Method HasError()
	Method HasWarning()
	Method HasInformation()
	Method ToString()
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
��� Parametros: � cName: Nome identificador da mensagem                                  ���
���             � nType: Tipo da mensagem, sendo:                                        ���
���             �        1 - Erro                                                        ���
���             �        2 - Aviso                                                       ���
���             �        2 - Informa��o                                                  ���
���             � cMessage: A mensagem.                                                  ���
���             � oInnerMessage: Objeto LJCMessage interno, ou a mensagem que gerou essa.���
����������������������������������������������������������������������������������������͹��
���    Retorno: � Self                                                                   ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method New( cName, nType, cMessage, oInnerMessage) Class LJCMessage
	Local nCount		:= 1
	Local aCallStack	:= {}
	Local aRet			:= {}
	Local aType			:= {}
	Local aFile 		:= {}
	Local aLine 		:= {}
	Local aDate 		:= {}
	Local aTime 		:= {}	

	Self:cName			:= cName
	Self:cMessage		:= cMessage
	Self:oInnerMessage	:= oInnerMessage
	Self:nType			:= nType
	Self:cCallStack		:= ""
	
	If ValType(cName) != "U"		
		// Pega o callstack
		While !Empty(ProcName(nCount))
			aAdd( aCallStack, ProcName(nCount) )
			nCount++
		End
	
		For nCount := 1 To Len(aCallStack)
			aRet := GetFuncArray( aCallStack[nCount], @aType, @aFile, @aLine, @aDate, @aTime )
			
			Self:cCallStack += "    on " + aCallStack[nCount] + "(" + If(Len(aFile)>0, aFile[1], "Unknown") + ") " + If(Len(aFile)>0,DToc(aDate[1]),"Unknown") + " line : " + AllTrim(Str(ProcLine(nCount+1))) + If(Len(aCallStack)==nCount,"",Chr(13) + Chr(10))
			nCount++
		End	
	EndIf
Return Self

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
Method HasMessage( cMessageName ) Class LJCMessage
	Local lHasMessage := .T.

	If cMessageName != Nil
		lHasMessage := .F.
		If Lower(Self:cName) == Lower(cMessageName)
			lHasMessage := .T.
		Else
			If Self:oInnerMessage != Nil
				lHasMessage := Self:oInnerMessage:HasMessage( cMessageName )
			EndIf
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
Method HasError( cMessageName ) Class LJCMessage
	Local lHasMessage := .T.

	If cMessageName != Nil
		lHasMessage := .F.
		If Lower(Self:cName) == Lower(cMessageName) .And. Self:nType == 1
			lHasMessage := .T.
		Else
			If Self:oInnerMessage != Nil
				lHasMessage := Self:oInnerMessage:HasError( cMessageName )
			EndIf
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
Method HasWarning( cMessageName ) Class LJCMessage
	Local lHasMessage := .T.

	If cMessageName != Nil
		lHasMessage := .F.
		If Lower(Self:cName) == Lower(cMessageName) .And. Self:nType == 2
			lHasMessage := .T.
		Else
			If Self:oInnerMessage != Nil		
				lHasMessage := Self:oInnerMessage:HasWarning( cMessageName )
			EndIf
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
Method HasInformation( cMessageName ) Class LJCMessage
	Local lHasMessage := .T.

	If cMessageName != Nil
		lHasMessage := .F.
		If Lower(Self:cName) == Lower(cMessageName) .And. Self:nType == 3
			lHasMessage := .T.
		Else
			If Self:oInnerMessage != Nil		
				lHasMessage := Self:oInnerMessage:HasWarning( cMessageName )
			EndIf
		EndIf
	EndIf	
Return lHasMessage

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � ToString                          � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Converte a mensagem para um texto de exibi��o.                         ���
���             �                                                                        ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � Nenhum                                                                 ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � cText: Texto de exibi��o.                                              ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method ToString() Class LJCMessage
	Local cText := ""
	
	cText += "Message: " + Self:cName
	If Self:cMessage != Nil .Or. !Empty(Self:cMessage)
		cText += Chr(13) + Chr(10) + Self:cMessage
	EndIf
	If Self:cCallStack != Nil .Or. !Empty(Self:cCallStack)
		cText += Chr(13) + Chr(10) + Self:cCallStack
	EndIf
	
	// Se existir mensagem interna, pega o texto dela
	If Self:oInnerMessage != Nil
		cText += Chr(13) + Chr(10) + Self:oInnerMessage:ToString()
	EndIf	
Return cText

