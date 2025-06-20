#Include "PROTHEUS.CH" 
                  
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GNRESP    �Autor  �Natalia Antonucci   � Data �  13/06/12   ���
�������������������������������������������������������������������������͹��
���Desc.     �Preparacao do meio magnetico GNRESP - A SEFAZ esta colocando���
���          �a disposi��o do contribuinte, contabilista e popula��o em   ���
���          �geral o sistema de Gera��o de Guias de Recolhimento em lote.���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/                                

Function GnreSP(lAutomato,aWizard)

Local	lEnd		:=	.F.
Local	cFileDest	:=	"GNRESP.XML"
Local	cNomWiz		:=	"GNRESP"
Local 	lVerpesssen := Iif(FindFunction("Verpesssen"),Verpesssen(),.T.)
Local	nNaoProc	:= 	0
Local   cMensagem   :=  ""
Local	aNaoProc	:=  {}
Local	lArqGerado  :=  .F.
Local 	cNomeCfp 	:=  cNomWiz
Default	aWizard		:=	{}
Default lAutomato	:= .f.
If lVerpesssen .And. Wizard(cNomWiz)

	//���������������������������������������������������������������
	//� Valida��es realizadas na Wizard antes da gera��o do arquivo  �
	//���������������������������������������������������������������
	If !lAutomato
		If (!xMagLeWiz(cNomeCfp, @aWizard, .T.))
			Return	//Se por algum motivo a leitura do CFP falhar aborto a rotina.
		Endif
		If  SToD(aWizard[1][1]) > SToD(aWizard[1][2])
			cMensagem += iif( empty(cMensagem),"", chr(13)+chr(10)) + "- Data Inicial superior a Data Final !" 
		Endif
		If  empty( Alltrim(aWizard[1][3]) ) .or. !ExistDir( Alltrim(aWizard[1][3]) )
			cMensagem += iif( empty(cMensagem),"", chr(13)+chr(10)) + "- Informe um Diret�rio V�lido !" 
		Endif
		If empty( Alltrim(aWizard[1][4]) )
			cMensagem += iif( empty(cMensagem),"", chr(13)+chr(10)) + "- Informe um nome para o arquivo !" 
		EndIf

		if !empty( cMensagem )
			MsgStop( cMensagem , "Aten��o" )
			Return
		endif

	Endif

	Processa({||PrGNRESP(@lEnd, aWizard, @cFileDest, @aNaoProc, @lArqGerado )})
	
	cMensagem := 'Arquivo: "'  + cFileDest + '..."' + iif( lArqGerado, " gerado com sucesso!", " n�o foi gerado ") + Chr(13)+Chr(10)+Chr(13)+Chr(10) 

	If 	len( aNaoProc ) >= 1

		aSort( aNaoProc )
		cMensagem += "Aten��o: " + iif( len(aNaoProc) == 1, "Guias de recolhimento cadastrada com o c�digo ", "Guias de recolhimento cadastradas com os c�digos ")

		For nNaoProc:= 1 to len( aNaoProc )
			cMensagem += iif( nNaoProc == 1, "",", ") + aNaoProc[nNaoProc]
		Next

		cMensagem += " n�o tem o seu leiaute atendido pelo Backoffice Protheus Fiscal, por tratar de normas para segmento especifico."
	Endif		

	If !lAutomato
		If lArqGerado 
			MsgInfo( cMensagem ) //"Arquivo "###" gerado com sucesso!"
		Else
			MsgAlert( cMensagem ) //"N�o foi poss�vel gerar o arquivo!"
		EndIf
	Endif

EndIf
	
Return()                                                                                                           

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PrGNRESP  �Autor  �Natalia Antonucci   � Data �  13/06/12   ���
�������������������������������������������������������������������������͹��
���Desc.     �Funcao principal de processamento do arq. magnetico GNRESP  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function PrGNRESP(lEnd,aWizard,cFileDest,aNaoProc,lArqGerado)

Local cFilDe   	:= ""
Local cFilAte  	:= "" 
Local cDir     	:= ""
Local cAliasSF6	:= "SF6"                                       
Local cIndex   	:= ""
Local cXml     	:= ""
Local cCorpo 	:= ""
Local cData 	:= ""
Local cDaRef 	:= ""
Local cInsc 	:= ""
Local cCodR 	:= ""
Local cCodRec	:= ""
Local cMVSUBTRIB:= IIf(FindFunction("GETSUBTRIB"), GetSubTrib(), SuperGetMv("MV_SUBTRIB")) 
Local cCODRECAP := GetNewPar("MV_RECEAPU","") 
Local dDataDe  	:= ctod("//")
Local dDataAte 	:= ctod("//") 
Local aFieldDt 	:= {}                                   
Local nCount   	:= 0 
Local nLote    	:= 0
Local nX	   	:= 0 
Local lGerou 	:= .F.
Local lQuery    := .F.
Local lRemet    := .T.
Local lArqTemp  := .F.
Local cPag  	:= ""
Local cCnpjCPF	:= ""
Local cNomeCont	:= ""
Local cEnd		:= ""
Local cMun		:= ""
Local cUF		:= ""
Local cTel		:= ""
Local cIE		:= ""
Local cCEP 		:= ""


dDataDe	 :=	SToD(aWizard[1][1])
dDataAte :=	SToD(aWizard[1][2])
cDir     := Alltrim(aWizard[1][3])
cFileDest:= Alltrim(aWizard[1][4])
cFilDe   := Alltrim(aWizard[1][5]) 
cFilAte  := Alltrim(aWizard[1][6])
cPag  	 := Alltrim(aWizard[1][7])

lRemet   := cPag == "Remetente"

//���������������Ŀ
//�Trata Diretorio�
//�����������������
If (SubStr (cDir, Len (cDir), 1)<>"\")
	cDir	+=	"\"
EndIf

                                                                        
//��������������������������������
//�Definicao da ordem das tabelas�
//��������������������������������

dbSelectArea("SA1")	//Cadastro do Cliente
SA1->(dbSetOrder(1))
dbSelectArea("SF6")	//GNRE
SF6->(dbSetOrder(1))                                

If Empty(cFilDe) .And. Empty(cFilAte)
	cFilDe  := cFilAnt
	cFilAte := cFilAnt
EndIf

DbSelectArea ("SM0")
SM0->(DbGoTop ())
SM0->(DbSeek (cEmpAnt+cFilDe, .T.))	//Pego a filial mais proxima 
Do While !SM0->(Eof()) .And. cEmpAnt==SM0->M0_CODIGO .And. FWGETCODFILIAL<=cFilAte

	cFilAnt := FWGETCODFILIAL

 	DbSelectArea("SF6")
	SF6->(DbSetOrder(1))

	lQuery    := .T.
	
	aAdd(aFieldDt,"F6_DTVENC")
	aAdd(aFieldDt,"F6_DTPAGTO")
	
	If SF6->(FieldPos("F6_PROCESS")) > 0
		cAliasSF6 := GetNextAlias()

		BeginSql Alias cAliasSF6    	
			SELECT SF6.F6_FILIAL, SF6.F6_DTARREC, SF6.F6_MESREF, SF6.F6_EST, SF6.F6_CODREC, SF6.F6_TIPOIMP, SF6.F6_VALOR, SF6.F6_ANOREF, 
			SF6.F6_DOC, SF6.F6_NUMCONV, SF6.F6_CLIFOR, SF6.F6_LOJA, SF6.F6_NUMERO, SF6.F6_DTVENC, SF6.F6_DTPAGTO, SF6.F6_OPERNF, 
			SF6.F6_SERIE, SF6.F6_MULTA, SF6.F6_JUROS, SF6.F6_ATMON, SF6.F6_INF, SF6.F6_PROCESS, SF6.R_E_C_N_O_, 
			SA1.A1_CGC, SA1.A1_NOME, SA1.A1_END, SA1.A1_MUN, SA1.A1_EST, SA1.A1_TEL, SA1.A1_INSCR, SA1.A1_CEP ,SA1.A1_TIPO
			FROM 
				%Table:SF6% SF6
				INNER JOIN  %Table:SA1% SA1 ON %xFilial:SA1%=SA1.A1_FILIAL AND SF6.F6_CLIFOR=SA1.A1_COD AND SF6.F6_LOJA=SA1.A1_LOJA AND SA1.D_E_L_E_T_ = ' '
			WHERE 
				SF6.F6_FILIAL=%xFilial:SF6% AND 
				SF6.F6_DTARREC>=%Exp:dDataDe% AND 
				SF6.F6_DTARREC<=%Exp:dDataAte% AND
				SF6.F6_PROCESS <> '1' AND
				(SF6.F6_TIPOIMP = '3' OR SF6.F6_TIPOIMP = 'B')  AND
				SF6.F6_EST = 'SP' AND
				SF6.%NotDel%
			ORDER BY %Order:SF6%					               			
		EndSql 
		For nX := 1 To Len(aFieldDt)
			TcSetField(cAliasSF6,aFieldDt[nX],"D",8,0)
		Next nX
			
		DbSelectArea (cAliasSF6)
		(cAliasSF6)->(DbGoTop())
		ProcRegua ((cAliasSF6)->(RecCount ()))
		nLote := 1
		While !(cAliasSF6)->(Eof ()) 
			cNomeArq := cFileDest + '_' + AllTrim(cFilAnt) + '_'
			lArqTemp := .F.
			nCount   := 0 
			cXml	 :=	""
			cXml     := GravaCab(nLote,@cNomeArq)
			While !(cAliasSF6)->(Eof()) .and. nCount < 50
				lGerou   := .F.	

				cData  := StrZero (Day ((cAliasSF6)->F6_DTVENC), 2)+StrZero (Month ((cAliasSF6)->F6_DTVENC), 2)+StrZero (Year ((cAliasSF6)->F6_DTVENC), 4)
				cDaRef := StrZero (Month (dDataDe), 2)+StrZero (Year (dDataDe), 4)
				cInsc  := IESubTrib((cAliasSF6)->F6_EST)
				cCodRec:= Alltrim((cAliasSF6)->F6_CODREC)
				cCodR  := IIf(!Empty(cCODRECAP), cCODRECAP, cCodRec ) 

				//Verifica se h� IE em S�o Paulo e se o c�digo da receita � por APURA��O, ou, Se c�digo da receita por opera��o e "Dados do pagador quando por opera��o" est� preenchido com remetente. Se
				//obedecer uma destas regras os dados da Guia ser�o preenchidos com o SM0(dados do emissor da guia). 
				If ("SP"$cMVSUBTRIB .and. cCodR=="100048" .and. cCodRec <> "100099") .OR. (lRemet .and. cCodRec $ "100099/100080") .OR. (cCodRec $ "100080"   .AND.  (cAliasSF6)->F6_OPERNF =='1') .OR. cCodRec=='100102'
					cCnpjCPF	:= Alltrim(SM0->M0_CGC)
					cNomeCont	:= Alltrim(SM0->M0_NOME)
					cEnd		:= Alltrim(SM0->M0_ENDENT)
					cMun		:= Alltrim(SM0->M0_CODMUN)
					cUF			:= Alltrim(SM0->M0_ESTENT)	
					cTel		:= Alltrim(SM0->M0_TEL)
					cIE			:= cInsc
					cCEP 		:= Alltrim(SM0->M0_CEPENT)
					lGerou:= .T.
				//Se n�o passar pela condi��o acima s� pode ser uma opera��o onde o destinat�rio deve ser preenchido na guia como pagador.		
				Elseif ((cCodRec $ "100099/100080") .and.  (cAliasSF6)->F6_OPERNF =='2') 
					cCnpjCPF	:= Alltrim((cAliasSF6)->A1_CGC)	
					cNomeCont	:= Alltrim((cAliasSF6)->A1_NOME)
					cEnd		:= Alltrim((cAliasSF6)->A1_END)
					cMun		:= Alltrim((cAliasSF6)->A1_MUN)
					cUF			:= Alltrim((cAliasSF6)->A1_EST)
					cTel		:= Alltrim((cAliasSF6)->A1_TEL)
					cIE			:= Alltrim((cAliasSF6)->A1_INSCR)
					cCEP 		:= Alltrim((cAliasSF6)->A1_CEP)
					lGerou:= .T. 
				Else
					If 	aScan( aNaoProc, cCodRec ) == 0
						aAdd( aNaoProc, cCodRec )
					Endif
				EndIf
				if lGerou // se falso n�o cria as tags.
					cCorpo := '<dados Vias='+'"3" ' + 'CodigoReceita="' + cCodRec + '" CnpjCpf="'+ cCnpjCPF + '" NomeContribuinte="'+ cNomeCont +;
					'" Endereco="'+ cEnd + '" Municipio="'+ cMun + '" Uf="'+ cUF + '" Telefone="'+ cTel + '" ValorOriginal="'+ Alltrim(StrTran(str((cAliasSF6)->F6_VALOR),".",",")) +;
					'" Juros="'+Alltrim(StrTran(str((cAliasSF6)->F6_JUROS),".",",")) + '" Observacoes="'+Alltrim((cAliasSF6)->F6_INF) + '" DataVencimento="'+ cData + '" Nf="'+Alltrim((cAliasSF6)->F6_DOC) +;
					'" Referencia="'+ cDaRef + '" Multa="'+ Alltrim(StrTran(str((cAliasSF6)->F6_MULTA),".",",")) + '" ConvenioProtocolo="'+Alltrim((cAliasSF6)->F6_NUMCONV) +;
					'" InscricaoEstadual="'+ cIE + '" Cep="'+ cCEP + '" DocumentoDeOrigem="'+Alltrim((cAliasSF6)->F6_DOC) +'"/>'

					cXml += cCorpo                        	         
					cXml += Chr(13)+Chr(10)
			
					lArqTemp := .t.
	
					SF6->(dbGoTo( (cAliasSF6)->R_E_C_N_O_ ))
					RecLock("SF6",.F.)
					SF6->F6_PROCESS := "1"
					SF6->(MsUnlock())
				EndIf

				(cAliasSF6)->(DbSkip())
				nCount++ 
			EndDo
			If lArqTemp
				lArqGerado := .t.
				cXml += "</Guia>"                            		
				MemoWrite(cDir+cNomeArq,cXml)
				nLote++ 
			Endif   	  	 	     	 		                    	
		EndDo

		DbSelectArea(cAliasSF6)
		(cAliasSF6)->(DbCloseArea())
	EndIf
	
	SM0->(DbSkip())
EndDo

If !lQuery    
	RetIndex("SF6")
	dbClearFilter()
	Ferase(cIndex+OrdBagExt()) 
EndIf

Return (.T.) 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GravaCab �Autor  �Natalia Antonucci   � Data �  13/06/12    ���
�������������������������������������������������������������������������͹��
���Desc.     � Monta o Cabecalho do XML                                   ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function  GravaCab(nLote,cNomeArq)
Local cMontXml := ""

cNomeArq := cNomeArq + ALLTRIM(Str(nLote)) + ".XML"
 
	cMontXml += "<Guia>"  

Return(cMontXml)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Wizard   �Autor  �Natalia Antonucci   � Data �  13/06/12   ���
�������������������������������������������������������������������������͹��
���Desc.     � Monta o Wizard da rotina.                                  ���
���          � Retorna .T. se finalizado com sucesso                      ���
���          � Retorna .F. se foi cancelado                               ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Wizard(cNomWiz)
Local	aTxtApre	:=	{}
Local	aPaineis	:=	{}
Local	cTitObj1	:=	""
Local	cTitObj2	:=	""
Local	lRet		:=	.T.

//��������Ŀ
//�Painel 0�
//����������
aAdd (aTxtApre, "Par�metros necess�rios.")
aAdd (aTxtApre, "")
aAdd (aTxtApre, "Preencha corretamente as informa��es solicitadas.")
aAdd (aTxtApre, "Informa��es necess�rias para a gera��o do meio-magn�tico GNRESP.")

//��������Ŀ
//�Painel 1�
//����������
aAdd (aPaineis, {})
nPos	:=	Len (aPaineis)
aAdd (aPaineis[nPos], "Preencha corretamente as informa��es solicitadas.")
aAdd (aPaineis[nPos], "Par�metros para Gera��o")
aAdd (aPaineis[nPos], {})
//
cTitObj1	:=	"Data de";								   	cTitObj2	:=	"Data at�"
aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});				aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})
//
aAdd (aPaineis[nPos][3], {2,,,3,,,,});						aAdd (aPaineis[nPos][3], {2,,,3,,,,}) 
//
aAdd (aPaineis[nPos][3], {0,"",,,,,,});						aAdd (aPaineis[nPos][3], {0,"",,,,,,})
//
cTitObj1	:=	"Diret�rio do Arquivo Destino";				cTitObj2	:=	"Nome do Arquivo Destino"
aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});				aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})
//
cTitObj1	:=	Replicate ("X", 50);						cTitObj2	:=	Replicate ("X", 20)
aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,50});			aAdd (aPaineis[nPos][3], {2,,cTitObj2,1,,,,20})
//
aAdd (aPaineis[nPos][3], {0,"",,,,,,});						aAdd (aPaineis[nPos][3], {0,"",,,,,,})
//
cTitObj1	:=	"Filial de"; 								cTitObj2	:=	"Filial ate"
aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});				aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})
//
cTitObj1	:=	Replicate ("X", 8);							cTitObj2	:=	Replicate ("X", 8)
aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,8});				aAdd (aPaineis[nPos][3], {2,,cTitObj2,1,,,,8})
//
aAdd (aPaineis[nPos][3], {0,"",,,,,,});						aAdd (aPaineis[nPos][3], {0,"",,,,,,})
//
cTitObj1	:=	"Dados do pagador quando por opera��o"					
aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});				aAdd (aPaineis[nPos][3], {1, "",,,,,,})
//
aAdd (aPaineis[nPos][3], {3,,,,,{"Remetente", "Destinat�rio"},,});

lRet	:=	xMagWizard (aTxtApre, aPaineis, cNomWiz)

Return (lRet)
