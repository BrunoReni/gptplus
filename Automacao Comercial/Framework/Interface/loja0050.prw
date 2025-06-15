#INCLUDE "PROTHEUS.CH" 

// O protheus necessita ter ao menos uma fun��o p�blica para que o fonte seja exibido na inspe��o de fontes do RPO.
Function LOJA0050() ; Return        

/*
Static Function TstTabbedPanel()
	Local oTabbedPanel	:= Nil
	Local oDlg			:= Nil
	
	DEFINE MSDIALOG oDlg TITLE "Janela" FROM 0,0 TO 600,800 PIXEL		
	
	oTabbedPanel := LJCTabbedPanel():New( oDlg, 4 )

	oTabbedPanel:AddTab( "Teste 1" )
	oTabbedPanel:AddTab( "Teste 2" )	
	oTabbedPanel:AddTab( "Teste 3" )		
	oTabbedPanel:AddTab( "Teste 4" )			
	oTabbedPanel:AddTab( "Teste 5" )				
	oTabbedPanel:AddTab( "Teste 6" )				
	oTabbedPanel:AddTab( "Teste 7" )			                                                
		
	oTabbedPanel:Show()
	
	oDlg:Activate()	
Return
*/

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     Classe: � LJCTabbedPanel                    � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Classe visual para a exibi��o de pain�s separado por abas.             ���
���             �                                                                        ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Class LJCTabbedPanel
	Data oOwner
	Data cTitle
	Data aoTabs
	Data aoTabButtons
	Data cHeight
	Data oPanel
	Data nTabPos

	Method New()
	Method AddTab()
	Method Show()
	Method DrawTabs()
	Method ShowPanel()	
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
��� Parametros: � oDlg: Di�logo ou pain�l pai.                                           ���
���             � nTabPos: Posi��o da aba, sendo:                                        ���
���             �          1 - Esquerda                                                  ���
���             �          2 - Acima                                                     ���
���             �          3 - Direita                                                   ���
���             �          2 - Abaixo                                                    ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � Nil                                                                    ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method New( oDlg, nTabPos ) Class LJCTabbedPanel
	Default nTabPos := 1

	Self:oOwner 	:= oDlg
	Self:aoTabs		:= {}
	Self:nTabPos	:= nTabPos
Return

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � AddTab                            � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Adicionada uma aba.                                                    ���
���             �                                                                        ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � cTitle: T�tulo de exibi��o da aba.                                     ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � oPanel: Pain�l que deve ser utilizado para adi��o de componentes.      ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method AddTab( cTitle ) Class LJCTabbedPanel
	oPanel :=  TPanel():New( 0,0 , , Self:oOwner , , , ,,,0,0)
	oPanel:Align := CONTROL_ALIGN_ALLCLIENT	
		
	aAdd( Self:aoTabs, { cTitle, oPanel } )
Return oPanel

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � Show                              � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Exibe as abas e seleciona uma.                                         ���
���             �                                                                        ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � nStartTab: Aba inicial.                                                ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � Nil                                                                    ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method Show( nStartTab ) Class LJCTabbedPanel
	Default nStartTab := 1
	
	Self:DrawTabs()
	Self:ShowPanel( nStartTab )
Return

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � DrawTabs                          � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Desenha as abas e os pain�is.                                          ���
���             �                                                                        ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � Nenhum.                                                                ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � Nil                                                                    ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method DrawTabs() Class LJCTabbedPanel
	Local nHeight 		:= 0
	Local nCount		:= 1
	Local oTempPanel	:= Nil
	Local oButtonsPanel	:= Nil	
	Local nFixedSize	:= 50
	Local nDinamicSize	:= 0
	Local nDiff			:= 0
	
	If Self:nTabPos == 1 .Or. Self:nTabPos == 3
		oButtonsPanel := TPanel():New( 0,0 , "", Self:oOwner , , , , , ,nFixedSize,0)
	ElseIf Self:nTabPos == 2 .Or. Self:nTabPos == 4
		oButtonsPanel := TPanel():New( 0,0 , "", Self:oOwner , , , , , ,0,nFixedSize)
	EndIf
	                          	
	If Self:nTabPos == 1
		oButtonsPanel:Align := CONTROL_ALIGN_LEFT
	ElseIf Self:nTabPos == 2
		oButtonsPanel:Align := CONTROL_ALIGN_BOTTOM
	ElseIf Self:nTabPos == 3
		oButtonsPanel:Align := CONTROL_ALIGN_RIGHT
	ElseIf Self:nTabPos == 4
		oButtonsPanel:Align := CONTROL_ALIGN_TOP
	EndIf
	
	If Self:nTabPos == 1 .Or. Self:nTabPos == 3
		nDinamicSize := Int( (Self:oOwner:nClientHeight/2) / Len( Self:aoTabs ) )
	ElseIf Self:nTabPos == 2 .Or. Self:nTabPos == 4
		nDinamicSize := Int( (Self:oOwner:nClientWidth/2) / Len( Self:aoTabs ) )		
	EndIf
	
	Self:aoTabButtons := {}

	For nCount := 1 To Len( Self:aoTabs )		
		If nCount == Len( Self:aoTabs )
			If Self:nTabPos == 1 .Or. Self:nTabPos == 3
				nDiff := (Self:oOwner:nClientHeight/2) - (Len( Self:aoTabs ) * nDinamicSize)  
			ElseIf Self:nTabPos == 2 .Or. Self:nTabPos == 4
				nDiff := (Self:oOwner:nClientWidth/2) - (Len( Self:aoTabs ) * nDinamicSize)  
			EndIf
		EndIf
		If Self:nTabPos == 1 .Or. Self:nTabPos == 3
			oTempPanel := TPanel():New( (nCount-1)*nDinamicSize, 0 ,  , oButtonsPanel , , , .T. , , , nFixedSize, nDinamicSize + nDiff)
		ElseIf Self:nTabPos == 2 .Or. Self:nTabPos == 4
			oTempPanel := TPanel():New( 0, (nCount-1)*nDinamicSize ,  , oButtonsPanel , , , .T. , , , nDinamicSize + nDiff, nFixedSize)
		EndIf
		
		oTempButton := TButton():New( 0, 0, Self:aoTabs[nCount][1],oTempPanel,&("{|| Self:ShowPanel( " + AllTrim(Str(nCount)) + " ) }"), 0,0,,,.F.,.T.,.F.,,.F.,,,.F. )
		oTempButton:Align := CONTROL_ALIGN_ALLCLIENT
	Next
Return

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � ShowPanel                         � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Exibe uma determinada aba.                                             ���
���             �                                                                        ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � nPanel: N�mero da aba.                                                 ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � Nil                                                                    ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method ShowPanel( nPanel ) Class LJCTabbedPanel
	Local nCount := 1
	
	For nCount := 1 To Len( Self:aoTabs )
		If nCount == nPanel
			Self:aoTabs[nCount][2]:Show()
		Else
			Self:aoTabs[nCount][2]:Hide()
		EndIf
	Next
Return