#INCLUDE "Protheus.ch"

// O protheus necessita ter ao menos uma fun��o p�blica para que o fonte seja exibido na inspe��o de fontes do RPO.
Function LOJA0051() ; Return

// Simulando job LOJA1115
Function JobA()	
	Local oLJCLocker := If( FindFunction("LOJA0051"), LJCGlobalLocker():New(), )
	While .T.
		If If( FindFunction("LOJA0051"), oLJCLocker:GetLock( "JobALock" ), .T. )
			ConOut( "JobA locou" )
			ConOut( "Processando JobA" )
			Sleep(2000)
			ConOut( "JobA vai liberar" )
			If( FindFunction("LOJA0051"), oLJCLocker:ReleaseLock( "JobALock" ),)
			
			ConOut( "JobA liberou" )
		Else
			ConOut( "JobA nao locou" )
		EndIf
		Sleep(1000)
	End
Return

// Simulando job gravabatch
Function JobB()
	Local oLJCLocker := LJCGlobalLocker():New()
	While .T.
		If oLJCLocker:GetLock( "JobBLock" )
			ConOut( "JobB locou" )
			ConOut( "Processando JobB" )
			Sleep(3000)
			Return
			ConOut( "JobB vai liberar" )
			oLJCLocker:ReleaseLock( "JobBLock" )
			ConOut( "JobB liberou" )			
		Else
			ConOut( "JobB nao locou" )
		EndIf
		Sleep(1000)
	End	
Return

/*
//------------------------------------------------------------------------ ATENCAO !!! ------------------------------------------------------------------------
//
//A User Function CARGA � utilizada apenas para teste. Descomentar apenas para teste e depois comentar a fun��o novamente, pois nao pode subir no RPO padrao.
//
//-------------------------------------------------------------------------------------------------------------------------------------------------------------
User Function Carga()
	Local oLJCLocker := LJCGlobalLocker():New()
		
	If oLJCLocker:MultiWaitGetLock( { "JobALock", "JobBLock" } )
		ConOut( "Efetuando carga" )
		Sleep(4000)
		ConOut( "Carga vai liberar" )
		oLJCLocker:MultiReleaseLock( { "JobALock", "JobBLock" } )
		ConOut( "Carga liberou" )
	EndIf
Return
*/

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     Classe: � LJCGlobalLocker                   � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Class que permite o controle de travas entre processos.                ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Class LJCGlobalLocker
	Method New()
	Method MultiGetLock()
	Method GetLock()
	Method MultiWaitGetLock()
	Method WaitGetLock()
	Method MultiReleaseLock()
	Method ReleaseLock()
EndClass                      

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � New                               � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Construtor                                                             ���
���             �                                                                        ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � Nenhum.                                                                ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � Self                                                                   ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method New() Class LJCGlobalLocker
Return Self

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � MultiGetLock                      � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Efetua a trava de m�ltiplos nomes.                                     ���
���             �                                                                        ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � aNames: Array de nomes que ser�o travados.                             ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � Self                                                                   ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method MultiGetLock( aNames ) Class LJCGlobalLocker
Return Self:MultiWaitGetLock( aNames, 1, 0 )

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � GetLock                           � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Efetua a trava de um nome.                                             ���
���             �                                                                        ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � cName: Nome a ser travado.                                             ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � Self                                                                   ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method GetLock( cName ) Class LJCGlobalLocker
Return Self:WaitGetLock( cName, 1, 0 )

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � MultiWaitGetLock                  � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Efetua a trava de um conjunto de nomes com possibilidade de um         ���
���             � determinado n�mero de tentativas e espera entre as tentativas.         ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � aNames: Array de nomes que ser�o travados.                             ���
���             � nTries: N�mero de tentativas.                                          ���
���             � nTryInterval: Espera entre tentativas (em milisegundos).               ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � Self                                                                   ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method MultiWaitGetLock( aNames, nTries, nTryInterval ) Class LJCGlobalLocker
	Local nCount 	:= 1
	Local lLocked	:= .F.
	Local aGotLocks := {}
	
	For nCount := 1 To Len( aNames )
		If !Self:WaitGetLock( aNames[nCount], nTries, nTryInterval )
			lLocked:= .F.
			Exit
		Else
			aAdd( aGotLocks, aNames[nCount] )
			lLocked:= .T.
		EndIf
	Next	
	
	If lLocked == .F. .And. Len( aGotLocks ) > 0
		Self:ReleaseLock( aGotLocks )
	EndIf
Return lLocked

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � WaitGetLock                       � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Efetua a trava de um nome com possibilidade de um determinado n�mero   ���
���             � de tentativas e espera entre as tentativas.                            ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � cName: Nome a ser travado.                                             ���
���             � nTries: N�mero de tentativas.                                          ���
���             � nTryInterval: Espera entre tentativas (em milisegundos).               ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � Self                                                                   ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method WaitGetLock( cName, nTries, nTryInterval ) Class LJCGlobalLocker
	Local nTry		:= 0
	Local lLocked	:= .F.
	
	Default nTries = 0
	Default nTryInterval = 100
	
	// Loop de controle de tentativas e seu n�mero m�ximo
	While nTry <= nTries
								
		// Se conseguir pegar o lock, sai do loop
		/*
		If Val( GetGlbValue( "LJCGlobalLocker" + Lower(cName) )) == 0
			PutGlbValue( "LJCGlobalLocker" + Lower(cName), "1" )	
			lLocked := .T.
			Exit
		EndIf		
		*/
		If LockByName( "LJCGlobalLocker" + Lower(cName), .F., .F. )
			lLocked := .T.
			Exit
		EndIf		
	
		// Se for para tentar lockar limitadas vezez, aumenta a quantidade de tentativas e espera o tempo informado
		If nTries > 0
			nTry ++
		EndIf
		Sleep( nTryInterval )
	End	
Return lLocked

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � MultiReleaseLock                  � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Efetua a libera��o da trava de um conjunto de nomes.                   ���
���             �                                                                        ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � aNames: Nomes a serem liberados.                                       ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � Self                                                                   ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method MultiReleaseLock( aNames ) Class LJCGlobalLocker
	Local nCount := 1
	
	For nCount := 1 To Len( aNames )
		Self:ReleaseLock( aNames[nCount] )
	Next
Return

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � MultiReleaseLock                  � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Efetua a libera��o da trava de um nome.                                ���
���             �                                                                        ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � cName: Nome a ser liberado.                                            ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � Self                                                                   ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method ReleaseLock( cName ) Class LJCGlobalLocker
	UnLockByName( "LJCGlobalLocker" + Lower(cName), .F., .F. )
	/*
	If GetGlbValue( "LJCGlobalLocker" + Lower(cName) ) == "1"
		PutGlbValue( "LJCGlobalLocker" + Lower(cName), "0" )	
	EndIf
	*/
Return