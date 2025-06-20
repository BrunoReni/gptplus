#INCLUDE "PROTHEUS.CH"

/*����������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������Ŀ��
���Fun��o    � MATA447D � Autor � Guadalupe Santacruz          � Data � 20/07/16 ���
��������������������������������������������������������������������������������Ĵ��
���Descri��o � Funciones para el calculo de impuestos de importacion             ���
���          � Mexico                                                            ���
��������������������������������������������������������������������������������Ĵ��
���Sintaxe   � MATA447D()                                                        ���
��������������������������������������������������������������������������������Ĵ��
���                ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
��������������������������������������������������������������������������������Ĵ��
���Programador � Data   �     BOPS    �  Motivo da Alteracao                     ���
��������������������������������������������������������������������������������Ĵ��
��� gsantcruz  �22/03/17� TSSERMI01-35�Se agrega el FV a la rutina M447DTA7      ���
��� Marco A    �29/09/17�TSSERMI01-151�Se realiza replica para V12.1.17, de la   ���
���            �        �             �funcionalidad de Pedimentos de Importacion���
���            �        �             �para el Pais Mexico.                      ���
���������������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������������
����������������������������������������������������������������������������������*/
/*�����������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �M447DTA7    � Autor � Gpe Santacruz         | Data � 01/04/16 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Calculo de DTA                                                ���
���������������������������������������������������������������������������Ĵ��
���Parametros�Ninguno                                                       ���
���������������������������������������������������������������������������Ĵ��
���Retorno   �nExp1.- Valor del DTA                                         ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �M447DTA7()                                                    ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � Es llamada el contenido del RSA_FUNC (tabla de impuestos imp)���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function M447DTA7()
	/*
	//�������������������������������������������������������������Ŀ
	//�Calculo de DTA: Solo aplicara sobre los �tems de tipo        �
	//�mercanc�a, que tengan impuesto IGI diferente de cero         �
	//� (para identificar los �tems con  IGI, son lo que tienen uso �
	//�de fracci�n arancelaria  RSA_usofrac ='1'), este IGI se      �
	//�identifica en la pesta�a de  Impuestos por �tem ,            �
	//�por cada �tem se multiplica el Costo CIF (este ya est�       �
	//�calculado en la pesta�a Datos de Importaci�n por �tem, en    �
	//� la columna de Valor Aduana )por la tasa (RSA_tasimp).       �
	//� El resultado debe reflejarse en la pesta�a de Impuestos a   �
	//�Nivel Pedimento, en la columna de Importe y en el pie de     �
	//�p�gina.                                                      �
	//���������������������������������������������������������������
	*/
	Local nValor := 0

	If lUsoRSG //SI LA TABLA TEMPORAL DE SECCIONES POR ITEM YA ESTA CREADA
		If !empty(TMPRSG->RSG_FRACAR)
			RSB->(DBSetOrder(1))//RSA_FILIAL+RSA_USOFRA
			If RSB->(DBSeek(xFilial("RSB")+TMPRSG->RSG_FRACAR))
				//Si tasa IGI mayor a cero, o si en el pedimento dice que aplica DTA, o si de acuerdo al pais de origen aplica DTA
				If TMPRSG->RSG_APLDTA<>'1'
					If M->RSC_FV > 0
						nValor := ROUND((TMPRSG->RSG_VALADU * M->RSC_FV) * (RSA->RSA_TASIMP / 100), 0) 
					Else
						nValor := ROUND(TMPRSG->RSG_VALADU * (RSA->RSA_TASIMP / 100), 0)
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

Return nValor

/*�����������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �M447DTA4    � Autor � Gpe Santacruz         | Data � 30/10/11 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Funcion para calculo de DTA4 (Mex)                            ���
���������������������������������������������������������������������������Ĵ��
���Parametros�Ninguno                                                       ���
���������������������������������������������������������������������������Ĵ��
���Retorno   �nExp1.- Valor del DTA4                                        ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �M447DTA4()                                                    ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � Es llamada el contenido del RSA_FUNC (tabla de impuestos imp)���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function M447DTA4()

	Local aArea		:= GetArea()
	Local nValor	:= 0
    If lUsoRSG
		RSB->(DBSetOrder(1))//RSA_FILIAL+RSA_USOFRA
		If RSB->(DBSeek(xFilial("RSB")+TMPRSG->RSG_FRACAR))
	         //Si tasa IGI mayor a cero, o si en el pedimento dice que aplica DTA, o si de acuerdo al pais de origen aplica DTA
			If TMPRSG->RSG_APLDTA <> '1'
				nValor := RSA->RSA_IMPORT / nPAplDTA
			EndIf
		EndIf
    ENDIF
	RestArea(aArea)

Return nValor


/*�����������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �M447IEPS    � Autor � Gpe Santacruz         | Data � 31/10/11 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Funcion para calculo de IEPS (Mex)                            ���
���������������������������������������������������������������������������Ĵ��
���Parametros�Ninguno                                                       ���
���������������������������������������������������������������������������Ĵ��
���Retorno   �nExp1.- Valor del IEPS                                        ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �M447IEPS()                                                    ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � Es llamada el contenido del RSA_FUNC (tabla de impuestos imp)���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function M447IEPS()

	Local aArea	:= GetArea()
	Local nValor	:= 0
	//Verifica el IGI del item a calcular
	Local nPos2	:= aScan(aImpItem,{|x| AllTrim(x[1])+ AllTrim(x[2])+AllTrim(x[3])+ AllTrim(x[4])+AllTrim(x[5])+;
								AllTrim(x[6])==AllTrim(TMPRSH->RSH_FACT)+AllTrim(TMPRSH->RSH_SERIE)+AllTrim(TMPRSH->RSH_PROV)+AllTrim(TMPRSH->RSH_TDA)+;
								AllTrim(TMPRSH->RSH_ITEM)+AllTrim(TMPRSH->RSH_IMPUES)})
	//DTA que pag� esta partida
	Local nPos		:= aScan(aTNivPed,{|x| AllTrim(x[1])+ AllTrim(x[2])+AllTrim(x[3])+ AllTrim(x[4])+AllTrim(x[5])==;
								AllTrim(TMPRSH->RSH_FACT)+AllTrim(TMPRSH->RSH_SERIE)+AllTrim(TMPRSH->RSH_PROV)+AllTrim(TMPRSH->RSH_TDA)+;
								AllTrim(TMPRSH->RSH_ITEM)})

	If lUsoRSG
		If TMPRSG->(DBSeek(TMPRSH->RSH_FACT+TMPRSH->RSH_SERIE+TMPRSH->RSH_PROV+TMPRSH->RSH_TDA+TMPRSH->RSH_ITEM))
			If nPos > 0
				If nPos2 > 0
					nValor := RSA->RSA_TASIMP / 100 * (TMPRSG->RSG_VALADU+aTNivPed[nPos,7]+aImpItem[nPos2,7]) //CIF+DTA+IGI
				Else
					nValor := RSA->RSA_TASIMP / 100 * (TMPRSG->RSG_VALADU+aTNivPed[nPos,7]) //CIF+DTA
				EndIf
			Else
				nValor := RSA->RSA_TASIMP / 100 * TMPRSG->RSG_VALADU
			EndIf
		EndIf
	EndIf

	RestArea(aArea)

Return nValor

/*�����������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �M447PRV     � Autor � Gpe Santacruz         | Data � 31/10/11 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Funcion para calculo de PRV (Mex)                            ���
���������������������������������������������������������������������������Ĵ��
���Parametros�Ninguno                                                       ���
���������������������������������������������������������������������������Ĵ��
���Retorno   �nExp1.- Importe PRV                                           ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �M447PRV()                                                     ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � Campo RSA_FUNC                                               ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function M447PRV()

	Local nValor := 0

	nValor := RSA->RSA_IMPORT

Return nValor

/*�����������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �M447IGI     � Autor � Gpe Santacruz         | Data � 31/10/11 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Funcion para calculo de IGI (Mex)                            ���
���������������������������������������������������������������������������Ĵ��
���Parametros�Ninguno                                                       ���
���������������������������������������������������������������������������Ĵ��
���Retorno   �nExp1.- Importe IGI                                           ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �M447IGI()                                                     ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � Campo RSA_FUNC                                               ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function M447IGI()

	Local aArea	:= GetArea()
	Local nValor	:= 0
	Local cFraIm1	:= ''
	Local nTasIm1	:= 0
	Local cPaiIm1	:= ''

	If lUsoRSG
		If TMPRSG->(DBSeek(TMPRSH->RSH_FACT+TMPRSH->RSH_SERIE+TMPRSH->RSH_PROV+TMPRSH->RSH_TDA+TMPRSH->RSH_ITEM))
			cFraIm1 := TMPRSG->RSG_FRACAR
			cPaiIm1 := TMPRSG->RSG_PAIVTA
			If !empty(cFraIm1)
				RSB->(DBSetOrder(1))//RSA_FILIAL+RSA_USOFRA
				If RSB->(DBSeek(xFilial("RSB")+cFraIm1+cPaiIm1))
					nTasIm1 := RSB->RSB_TASA
				EndIf
				If M->RSC_FV > 0 .and. M->RSC_FV<>NIL
					nValor := Round(nTasIm1 / 100 * (TMPRSG->RSG_VALADU * M->RSC_FV), 0)
				Else
					nValor := Round(nTasIm1 / 100 * (TMPRSG->RSG_VALADU), 0)
				EndIf
			EndIf
		EndIf
	EndIf
	RestArea(aArea)

Return nvalor


/*�����������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �M447CC      � Autor � Gpe Santacruz         | Data � 08/11/18 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Funcion para calculo de Cuota Compensatoria                   ���
���������������������������������������������������������������������������Ĵ��
���Parametros�Ninguno                                                       ���
���������������������������������������������������������������������������Ĵ��
���Retorno   �nExp1.- Valor de la cuota                                     ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �M447CC()                                                     ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � Es llamada el contenido del RSA_FUNC (tabla de impuestos imp)���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function M447CC()

	Local aArea	:= GetArea()
	Local nValor	:= 0

	If lUsoRSG
				nValor := TMPRSH->RSH_IMPORT
	EndIf

	RestArea(aArea)

Return nValor
