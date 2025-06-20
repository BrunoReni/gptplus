#INCLUDE "PROTHEUS.CH"
#INCLUDE "FISA060.CH"

/*/
����������������������������������������������������������������������������
����������������������������������������������������������������������������
������������������������������������������������������������������������Ŀ��
���Fun��o    �FISA060  � Autor � Marcio Nunes          � Data �05/03/2013���
������������������������������������������������������������������������Ĵ��
���Descri��o �Importacao de arquivo TXT retornado ARBA                   ���
���          �Embargo de Derechos de Cr�dito                             ���
������������������������������������������������������������������������Ĵ��
���Sintaxe   �FISA060()                                                  ���
������������������������������������������������������������������������Ĵ��
���Parametros�                                                           ���
������������������������������������������������������������������������Ĵ��
���Retorno   � .T.                                                       ���
������������������������������������������������������������������������Ĵ��
���Uso       � Argentina                                                 ���
������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.            ���
������������������������������������������������������������������������Ĵ��
���Programador � Data     � BOPS     � Motivo da Alteracao               ���
������������������������������������������������������������������������Ĵ��
���Alf. Medrano�26/12/16  �SERINN001-539�creaci�n de tablas temporales se���
���            �          �          �asigna FWTemporaryTable y se inicia���
���            �          �          �variable nStart=1 en func. GRTPARBA���
���Alf. Medrano�12/01/17  �SERINN001-539�Merge Main vs 12.1.15           ���
�������������������������������������������������������������������������ٱ�
����������������������������������������������������������������������������
����������������������������������������������������������������������������
/*/
Function FISA060()

Local aArqTmp	:= {}	// Arquivo temporario para importacao
Local cAliasTMP	:= ""
Local cTitulo	:= ""
Local cErro		:= ""
Local cSolucao	:= ""
Local lCarga 	:= .F.
Local lRet	 	:= .T.
private oTmpTable

If MostraWiz()	            

	//����������������������������������������������������������������������Ŀ
	//�Carrega no arquivo temporario com as informacoes do arquivo de retorno�
	//������������������������������������������������������������������������
	Processa({|| lRet := GRTPARBA(@aArqTmp)})

	cAliasTMP := aArqTmp[02]   
	
	If lRet

		//���������������������������������������Ŀ
		//�Processo de valiadacao para Fornecedor �
		//�����������������������������������������
		Processa({|| ProcFor("SA2")})

	EndIf
		
	//�������������������������������������Ŀ
	//�Excluindo o arquivo temporario criado�
	//���������������������������������������
	
	If oTmpTable <> Nil  
		oTmpTable:Delete() 	
		oTmpTable := Nil 
	Endif

Endif

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �MostraWiz � Autor �Marcio Nunes      � Data �    05/03/2013 ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Tela Wizard inicial pata selecao do arquivo a ser importado ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �MostraWiz()                                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Especifico - FISA060                                       ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function MostraWiz()

//������������������������Ŀ
//�Declaracao das variaveis�
//��������������������������
Local aTxtPre 	:= {}
Local aPaineis 	:= {}
Local cTitObj1	:= ""                
Local cMask		:= Replicate("X",245)
Local nPos		:= 0
Local lRet		:= .T.

//�����������������������������������������Ŀ
//�Monta wizard com as perguntas necessarias�
//�������������������������������������������
aAdd(aTxtPre,STR0002) 			//"Importa��o do arquivo Padron de Embargo ARPA"
aAdd(aTxtPre,STR0001) 			//"Aten��o"
aAdd(aTxtPre,STR0003) 			//"Preencha corretamente as informa��es solicitadas."
aAdd(aTxtPre,Alltrim(STR0004))	// "Esta rotina ir� importar o arquivo padr�o de Embargos de ARBA."

//����������������������������������������Ŀ
//�Painel 1 - Assistente de parametriza��o �
//������������������������������������������
aAdd(aPaineis,{})
nPos :=	Len(aPaineis)
aAdd(aPaineis[nPos],STR0005) //"Assistente de parametriza��o" 
aAdd(aPaineis[nPos],STR0006) //"Informa��es sobre o arquivo de retorno: "
aAdd(aPaineis[nPos],{})

cTitObj1 :=	STR0007 //"Arquivo a ser importado: "
aAdd(aPaineis[nPos][3],{0,"",,,,,,})
aAdd(aPaineis[nPos][3],{0,"",,,,,,})
aAdd(aPaineis[nPos][3],{0,"",,,,,,})
aAdd(aPaineis[nPos][3],{0,"",,,,,,})
aAdd(aPaineis[nPos][3],{0,"",,,,,,})
aAdd(aPaineis[nPos][3],{0,"",,,,,,})
aAdd(aPaineis[nPos][3],{0,"",,,,,,})
aAdd(aPaineis[nPos][3],{0,"",,,,,,})
aAdd(aPaineis[nPos][3],{0,"",,,,,,})
aAdd(aPaineis[nPos][3],{0,"",,,,,,})
aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
aAdd(aPaineis[nPos][3],{2,"",cMask,1,,,,245,,.T.})
aAdd(aPaineis[nPos][3],{0,"",,,,,,})
aAdd(aPaineis[nPos][3],{0,"",,,,,,})
aAdd(aPaineis[nPos][3],{0,"",,,,,,})
aAdd(aPaineis[nPos][3],{0,"",,,,,,})

lRet :=	xMagWizard(aTxtPre,aPaineis,"MostraWiz")
	
Return(lRet)   

/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������Ŀ��
���Fun�ao    �GRTPARBA     � Autor � Marcio Nunes            � Data �05/03/2013���
������������������������������������������������������������������������������Ĵ��
���Descri�ao �Gera arquivo temporarioa a partir do TXT importado               ���
������������������������������������������������������������������������������Ĵ��
���Sintaxe   �GRTPARBA(ExpC1)                                                  ���
������������������������������������������������������������������������������Ĵ��
���Parametros�ExpC1 = Nome do arquivo temporario                               ���
������������������������������������������������������������������������������Ĵ��
���Uso       �                                                                 ���
�������������������������������������������������������������������������������ٱ�
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/          
Static Function GRTPARBA(aArqTmp)
Local aWizard   := {}
Local aArqPro   := {}
Local lRet      := xMagLeWiz("MostraWiz",@aWizard,.T.)
Local cArqProc  := Alltrim(aWizard[01][01])
Local cTitulo   := STR0008		//"Problemas na Importa��o de Arquivo"
Local cErro	    := ""
Local cSolucao  := ""
Local cLinha    := ""
Local lArqValido:= .T. 
Local nHandle   := 0 
Local nTam      := 0 
Local cSearch 	:= "-"
Local cReplace	:= ""
Local nStart	:= 1
Local nCount	:= 2

//���������������������������������������������
//�Cria o arquivo temporario para a importacao�
//���������������������������������������������
AADD(aArqPRO,{"DATAP"	,"D",08,0})
AADD(aArqPRO,{"CGC"		,"C",11,0})
AADD(aArqPRO,{"VALEMB"	,"C",13,0})
AADD(aArqPRO,{"RAZAO"	,"C",120,0})

cArqTmp := CriaTrab(nil,.f.)

aArqTmp := {cArqTmp,"TMP"}
oTmpTable:= FWTemporaryTable():New("TMP") 
oTmpTable:SetFields( aArqPRO ) 
oTmpTable:AddIndex("T1ORD1", {'CGC'})
//Creacion de la tabla
oTmpTable:Create()

//���������������������������������������������������������
//�Atualiza arquivo temporario com dados do TXT importado �
//���������������������������������������������������������
If File(cArqProc) .And. lRet
	nHandle	:= FOpen(cArqProc)
   
	If nHandle > 0 
		nTam := FSeek(nHandle,0,2)  
		FSeek(nHandle,0,0)
		FT_FUse(cArqProc)
		FT_FGotop()
	Else
		lArqValido := .F.	
		cErro	   := STR0009 + cArqProc	//"N�o foi poss�vel efetuar a abertura do arquivo: "
		cSolucao   := STR0010 				//"Verifique se foi informado o arquivo correto para importa��o"
	EndIf

	If lArqValido 
		ProcRegua(nTam)

		While (!FT_FEof()) 		
			IncProc()
			
   			cLinha   := FT_FREADLN()	

        	RecLock("TMP",.T.)

			// Retira h�fem do CUIT caso necessario
			cLinha := StrTran(cLinha, cSearch, cReplace, nStart, nCount)
			
            TMP->DATAP		:= CtoD(SubStr(cLinha,7,2)+"/"+SubStr(cLinha,5,2)+"/"+SubStr(cLinha,1,4))
  	  	   	TMP->CGC		:= SubStr(cLinha,9,11)
		   	TMP->VALEMB  	:= SubStr(cLinha,20,13)
            TMP->RAZAO		:= SubStr(cLinha,33,120)			
			FT_FSkip()  

		Enddo 
	Endif	

	FT_FUse()
	FClose(nHandle)

	If Empty(cErro) .and. TMP->(LastRec())==0     
		cErro		:= STR0011	//"A importa��o n�o foi realizada por n�o existirem informa��es no arquivo texto informado."
		cSolucao	:= STR0012	//"Verifique se foi informado o arquivo correto para importa��o"
	Endif
Else
	cErro	 := STR0013+CHR(13)+cArqProc	//"O arquivo informado para importa��o n�o foi encontrado: "
	cSolucao := STR0014 		   			//"Informe o diret�rio e o nome do arquivo corretamente e processe a rotina novamente."
EndIf
	 
If !Empty(cErro)
	xMagHelpFis(cTitulo,cErro,cSolucao)
	lRet := .F.
Endif

Return(lRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �ProcFor   � Autor �Marcio Nunes           � Data �05/03/2003���
�������������������������������������������������������������������������Ĵ��
���Descricao �Processa os arquivos para verificar se o fornecedor         ���
���          �consta no arquivo Importado                                 ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �ProcFor(ExpC1)                                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpC1 = Alias da tabela a ser processada(SA2)               ���
�������������������������������������������������������������������������Ĵ��
���Uso       �Especifico - FISA060                                        ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ProcFor(cAlias)
Local aArea     := GetArea()	// Salva area atual para posterior restauracao
Local lExistSFH := .F.			// Determina se o Fornecedor ja existem na tabela SFH

DEFAULT cAlias := "SA2"

dbSelectArea(cAlias)
dbGoTop()
  
ProcRegua(RecCount())

While !Eof()

	IncProc(STR0015)	//"Processando Fornecedor"	

	//���������������������������������������������������������������
	//�Verifica se o Fornecedor consta no arquivo importado da ARPA �
	//���������������������������������������������������������������
	If TMP->(dbSeek(SA2->A2_CGC))
		lExistSFH := PesqSFH(1,(cAlias)->A2_COD+(cAlias)->A2_LOJA+"IBRBA",cAlias)
	EndIf 

   	dbSkip()
	
EndDo

RestArea(aArea)

Return                                                

/*
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
�����������������������������������������������������������������������������Ŀ��
���Fun�ao    �PesqSFH     � Autor � Marcio Nunes            � Data �05/03/2013���
�����������������������������������������������������������������������������Ĵ��
���Descri�ao �Pesquisa existencia de registros na tabela SFH referente ao     ���
���          �fornecedor cadastrado.                                          ���
�����������������������������������������������������������������������������Ĵ��
���Sintaxe   �PesqSFH(ExpN1,ExpC1,ExpC3)                                      ���
�����������������������������������������������������������������������������Ĵ��
���Parametros�ExpN1 = Ordem do indice da tabela SFH                           ���
���          �ExpC1 = Chave de pesquisa para a tabela SFH                     ���
���          �ExpC3 = Alias da tabela a ser processada(SA2)                   ���
�����������������������������������������������������������������������������Ĵ��
���Uso       �Especifico - FISA060                                            ���
������������������������������������������������������������������������������ٱ�
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
*/          
Static Function PesqSFH(nOrd,cKeySFH,cAlias)
Local aArea    	 := GetArea()						// Salva area atual para posterior restauracao
Local IEncontro:=.F.
Local ICria:=.F.

dbSelectArea("SFH")
DbSetOrder(nOrd) 

//����������������������������������������������������������
//�Verifica se existe registro do Fornecedor na tabela SFH �
//����������������������������������������������������������      


//1. Acceder a la tabla "SFH" para el proveedor indicado, donde FH_IMPOSTO="IBR", FH_ZONAFIS="BA", FH_SITUACA="4" 
//   a.	Si encuentra registro y FH_INIVIGE=>cib_fecha No actualiza y contin�a con la lectura del pr�ximo registro "cib"
//   b.	Si encuentra registro y FH_INIVIGE<cib_fecha o no encuentra registro:-	Si FH_INIVIGE<cib_fecha y FH_FIMVIG=NULL
//      Actualiza: FH_FIMVIGE=cib_fecha - 1 d�a

If dbSeek(xFilial("SFH")+cKeySFH)
	While !Eof()  .and. SFH->(FH_FORNECE+FH_LOJA+FH_IMPOSTO+FH_ZONFIS) ==cKeySFH   //FH_SITUACA? 
    	If SFH->FH_SITUACA <> "4"       
			If !IEncontro
				ICria:=.T.
			EndIf     	 
		Else
			IEncontro:=.T.
			ICria:=.F.
			If SFH->FH_INIVIGE < TMP->DATAP .And. Empty(SFH->FH_FIMVIGE)
				Reclock("SFH",.F.)
   	 	    	SFH->FH_FIMVIGE := TMP->DATAP-1
   	   	    	MsUnLock()                  
                  
            	Reclock("SFH",.T.)
  				SFH->FH_FILIAL  := xFilial("SFH")
   				SFH->FH_ZONFIS 	:= "BA"
				SFH->FH_AGENTE  := "N"
				SFH->FH_FORNECE := (cAlias)->A2_COD
   				SFH->FH_LOJA    := (cAlias)->A2_LOJA
				SFH->FH_NOME    := (cAlias)->A2_NOME
				SFH->FH_IMPOSTO := "IBR"
   				SFH->FH_APERIB	:= "N"
				SFH->FH_PERCIBI	:= "N"
				SFH->FH_TIPO	:= "I"
				SFH->FH_SITUACA := "4"                                                                   
				SFH->FH_INIVIGE	:= TMP->DATAP
				SFH->FH_ISENTO  := "N"
				SFH->FH_VALEMB 	:= Val(TMP->VALEMB)/100             
				MsUnLock()
           EndIf             
               
        Endif 
        SFH->(dbSkip())
	EndDo
	If ICria
		Reclock("SFH",.T.)
		SFH->FH_FILIAL  := xFilial("SFH")
		SFH->FH_ZONFIS 	:= "BA"
		SFH->FH_AGENTE  := "N"
		SFH->FH_FORNECE := (cAlias)->A2_COD
		SFH->FH_LOJA    := (cAlias)->A2_LOJA
		SFH->FH_NOME    := (cAlias)->A2_NOME
		SFH->FH_IMPOSTO := "IBR"
		SFH->FH_APERIB	:= "N"
		SFH->FH_PERCIBI	:= "N"
		SFH->FH_TIPO	:= "I"
		SFH->FH_SITUACA := "4"                                                                   
		SFH->FH_INIVIGE	:= TMP->DATAP
		SFH->FH_ISENTO  := "N"
		SFH->FH_VALEMB 	:= Val(TMP->VALEMB)/100      
		MsUnLock() 
	EndIf
Else
	Reclock("SFH",.T.)
  	SFH->FH_FILIAL  := xFilial("SFH")
	SFH->FH_ZONFIS 	:= "BA"
	SFH->FH_AGENTE  := "N"
	SFH->FH_FORNECE := (cAlias)->A2_COD
	SFH->FH_LOJA    := (cAlias)->A2_LOJA
	SFH->FH_NOME    := (cAlias)->A2_NOME
	SFH->FH_IMPOSTO := "IBR"
	SFH->FH_APERIB	:= "N"
	SFH->FH_PERCIBI	:= "N"
	SFH->FH_TIPO	:= "I"
	SFH->FH_SITUACA := "4"                                                                   
	SFH->FH_INIVIGE	:= TMP->DATAP 
	SFH->FH_ISENTO  := "N"
	SFH->FH_VALEMB 	:= Val(TMP->VALEMB)/100             
	MsUnLock()
EndIf

RestArea(aArea)

Return(.T.)   
