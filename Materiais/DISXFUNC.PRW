#include "PROTHEUS.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � M450LibCg� Autor � Octavio Moreira       � Data � 01.07.99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Ponto de entrada na filtragem do browse do MATA450         ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Especifico (DISTRIBUIDORES) igual M450Fil                  ���
�������������������������������������������������������������������������Ĵ��
��� Revis�o  �                                          � Data �          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
*/   

Function D450LibCg(cRt)

//��������������������������������������������������������������Ŀ
//� Define variaveis proprias da rotina                          �
//����������������������������������������������������������������
Local cVendDe  := "      "
Local cVendAte := "ZZZZZZ"
Local dDataDe  := Ctod("  /  /  ")
Local dDataAte := Ctod("31/12/05")
//Local cRt      := ".T."
Local lExec := existblock("M450FIL")

If !lExec

	//��������������������������������������������������������������Ŀ
	//� Dialog Principal.														  �
	//����������������������������������������������������������������
	
	DEFINE MSDIALOG oDlg1 FROM 000,000 TO 160,215 TITLE "Liberacao de Credito" PIXEL
	
		@ 003,003 To 030,106 OF oDlg1 PIXEL
		@ 003,005 Say "Vendedor" Size 25,10 Of oDlg1 PIXEL
		@ 015,008 Say "De" Size 10,10 Of oDlg1 PIXEL
		@ 015,020 MSGet cVendDe  Picture "@!" F3 "SA3" SIZE 36,10 OF oDlg1 PIXEL
		@ 015,055 Say OemtoAnsi("At�") Size 20,10 OF oDlg1 PIXEL
		@ 015,067 MsGet cVendAte Picture "@!" F3 "SA3" SIZE 36,10 OF oDlg1 PIXEL
		
		@ 033,003 To 060,106 OF oDlg1 PIXEL
		@ 033,005 Say "Data Liberacao" Size 40,10 OF oDlg1 PIXEL
		@ 045,008 Say "De" Size 15,10 OF oDlg1 PIXEL
		@ 045,020 MsGet dDataDe SIZE 35,10 OF oDlg1 PIXEL
		@ 045,055 Say OemtoAnsi("At�") OF oDlg1 PIXEL
		@ 045,067 MsGet dDataAte SIZE 35,10 OF oDlg1 PIXEL
	
		DEFINE SBUTTON FROM 066,075 TYPE 1 ACTION (oDlg1:End()) ENABLE OF oDlg1
	Activate Dialog oDlg1 Centered
	
	//��������������������������������������������������������������Ŀ
	//� Prepara o filtro a ser montado para devolve-lo ao MATA460    �
	//����������������������������������������������������������������
	If cVendDe <> "      " .Or. cVendAte <> "ZZZZZZ" .Or.;
	   dDataDe <> Ctod("  /  /  ") .Or. dDataAte <> Ctod("31/12/05")
	   cRt := cRt+iif(Empty(cRt),'','.and.')+'(C9_VEND1>="'+cVendDe+'".And.C9_VEND1<="'+cVendAte+'".And.'+;
	          'C9_DATALIB>=Ctod("'+Dtoc(dDatade)+'").And.C9_DATALIB<= '+;
	          'Ctod("'+Dtoc(dDataAte)+'"))'
//	Else
//	   cRt := '.T.'
	Endif
	
Endif
	
Return(cRt)


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � M455LibCg� Autor � Octavio Moreira       � Data � 01.07.99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Ponto de entrada na filtragem do browse do MATA455         ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Especifico (DISTRIBUIDORES)                                ���
�������������������������������������������������������������������������Ĵ��
��� Revis�o  �                                          � Data �          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
*/

Function D455LibCg(cRt)

//��������������������������������������������������������������Ŀ
//� Define variaveis proprias da rotina                          �
//����������������������������������������������������������������
Local cVendDe  := "      "
Local cVendAte := "ZZZZZZ"
Local dDataDe  := Ctod("  /  /  ")
Local dDataAte := Ctod("31/12/05")
//Local cRt      := ".t."
Local lExec := existblock("M455FIL")

If !lExec

	//��������������������������������������������������������������Ŀ
	//� Dialog Principal.														  �
	//����������������������������������������������������������������
	
	DEFINE MSDIALOG oDlg1 FROM 000,000 TO 160,215 TITLE "Liberacao de Estoques" PIXEL
	
	@ 003,003 To 030,106 OF oDlg1 PIXEL
	@ 003,005 Say "Vendedor" Size 30,10 OF oDlg1 PIXEL
	@ 015,008 Say "De" Size 15,10 OF oDlg1 PIXEL
	@ 015,020 MsGet cVendDe F3 "SA3" Picture "@!" SIZE 36,10 OF oDlg1 PIXEL
	@ 015,055 Say OemtoAnsi("At�") Size 15,10 OF oDlg1 PIXEL
	@ 015,067 MsGet cVendAte F3 "SA3" Picture "@!" SIZE 36,10 OF oDlg1 PIXEL
	
	@ 033,003 To 060,106 OF oDlg1 PIXEL
	@ 033,005 Say "Data Liberacao" Size 30,10 OF oDlg1 PIXEL
	@ 045,008 Say "De" Size 15,10 OF oDlg1 PIXEL
	@ 045,020 Get dDataDe SIZE 35,10 OF oDlg1 PIXEL
	@ 045,055 Say OemtoAnsi("At�") Size 15,10 OF oDlg1 PIXEL
	@ 045,067 Get dDataAte SIZE 35,10 OF oDlg1 PIXEL
	
	DEFINE SBUTTON FROM 066,075 TYPE 1 ACTION (oDlg1:End()) ENABLE OF oDlg1
	Activate Dialog oDlg1 Centered
	
	//��������������������������������������������������������������Ŀ
	//� Prepara o filtro a ser montado para devolve-lo ao MATA460    �
	//����������������������������������������������������������������
	If cVendDe <> "      " .Or. cVendAte <> "ZZZZZZ" .Or.;
	   dDataDe <> Ctod("  /  /  ") .Or. dDataAte <> Ctod("31/12/05")
	   cRt := cRt+iif(Empty(cRt),'','.and.')+'(C9_VEND1>="'+cVendDe+'".And.C9_VEND1<="'+cVendAte+'".And.'+;
	          'C9_DATALIB>=Ctod("'+Dtoc(dDatade)+'").And.C9_DATALIB<= '+;
	          'Ctod("'+Dtoc(dDataAte)+'"))'
//	Else
//	   cRt := '.t.'
	Endif
	
Endif	

Return(cRt)


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � M456LibCg� Autor � Octavio Moreira       � Data � 01.07.99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Ponto de entrada na filtragem do browse do MATA456         ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Especifico (DISTRIBUIDORES)                                ���
�������������������������������������������������������������������������Ĵ��
��� Revis�o  �                                          � Data �          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
*/

Function D456LibCg(cRt)

//��������������������������������������������������������������Ŀ
//� Define variaveis proprias da rotina                          �
//����������������������������������������������������������������
Local cVendDe  := "      "
Local cVendAte := "ZZZZZZ"
Local dDataDe  := Ctod("  /  /  ")
Local dDataAte := Ctod("31/12/05")
//Local cRt      := ".T."
Local lExec := existblock("M456FIL")

If !lExec

	//��������������������������������������������������������������Ŀ
	//� Dialog Principal.														  �
	//����������������������������������������������������������������

	DEFINE MSDIALOG oDlg1 FROM 000,000 TO 160,215 TITLE "Liberacao de Credito / Estoques" PIXEL
	
	@ 003,003 To 030,106 OF oDlg1 PIXEL
	@ 003,005 Say "Vendedor" Size 28,10 OF oDlg1 PIXEL
	@ 015,008 Say "De" Size 15,10 OF oDlg1 PIXEL
	@ 015,020 MsGet cVendDe F3 "SA3" Picture "@!" SIZE 36,10 OF oDlg1 PIXEL
	@ 015,055 Say OemtoAnsi("At�") Size 15,10 OF oDlg1 PIXEL
	@ 015,067 MsGet cVendAte F3 "SA3" Picture "@!" SIZE 36,10 OF oDlg1 PIXEL
	
	@ 033,003 To 060,106 OF oDlg1 PIXEL
	@ 033,005 Say "Data Liberacao" Size 45,10 OF oDlg1 PIXEL
	@ 045,008 Say "De" Size 15,10 OF oDlg1 PIXEL
	@ 045,020 Get dDataDe SIZE 35,10 OF oDlg1 PIXEL
	@ 045,055 Say OemtoAnsi("At�") Size 15,10 OF oDlg1 PIXEL
	@ 045,067 Get dDataAte SIZE 35,10 OF oDlg1 PIXEL
	
	DEFINE SBUTTON FROM 066,075 TYPE 1 ACTION (oDlg1:End()) ENABLE OF oDlg1
	Activate Dialog oDlg1 Centered
	
	//��������������������������������������������������������������Ŀ
	//� Prepara o filtro a ser montado para devolve-lo ao MATA460    �
	//����������������������������������������������������������������
	If cVendDe <> "      " .Or. cVendAte <> "ZZZZZZ" .Or.;
	   dDataDe <> Ctod("  /  /  ") .Or. dDataAte <> Ctod("31/12/05")
	   cRt := cRt+iif(Empty(cRt),'','.and.')+'(C9_VEND1>="'+cVendDe+'".And.C9_VEND1<="'+cVendAte+'".And.'+;
	          'C9_DATALIB>=Ctod("'+Dtoc(dDatade)+'").And.C9_DATALIB<= '+;
	          'Ctod("'+Dtoc(dDataAte)+'"))'
//	Else
//	   cRt := '.t.'
	Endif
Endif
	
Return(cRt)


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � M460FIL  � Autor � Octavio Moreira       � Data � 01.07.99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Ponto de entrada na filtragem do browse do MATA460         ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Especifico (DISTRIBUIDORES)                                ���
�������������������������������������������������������������������������Ĵ��
��� Revis�o  �                                          � Data �          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
*/
     
Function D460LibCg(cFilSC9,cQuery)

//��������������������������������������������������������������Ŀ
//� Define variaveis proprias da rotina                          �
//����������������������������������������������������������������
Local aOpcoes   := { OemtoAnsi("Sem montagem de carga"), OemtoAnsi("Carga de Caminhoes") }
Local nRadio    := 2
Local cCargaDe  := Space(6)
Local cCargaAte := "ZZZZZZ"
//Local cFilSC9   := ".T."
Local lExec     := existblock("M460FIL")
Local lExecT    := existTemplate("M460FIL")
Local lIntACD	:= (SuperGetMV("MV_INTACD",.F.,"0") == "1" .And. FindFunction("CBM460FIL")) //Integra��o com Modulo ACD.

If !lExec .and. !lExecT .And. !lIntACD

	//��������������������������������������������������������������Ŀ
	//� Dialog Principal.														  �
	//����������������������������������������������������������������
	
	DEFINE MSDIALOG oDlg1 FROM 000,000 TO 120,267 TITLE "Prepara�ao de Notas Fiscais" PIXEL
	
	@ 003,003 Radio oRadio Var nRadio Items OemtoAnsi("Sem montagem de carga"), OemtoAnsi("Carga de Caminhoes") 3D Size 70,10 Of oDlg1 PIXEL
	@ 030,005 Say "De" Size 15,10 Of oDlg1 PIXEL
	@ 030,016 MsGet cCargaDe Size 30,10 Picture "@!" When nRadio == 2 F3 "DAK" Of oDlg1 PIXEL
	@ 030,072 Say OemtoAnsi("At�") Size 15,10 Of oDlg1 PIXEL
	@ 030,086 MsGet cCargaAte Size 30,10 Picture "@!" When nRadio == 2 F3 "DAK" Of oDlg1 PIXEL
	DEFINE SBUTTON FROM 046,103 TYPE 1 ACTION (oDlg1:End()) ENABLE OF oDlg1
	Activate Dialog oDlg1 Centered
	
	//��������������������������������������������������������������Ŀ
	//� Prepara o filtro a ser montado para devolve-lo ao MATA460    �
	//����������������������������������������������������������������
	VAR_IXB := nRadio // variavel publica que permite tratamento posterior
	If nRadio == 1
	   cFilSC9 += iif(Empty(cFilSC9),'','.and.')+'(Empty(C9_CARGA) )'
	   If FunName(1) == "MATA460A"
		   cQuery    += iif(Empty(cQuery) ,""," AND ")+"C9_CARGA = '      ' "
		Endif		   
	Else
	   cFilSC9 += iif(Empty(cFilSC9),'','.and.')+'(!Empty(C9_CARGA).And.C9_CARGA>="'+cCargaDe+'".And.C9_CARGA<="'+cCargaAte+'")'
  	   If FunName(1) == "MATA460A"
		   cQuery    += iif(Empty(cQuery) ,""," AND ")+"C9_CARGA <> '      ' AND C9_CARGA>='"+cCargaDe+"' AND C9_CARGA <='"+cCargaAte+"'"
		Endif		   
	EndIf
Endif
	                   
Return(cFilSC9)

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
��� Funcao   � SE5FI070 � Autor � Waldemiro L. Lustosa  � Data � 10/08/1999 ���
���������������������������������������������������������������������������Ĵ��
��� Descricao� Ponto de Entrada na Gera��o de registros no SE5 (Fun��o      ���
���          � FA070Mov - Gera��o de Movimenta�ao Banc�ria)                 ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � Especifico (DISTRIBUIDORES)                                  ���
���������������������������������������������������������������������������Ĵ��
��� Descricao da Revisao                           � Responsavel �   Data   ���
���������������������������������������������������������������������������Ĵ��
��� Grava o campo E5_CARGA se o mesmo existir      �Almir Bandina� 17/04/00 ���
���������������������������������������������������������������������������Ĵ��
���                                                �             �          ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/         

Function DSe5Fi070()

// ������������������������������������������������������������������Ŀ
// � Avalio se este Ponto de Entrada esta sendo executado a partir do �
// � Acerto Financeiro (que utiliza a fun��o FA070Grv).               �
// ��������������������������������������������������������������������
If Type("l354MkAcF") == "L" .And. l354MkAcF
   SE5->E5_ACERFIN := "S"
EndIf

If SE5->(FieldPos("E5_CARGA"))>0
	SE5->E5_CARGA := SE1->E1_CARGA
EndIf

Return(.T.)


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �DVLDPTMOV �Autor  �Henry Fila          � Data �  09/14/00   ���
�������������������������������������������������������������������������͹��
���Desc.     �Valida o tipo de movimentaco no TES no campo de TES de      ���
���          �devolucao. O TES de devolucao deve ter o mesmo tipo de      ���
���          �movimentacao que o TES de saida                             ���
�������������������������������������������������������������������������͹��
���Uso       � AP5                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function DVldTpMov()

Local lRet := .T.
Local nReg := Recno()
Local cAlias := Alias() 

If Empty(M->F4_TPMOV)
	Help(" ",1,"DSTPMOVVZ") //Campo de tipo de movimentacao vazio
	lRet := .F.
Endif	

dbSelectarea("SF4")
dbSetOrder(1)
If dbSeek(xFilial("SF4")+&(ReadVar())) .And. lRet
	If (M->F4_TPMOV <> SF4->F4_TPMOV) 
		Help(" ",1,"DSTPMOVDIF") //Tipo de movimentacao difere da do tes de devolucao.
		lRet := .F.
	Endif		
Else
	Help(" ",1,"REGNO")
	lRet := .F.		
Endif
             
dbSelectArea(cAlias)
dbGoto(nReg)

Return(lRet)	     

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � DS460SOLI� Autor �Andrea Marques Federson� Data � 19/05/99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Calculo ICMS Solidario/Substit (Ponto Entrada - NF Saida)  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Especifico (DISTRIBUIDORES)                                ���
�������������������������������������������������������������������������Ĵ��
��� Revis�o  � TI0607 - Almir Bandina                   � Data � 11.08.99 ���
���          � Conforme Sr. Manoel (Contador) n�o calcu-�      �          ���
���          � lar o ICMS-ST quando o cliente for pessoa�      �          ���
���          � F�sica.                                  �      �          ���
��� Revis�o  � TI0607 - Almir Bandina                   � Data � 13.09.99 ���
���          � Compatibiliza��o para utiliza��o no gati-�      �          ���
���          � lho referente a nota fiscal de entrada.  �      �          ���
��� Revis�o  � TI0607 - Almir Bandina                   � Data � 20.09.99 ���
���          � N�o verifica o tipo de movimenta��o      �      �          ���
���          � Se valor retido menor que zero for�a va- �      �          ���
���          � lor zero (Caso Kronembier).              �      �          ���
��� Revis�o  � TI0607 - Almir Bandina                   � Data � 24.11.99 ���
���          � Soma o valor do frete na Base de Calculo �      �          ���
���          � do ICMS Solid�rio conforme Sr. Jos� de   �      �          ���
���          � Paula.                                   �      �          ���
��� Revis�o  � TI0607 - Almir Bandina                   � Data � 25.11.99 ���
���          � Para c�lculo do ICMS substitui��o SEMPRE �      �          ���
���          � usar a fun�ao ALIQICMS.                  �      �          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function Ds460SOLI(nValIcm,nQtdItem,nTotal,nMargem)        // incluido pelo assistente de conversao do AP5 IDE em 05/10/00

//���������������������������������������������������������������������Ŀ
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//�����������������������������������������������������������������������

Local cAlias
Local nIndex,nRegis,nBsIcms,nVlIcms,nValorIpi, nFrete, nAliqSolid, nAliqIcm := 0
Local aRet := {}

//������������������������������������������������������Ŀ
//� Se o ICMS nao for calculado, nao ha calculo de ICMSST�
//��������������������������������������������������������
If SF4->F4_ICM == "S"

	cAlias  := Alias()
	nIndex  := IndexOrd()
	nRegis  := Recno()
	nBsIcms := 0
	nVlIcms := 0

	//������������������������������������������������������Ŀ
	//� Inicializa vari�vel que s� � inicializada pelo ponto �
	//� de entrada M460IPI que � executado somente quando o  �
	//� TES calcular IPI.                                    �
	//��������������������������������������������������������
	If SF4->F4_IPI == "N"
		nValorIpi   := 0
	EndIf

	If SC5->C5_TIPOCLI == "F"
		aRet := {}
		AADD(aRet,0)
		AADD(aRet,0)
	Else
		If !Empty(SB1->B1_VLR_ICM)
			//������������������������������������������������������Ŀ
			//� Calcula ICMS-ST especificamente para produtos com a  �
			//� caracteristica verificada abaixo                     �
			//��������������������������������������������������������
			If SC6->C6_PRCVEN <= SB1->B1_VLR_ICM
				nAliqIcm := AliqIcms(SC5->C5_TIPO,"S",SC5->C5_TIPOCLI)
				nBsIcms  := ROUND(ROUND(SB1->B1_VLR_ICM/SB1->B1_QTDUPAD,6)*nQtdItem,2)
				nVlIcms  := (nBsIcms * (nAliqIcm/100))  - nValIcm

				//������������������������������������������������������Ŀ
				//� For�a valor zero - Caso Kronembier                   �
				//��������������������������������������������������������
				If nBsIcms < 0 .or. nVlIcms < 0
					nBsIcms := 0
					nVlIcms := 0
				EndIf
				aRet     := {}
				AADD(aRet,nBsIcms)
				AADD(aRet,nVlIcms)
			Endif
		Else
			//������������������������������������������������������Ŀ
			//� Calcula ICMS-ST de forma semelhante a original, po-  �
			//� rem arredondando (solucao para paralelo com o NOVA)  �
			//��������������������������������������������������������
			If nMargem > 0.00 .And. SC5->C5_TIPOCLI == "S"
				nBsIcms := Round(SC6->C6_PRCVEN * nQtdItem,2) + If(SF4->F4_INCIDE=="S",0,nValorIpi) + nFrete
				nBsIcms := Round(nBsIcms * (1+nMargem/100),2)
				nAliqSolid := AliqIcms(SC5->C5_TIPO,"S",SC5->C5_TIPOCLI,"S")/100
				nVlIcms    := Max(Round((nBsIcms*nAliqSolid)-nValIcm,2),0)
				aRet     := {}
				AADD(aRet,nBsIcms)
				AADD(aRet,nVlIcms)
			Endif         
			
		EndIf
	EndIf


	//������������������������������������������������������Ŀ
	//� Retorna o conteudo gerado nas rotinas acima          �
	//��������������������������������������������������������
	dbSelectArea(cAlias)
	dbSetOrder(nIndex)
	dbGoto(nRegis)
EndIf       

Return(aRet)

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � DlTesInt   � Autor � Marcos Cesar        � Data � 23/07/1999 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Pesquisa o Arquivo DA2 (Cadastro De/Para de TES) p/ obter o  ���
���          � Codigo do TES.                                               ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � ExpC1 := DlaTesInt(ExpC2,ExpC3,ExpC4,ExpC5)                  ���
���������������������������������������������������������������������������Ĵ��
���Parametros� ExpC2 : Modelo de Venda                                      ���
���          � ExpC3 : Tipo do Cliente                                      ���
���          � ExpC4 : Almoxarifado                                         ���
���          � ExpC5 : Codigo do Produto                                    ���
���������������������������������������������������������������������������Ĵ��
���Retorno   � ExpC1 : Codigo do TES                                        ���
���������������������������������������������������������������������������Ĵ��
���Uso       � Generico                                                     ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function DlaTesInt(cModelo, cTipoCli, cLocal, cCodProduto)

Local cTes := ""

//�����������������������������������������������������������������Ŀ
//� Funcao utilizada para verificar a ultima versao dos fontes      �
//� SIGACUS.PRW, SIGACUSA.PRX e SIGACUSB.PRX, aplicados no rpo do   |
//| cliente, assim verificando a necessidade de uma atualizacao     |
//| nestes fontes. NAO REMOVER !!!							        �
//�������������������������������������������������������������������
IF !(FindFunction("SIGACUS_V") .and. SIGACUS_V() >= 20050512)
    Final("Atualizar SIGACUS.PRW !!!")
Endif
IF !(FindFunction("SIGACUSA_V") .and. SIGACUSA_V() >= 20050512)
    Final("Atualizar SIGACUSA.PRX !!!")
Endif
IF !(FindFunction("SIGACUSB_V") .and. SIGACUSB_V() >= 20050512)
    Final("Atualizar SIGACUSB.PRX !!!")
Endif

//��������������������������������������������������������������Ŀ
//� Primeiro Seek no Arquivo DA2 (Cadastro De/Para de TES).      �
//� Chave : Filial + Tipo Venda + Tipo Cliente + Local + Produto �
//����������������������������������������������������������������
dbSelectArea("DA2")
dbSetOrder(1)
If !dbSeek(xFilial() + cModelo + cTipoCli + cLocal + cCodProduto)
	//��������������������������������������������������������������Ŀ
	//� Segundo Seek no Arquivo DA2 (Cadastro De/Para de TES).       �
	//� Chave : Filial + Tipo Venda + Tipo Cliente + Local           �
	//����������������������������������������������������������������
	
	dbSelectArea("DA2")
	dbSetOrder(1)
	If !dbSeek(xFilial() + cModelo + cTipoCli + cLocal + Space(15))
	
		//��������������������������������������������������������������Ŀ
		//� Terceiro Seek no Arquivo DA2 (Cadastro De/Para de TES).      �
		//� Chave : Filial + Tipo Venda + Tipo Cliente + Local           �
		//����������������������������������������������������������������
		dbSelectArea("DA2")
		dbSetOrder(1)
		If !dbSeek(xFilial() + cModelo + cTipoCli + cLocal + Space(15))

			//��������������������������������������������������������������Ŀ
			//� Quarto Seek no Arquivo DA2 (Cadastro De/Para de TES).        �
			//� Chave : Filial + Tipo Venda + Tipo Cliente                   �
			//����������������������������������������������������������������
			dbSelectArea("DA2")
			dbSetOrder(1)
			dbSeek(xFilial() + cModelo + cTipoCli + Space(2) + Space(15))
			
		EndIf
	EndIf
EndIf

//��������������������������������������������������������������Ŀ
//� Verifica qual TES sera usado.                                �
//����������������������������������������������������������������
cTes := Iif(DA2->DA2_TES == "P  ", RetFldProd(SB1->B1_COD,"B1_TS"), DA2->DA2_TES)

//��������������������������������������������������������������Ŀ
//� Pesquisa o Arquivo SF4 (Tipos de Entrada e Saida).           �
//����������������������������������������������������������������
dbSelectArea("SF4")
dbSetOrder(1)
dbSeek(xFilial() + cTes)

If !Found()
	cTes := Space(3)
EndIf

Return( cTes )
/*                           	
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �DSCapArm  �Autor  �Henry Fila          � Data �  06/26/00   ���
�������������������������������������������������������������������������͹��
���Desc.     � REtorna a capacidade de armazenamento do produto           ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Distribuicao                                               ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function DlaCapArm(cProduto)

Local nCapac := 0

SB1->(dbSetOrder(1))
If SB1->(dbSeek(xFilial("SB1")+cProduto))
	SB5->(dbSetOrder(1))
	If SB5->(dbSeek(xFilial("SB5")+cProduto))
		nCapac := (SB5->B5_ALTURLC * SB5->B5_LARGLC * SB5->B5_COMPRLC)
	Endif
Endif

Return(nCapac)

