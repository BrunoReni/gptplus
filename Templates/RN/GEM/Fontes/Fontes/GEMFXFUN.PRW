
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FA080BTN  �Autor  �Reynaldo Miyashita  � Data �  14.12.2005 ���
�������������������������������������������������������������������������͹��
���Desc.     � Cria��o do bot�o na toolbar na tela de baixa manual de     ���
���          � titulos a pagar para visualizar detalhes do titulo.        ���
�������������������������������������������������������������������������͹��
���Uso       � SIGAFIN                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�������� ��������������������������������������������������������������������
*/
Template Function FA080BTN()
Local aButtons := ParamIXB[1]
Local aArea    := GetArea()

// Valida se tem licen�as para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
If ! HasTemplate("LOT")
	Return aButtons 
EndIf
	
	dbSelectArea("LJV")
	dbSetOrder(1) // LJV_FILIAL+LJV_PREFIX+LJV_NUM+LJV_PARCEL+LJV_TIPO
	If dbSeek(xFilial("LJV")+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO)
		AAdd( aButtons, { "BUDGETY" ,{ || ExecTemplate("GEMSE2Detail",.F.,.F.) },"Detalhes do t�tulo", "Detalhes" } )
	EndIf

	RestArea(aArea)
	
Return(aButtons)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FA070BTN  �Autor  �Reynaldo Miyashita  � Data �  14.12.2005 ���
�������������������������������������������������������������������������͹��
���Desc.     � Cria��o do bot�o na toolbar na tela de baixa manual de     ���
���          � titulos a receber para visualizar detalhes do titulo.      ���
�������������������������������������������������������������������������͹��
���Uso       � SIGAFIN                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�������� ��������������������������������������������������������������������
*/
Template Function FA070BTN()
Local aButtons:= ParamIXB[1]
Local aArea   := GetArea()
Local lUltCM  := GetNewPar("MV_GEMULTC",.F.)                                        
                                            
if ! lUltCM
	// Valida se tem licen�as para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
	If ! HasTemplate("LOT")
		Return aButtons 
	EndIf
		
	dbSelectArea("LIX")
	dbSetOrder(1) // LIX_FILIAL+LIX_PREFIX+LIX_NUM+LIX_PARCEL+LIX_TIPO
	If dbSeek(xFilial("LIX")+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO)
		AAdd( aButtons, { "BUDGETY" ,{ || ExecTemplate("GEMSE1Detail",.F.,.F.) },"Detalhes do t�tulo", "Detalhes" } )
	EndIf
endif
	
RestArea(aArea)
Return(aButtons)



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GEMMA461  �Autor  �Reynaldo Miyashita  � Data �  14.12.2005 ���
�������������������������������������������������������������������������͹��
���Desc.     � Retorna o valor da amortizacao e do juros das parcelas     ���
�������������������������������������������������������������������������͹��
���Uso       � SIGAFAT                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�������� ��������������������������������������������������������������������
*/
Template Function GEMMA461()
Local cPedido    := ParamIXB[1]
Local cCond      := ParamIXB[2]
Local dDataCnd   := ParamIXB[3]
Local nVlrTitulo := ParamIXB[4]
Local aTitCndVnd := {}

// Valida se tem licen�as para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
If ! HasTemplate("LOT")
	Return {}
EndIf

	If ExistTemplate("GMCondPagto") .AND. ExecTemplate("GMCondPagto",.F.,.F.,{cCond,} )
		If SF2->F2_COND == GetMV("MV_GMCPAG")
			If ExistTemplate("GMMA410Dupl")
				//Se condicao de venda personalizada, processa os titulos
				aTitCndVnd := ExecTemplate("GMMA410Dupl",.F.,.F.,{cPedido ,cCond ,dDataCnd ,3 ,nVlrTitulo,/*NIL*/ }) 
			EndIf
		Else
			//Se condicao de venda cadastrada, processa os titulos
			If ExistTemplate("GMCondicao")
            	aTitCndVnd := ExecTemplate("GMCondicao",.F.,.F.,{cCond,dDataCnd,nVlrTitulo,.T. })
			EndIf
		EndIf
	EndIf

Return( aTitCndVnd )


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MA030ROT  �Autor  �Reynaldo Miyashita  � Data �  20.03.2006 ���
�������������������������������������������������������������������������͹��
���Desc.     � Adiciona o bot�o "copia" na tela de cadastro de clientes   ���
���          � que vai permitir a copia dos dados do cliente para um novo.���
�������������������������������������������������������������������������͹��
���Uso       � MATA030                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�������� ��������������������������������������������������������������������
*/
Template Function MA030ROT()
Local aRotina := NIL

// Valida se tem licen�as para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
If HasTemplate("LOT")
	aRotina := {}
	aAdd( aRotina ,{"C�pia","t_GEMCpySA1",0,3} )
EndIf

Return( aRotina )
