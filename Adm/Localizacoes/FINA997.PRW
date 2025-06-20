#INCLUDE "FINA997.ch"
#INCLUDE "Protheus.ch"

/*
�����������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Programa    � FINA997  �Autor  �	Bruno Schmidt    � Data � 20/02/2013     ���
������������������������������������������������������������������������������͹��
���Desc.       �Le o arquivo de retorno 			                              ���
������������������������������������������������������������������������������͹��
���Uso         �SigaFis                                                        ���
���Programador � Data   �   BOPS   �           Motivo da Alteracao             ���
������������������������������������������������������������������������������Ĵ��
���gsantacruz  �09/06/17�  MMI-5915�Se replica el fuente para 12.1.14 ya se    ���
���            �        �          �modifica el uso de tablas temporales CTREE ���
������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/      
Function FINA997()                     


Local aCarga	:= {}

Local cTitulo	:= ""
Local cErro		:= ""
Local cSolucao	:= ""

Local lCarga 	:= .F.
Private oTmpTable		:= Nil

If FINA997Wiz()	   
		//������������������������������������������������������������������Ŀ
		//�Carrega no arquivo temporario as informacoes do arquivo de retorno�
		//��������������������������������������������������������������������
		Processa({|| aCarga := FINA997Le()})
		lCarga := aCarga[01]   
		If lCarga
			//����������������������������������������������Ŀ
			//�Atualiza tabelas com as informacoes do retorno�
			//������������������������������������������������
			Processa({|| FINA997Atu(aCarga[02])})
			 
		Else
			cTitulo 	:= STR0024		//"Importa��o n�o realizada"	
			cErro		:= STR0025		//"A importa��o do arquivo de retorno n�o foi realizada "
			cErro		+= STR0026		//"por n�o existirem informa��es de retorno no arquivo "
			cErro		+= STR0027		//"texto informado. "
			cSolucao	:= STR0028		//"Verifique se o arquivo de retorno informado nas "
			cSolucao	+= STR0029		//"perguntas da rotina � o enviado pela Reproweb "
			cSolucao	+= STR0030		//"e processe esta rotina novamente."
			xMagHelpFis(cTitulo,cErro,cSolucao)
		Endif
		//�������������������������������������Ŀ
		//�Excluindo o arquivo temporario criado�
		//���������������������������������������
		If oTmpTable <> Nil 
				oTmpTable:Delete()
				oTmpTable := Nil
		EndIf
		
Else
	cTitulo 	:= STR0018 				//"Implementa��o n�o efetuada"	
	cErro		:= STR0019 				//"A implementa��o do processo de atualiza��o"
	cErro		+= STR0020 				//"Reproweb n�o foi efetuada corretamente."
	cSolucao	:= STR0021 				//"verifique a documenta��o que acompanha a rotina e "
	cSolucao	+= STR0022 				//"execute todos os procedimentos indicados e processe "
	cSolucao	+= STR0023 				//"esta rotina novamente."
	xMagHelpFis(cTitulo,cErro,cSolucao)
Endif

Return(.T.)

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Programa  �FINA997Wiz  �Autor  �   Bruno Schmidt    � Data � 20/02/2013  ���
���������������������������������������������������������������������������͹��
���Desc.     �Monta a wizard com as perguntas a rotina de importacao        ���
���������������������������������������������������������������������������͹��
���Uso       �Reproweb                                                      ���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Static Function FINA997Wiz()

//������������������������Ŀ
//�Declaracao das variaveis�
//��������������������������
Local aTxtPre 		:= {}
Local aPaineis 		:= {}

Local cTitObj1		:= ""                
Local cMask			:= Replicate("X",245)
	
Local nPos			:= 0
	
Local lRet			:= 0
Local cCab			:= STR0001 //"Importa��o do Arquivo Reproweb"
//�����������������������������������������Ŀ
//�Monta wizard com as perguntas necessarias�
//�������������������������������������������
aAdd(aTxtPre,STR0001) //"Importa��o do Arquivo "
aAdd(aTxtPre,STR0002) //"Aten��o"
aAdd(aTxtPre,STR0003) //"Preencha corretamente as informa��es solicitadas."
aAdd(aTxtPre,Alltrim(STR0004)+" "+cCab+Alltrim(STR0005)+" "+Alltrim(STR0006))	
										//"Esta rotina ira importar o arquivo de retorno disponibilizado pela Reproweb       "
										//", contendo informa��es sobre fornecedores     "
										//"em um deternimado per�odo."

//�������������������������������������Ŀ
//�Painel 1 - Informacoes da Empresa    �
//���������������������������������������
aAdd(aPaineis,{})
nPos :=	Len(aPaineis)
aAdd(aPaineis[nPos],STR0007) //"Assistente de parametriza��o" 
aAdd(aPaineis[nPos],STR0008) //"Informa��es sobre o arquivo de retorno: "
aAdd(aPaineis[nPos],{})

cTitObj1 :=	STR0009 //"Arquivo de retorno: "
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

lRet :=	xMagWizard(aTxtPre,aPaineis,"FINA997")
	
Return(lRet)   

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Programa  �FINA997Tmp  �Autor  �   Bruno Schmidt    � Data � 20/02/2013  ���
���������������������������������������������������������������������������͹��
���Desc.     �Cria o arquivo temporario para importacao                     ���
���          �                                                              ���
���������������������������������������������������������������������������͹��
���Uso       �Reproweb                                                      ���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Static Function FINA997Tmp()

Local aArqPRO   := {}                                 


AADD(aArqPRO,{"CUIT"    ,"C",11 ,0})
AADD(aArqPRO,{"NUMCERT"	,"C",13 ,0})
AADD(aArqPRO,{"BRN"	    ,"C",10 ,0})
AADD(aArqPRO,{"PORC"	,"C",03 ,0})
AADD(aArqPRO,{"RG"      ,"C",04 ,0})
AADD(aArqPRO,{"INN"     ,"C",04 ,0})
AADD(aArqPRO,{"DTEMIS"  ,"C",10 ,0})
AADD(aArqPRO,{"DTPUBLI" ,"C",10 ,0})

AADD(aArqPRO,{"IMPORT"	,"C",01,0}) 
AADD(aArqPRO,{"ERRO"	,"C",35,0}) 

	aOrdem := {"CUIT" }
	oTmpTable := FWTemporaryTable():New("PRO")
	oTmpTable:SetFields(aArqPRO)
	oTmpTable:AddIndex("I1", aOrdem)
	oTmpTable:Create()
	
Return

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Programa  � FINA997Le  �Autor  �   Bruno Schmidt    � Data � 20/02/2013  ���
���������������������������������������������������������������������������͹��
���Desc.     �Le arquivo de retorno e carrega o arquivo temporario          ���
���          �para atualizar cadastro de Fornecedor.                        ���
���������������������������������������������������������������������������͹��
���Uso       �Reproweb                                                      ���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Static Function FINA997Le

Local aWizard		:= {}
Local aInforma      := {}
	
Local lRet			:= !xMagLeWiz("FINA997",@aWizard,.T.)
	
Local cArqProc		:= Alltrim(aWizard[01][01])
Local cTitulo		:= ""
Local cErro			:= ""
Local cSolucao		:= ""
Local cLinha		:= ""
Local cChar			:= ""

Local lCarga		:= .F.   
Local lArqValido	:= .F.

Local nCont			:= 0
Local nX            := 0 
//���������������������������������������������
//�Cria o arquivo temporario para a importacao�
//���������������������������������������������
 FINA997TMP()                                  

//����������������������������������������������������
//�Verifica se o arquivo existe no diretorio indicado�
//����������������������������������������������������
If File(cArqProc) .And. !lRet

	nHandle	:=	FOpen(cArqProc)
	nTam	:=	FSeek(nHandle,0,2)
	FSeek(nHandle,0,0)
	ProcRegua(nTam)

	FT_FUse(cArqProc)
	FT_FGotop()

	//�����������������������������������������������������������������������Ŀ
	//�Verifica se o arquivo aberto e um arquivo valido com o mesmo CGC do SM0�
	//�������������������������������������������������������������������������
	lArqValido 	:= .T.	
	cChar  		:= "."       
	nCont	    := 0
	
	cLinha := ""
  	cLinha := FT_FREADLN()	
	
	If lArqValido 
		FT_FGotop()
		FSeek(nHandle,0,0)
		cChar  := ","		
		cLinha := ""		
		
		While (!FT_FEof()) 		
			IncProc()
			cLinha := ""        
			aDadosSA := {}
		    aInforma := {}	            
   			cLinha := FT_FREADLN()
        	RecLock("PRO",.T.)
        			For nX := 1 to 9
        				If nX == 9
        			   	 	AADD (aInforma,Alltrim(SubStr(cLinha,1,(nPos-1))))
        				Else
	        	        	nPos := at(";",cLinha)
	        	        	AADD (aInforma,Alltrim(SubStr(cLinha,1,(nPos-1))))
	        	        	cLinha := SubStr(cLinha,nPos+1,Len(cLinha))
	        	        EndIf	
        	        nEXT
        	  		PRO->CUIT 	 := aInforma [1]
					PRO->NUMCERT := aInforma [2]
					PRO->BRN	 := aInforma [3]
					PRO->PORC	 := aInforma [5]
					PRO->RG  	 := aInforma [6]
					PRO->INN 	 := aInforma [7]
					PRO->DTEMIS	 := aInforma [8]
					PRO->DTPUBLI := aInforma [9]			
					
			FT_FSkip()
		Enddo 
		lCarga := .T.        
	Else
		lCarga := .F.
	Endif	
	FT_FUse()
	FClose(nHandle)
Else 
	cTitulo 	:= STR0011 						//"Arquivo de importa��o n�o localizado"	
	cErro		:= STR0012 + cArqProc			//"N�o foi localizado no diret�rio "
	cErro		+= STR0013 + STR0014 	        //" o arquivo "," indicado nas perguntas "
	cErro		+= STR0015 						//"da rotina."
	cSolucao	:= STR0016 						//"Informe o diret�rio e o nome do arquivo "
	cSolucao	+= STR0017 						//"corretamente e processe a rotina novamente."
	xMagHelpFis(cTitulo,cErro,cSolucao)
	lCarga := .F.
Endif

Return({lCarga,cArqProc})

/*�����������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Programa  � FINA997Atu �Autor  �	  Bruno Schmidt    � Data � 20/02/2013  ���
���������������������������������������������������������������������������͹��
���Desc.     �Atualiza tabela do Protheus com as informacoes retornadas     ���
���          �pela tabela de Fornecedores                        	        ���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�����������������������������������������������������������������������������*/                                                                                                    
Static Function FINA997Atu(cCarga)

ProcRegua(PRO->(LastRec()))
SA2->(dbSetOrder(3))

PRO->(dbGoTop())
While !(PRO->(Eof()))

	IncProc()
	//��������������������������������Ŀ
	//�Atualizando tabelas posicionadas�
	//����������������������������������
	If SA2->(MsSeek(xFilial("SA2")+Alltrim(PRO->CUIT)))
		While !SA2->(EOF()) .And. xFilial("SA2") == SA2->A2_FILIAL .And. Alltrim(PRO->CUIT) == Alltrim(SA2->A2_CGC) .and. SA2->A2_CONCSUS $"1246" 
		  	Begin Transaction 
		  	
				RecLock("SA2",.F.) 
				
				SA2->A2_PORSUS	:= 100 - Val(PRO->PORC)
				SA2->A2_DTICALS	:= TrsfData(PRO->DTEMIS)
				SA2->A2_DTFCALS := TrsfData(PRO->DTPUBLI)	
				MsUnLock()
			End Transaction
			SA2->(dbSkip())
		EndDo
		
 		RecLock("PRO",.F.)
 		PRO->ERRO :=STR0041 //"Importado"
		MsUnLock()
 	Else
    	//����������������������������������������������Ŀ
		//�Se houve algum erro na atualizacao das tabelas�
		//������������������������������������������������
		RecLock("PRO",.F.)
		PRO->IMPORT	:= "1"
		PRO->ERRO	:= STR0031 //"Fornecedor n�o encontrado"
		MsUnLock() 	
	EndIf
	PRO->(dbSkip())
Enddo

Return(.T.)	

/*�����������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Programa  � TransfData �Autor  �	  Bruno Schmidt    � Data � 20/02/2013  ���
���������������������������������������������������������������������������͹��
���Desc.     �Transforna a a data recebi do Arquivo						    ���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�����������������������������������������������������������������������������*/ 
Static Function TrsfData(cData)
Local cMes := ""
Local cDia := ""
Local cAno := ""   


cDia	:= Substr(cData,1,2) 
cMes	:= Substr(cData,4,3) 
cAno	:= Substr(cData,8,2) 
cAnoVig := Str(Year(Date()),4,0)
cAnoVig := SubStr(cAnoVig,1,2)
	
Do case
	Case cMes == "JAN"
		cMes:= "01"
	Case cMes == "FEB"
		cMes:= "02"
	Case cMes == "MAR"
		cMes:= "03"
	Case cMes == "APR"
		cMes:= "04"
	Case cMes == "MAY"
		cMes:= "05"
	Case cMes == "JUN"
		cMes:= "06"
	Case cMes == "JUL"
		cMes:= "07"
	Case cMes $ "AGO|AUG"
		cMes:= "08"
	Case cMes $ "SET|SEP"
		cMes:= "09"
	Case cMes == "OCT"
		cMes:= "10"
	Case cMes == "NOV"
		cMes:= "11"
	Case cMes $ "DIC|DEC"
		cMes:= "12"
EndCase


cData:= cDia+"/"+cMes+"/"+cAnoVig+cAno

Return Ctod(cData)

