#INCLUDE "LOJA170.CH"
#INCLUDE "FIVEWIN.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � LojA170	� Autor � Fernando Godoy	     � Data � 16/10/96���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Leitura X 									        	  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � Generico 												  ���   
�������������������������������������������������������������������������Ĵ��
��� DATA     � BOPS �Prograd.�ALTERACAO                                   ���
�������������������������������������������������������������������������Ĵ��
���23/06/05  �083499�Marcos  �Incluido a funcao LJVLDSERIE para verificar ���
���          �      �        �se o nro de serie do ECF conectado e o mesmo��� 
���          �      �        �cadastrado na estacao                       ���
���05/04/07  �122711�Conrado �Alterada a utiliza��o da chamada            ���
���          �      �        �SubStr(cUsuario,7,15) por cUserName         ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function LojA170

LOCAL nOpca 		:= 0
LOCAL oDlg
Local cImpressora := LJGetStation("IMPFISC")
Local cLock 		:= cUserName+cEstacao  
Local lRet			:= .T.  // Retorno da funcao
Local nHandle     	:= -1
Local lEmitNfce	  	:= FindFunction("LjEmitNFCe") .AND.  LjEmitNFCe()								// Sinaliza se utiliza NFC-e						
Local lIsMDI 		:= Iif(ExistFunc("LjIsMDI"),LjIsMDI(),SetMDIChild(0)) //Verifica se acessou via SIGAMDI

Private cCadastro := OemToAnsi(STR0001)

//��������������������������������������������������������������Ŀ
//� Abre a impressora fiscal - FATURAMENTO                       �
//����������������������������������������������������������������
If cModulo == "FAT"
	If Type("nHdlECF") == "U" .Or. nHdlECF == -1
  		nHandle := IFAbrir(SuperGetMv("MV_IMPFIS"),SuperGetMv("MV_PORTFIS"))
    	Private lFiscal := nHandle >= 0
  EndIf
Else
	If type("nHdlECF") == "N"
		nHandle := nHdlECF
	EndIf
EndIf

//�����������������������������������������������������������������������Ŀ
//� Faz o controle via LockByName para evitar que um usu�rio acesse       �
//� 2 vezes uma rotina que use os perif�ricos de automa��o, evitando assim�
//� a concorr�ncia dos mesmos.                                            �
//�������������������������������������������������������������������������
If lIsMDI .And. !LockByName( cLock )
	lRet := .F.
Else
	If !lFiscal
		//Para Emitir a Leitura X da Impressora fiscal, deve-se
		//estar cadastrado como usu�rio fiscal e com os par�metros da impressora corretos.
		//Aten��o
		MsgStop(Oemtoansi(STR0002)+;
		Oemtoansi(STR0003),;
		Oemtoansi(STR0004))
		lRet := .F.
	ElseIf lEmitNfce
		MsgInfo( STR0012 + Chr(10) + STR0013 )	//"A Leitura X est� dispon�vel apenas para Emissor de Cupom Fiscal (ECF) configurado."  ## "N�o h� emiss�o em Equipamento n�o fiscal com NFC-e."				 
		lRet := .F.	
	Else
		//���������������������������������������������������������������������Ŀ
		//�Consiste o numero de serie do equipamento conforme arq. sigaloja.bin � 
		//�somente se o parametro MV_LJNSECF = .T.                              �
		//�����������������������������������������������������������������������
		If	LJVLDSERIE()
			DEFINE MSDIALOG oDlg FROM 39,85 TO 210,340 TITLE OemToAnsi(cCadastro) PIXEL OF oMainWnd
			DEFINE FONT oFont NAME "Ms Sans Serif" BOLD
			// Objetivo do Programa
			@ 7, 4 TO 60, 121 LABEL STR0005 OF oDlg PIXEL
			
			// Este programa tem como
			// objetivo efetuar	a	impress�o	do
			// cupom de leitura impressora fiscal
			@ 19, 15 SAY OemToAnsi(STR0006 +STR0007 +STR0008 + cImpressora + ".") SIZE 100, 40 OF oDlg PIXEL FONT oFont
			DEFINE SBUTTON FROM 65, 65 TYPE 1;
			ACTION (nOpca := 1,IF(MsgYesNo( OemToAnsi(STR0010),OemToAnsi(STR0011) ),oDlg:End(),nOpca:=0)) ENABLE OF oDlg
			DEFINE SBUTTON FROM 65, 94 TYPE 2;
			ACTION oDlg:End() ENABLE OF oDlg
			
			ACTIVATE MSDIALOG oDlg CENTERED
			
			If nOpca == 1
				If LjProfile( 21 )
					Processa({|lEnd| IFLeituraX( nHandle )})
				EndIf
			Endif
			oFont:End()
		EndIf
	EndIf	
EndIf

If cModulo == "FAT"
	nHandle := IFFechar(nHandle, SuperGetMv("MV_PORTFIS"))
EndIf

Return lRet
