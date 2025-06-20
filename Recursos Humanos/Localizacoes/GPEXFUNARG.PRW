#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPEXFUNARG.CH"  

/*
��������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������
����������������������������������������������������������������������������������Ŀ��
���			ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.		    	       ���
����������������������������������������������������������������������������������Ĵ��
���Programador �   Data   �     FNC   �  Motivo da Alteracao 	    		   	   ���
����������������������������������������������������������������������������������Ĵ��
���Glaucia M.  |19/11/2011�ARG11.6-RH �gatilho para atualizacao de RA_SALARIO, etc.���
���Silvia Tag. |06/12/2011�ARG11.6-RH �Funcao para geracao dos dias de ferias      ���
���Marcelo F.  |24/01/2012�ARG11.6-RH �Atualizacao para Funcao de geracao dos dias ���
���            |          �           �dias de ferias para inclusao de funcionario.���
���Glaucia M.  |13/02/2012�ARG11.6-RH �Validacao ChkDtRec, campo RA_DTREC		   ���
���Glaucia M.  |15/02/2012�ARG11.6-RH �Criacao de Consulta Especifica para os	   ���
���			   |		  �REQ006	  �campos: RA_ATIV, RA_COND e RA_MODALID       ���
���			   |		  �			  �Funcoes:fS10ARG, fS10Pesq e fS10Ordem       ���
���Glaucia M.  |22/02/2012�ARG11.6-RH �Validacao fAliquARG para os	campos:        ���
���			   |		  �REQ006	  �RA_ATIV, RA_COND e RA_MODALID       		   ���
���Glaucia M.  |22/01/2013�000689/2013�fDiasFerArg: Tratamento para considerar     ���
���			   |		  �     TGJMGL�RA_DTREC (se vazio RA_ADMISSA), no calculo  ���
���			   |		  �     	  �de dias de direito de ferias.               ���
���			   |		  �     	  �Criacao rotina fAnosRec, para substituir o  ���
���			   |		  �     	  �uso de fCalAntig.                           ���
���Glaucia M.  |07/02/2013�001501/2013�fDiasFerArg: Tratamento para considerar     ���
���			   |		  �     TGMQ59�somente de calculo de dias proporcionais    ���
���			   |		  �     	  �baseado RA_DTREC (se vazio RA_ADMISSA), qdo ���
���			   |		  �     	  �esta rotina for chamada via GPEM042.        ���
���M. Silveira |26/12/2013�THYVGM     �Ajuste na fAliquARG para verificar se campos���
���			   |		  �TIEBGY  	  �usados na query estao preenchidos.          ���
�����������������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������*/

/*
��������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������
����������������������������������������������������������������������������������Ŀ��
���Fun��o    �SalarioAntig	� Autor � 				           � Data � 19/11/2011 ���
����������������������������������������������������������������������������������Ĵ��
���Descri��o �Gatilho para alterar Salario do funcion�rio, conforme preenchimento  ���
���			 �RA_ORISDO, RA_ADMISSA, RA_CODCONV, RA_FUNCAO, RA_DTREC			   ���
���			 �RA_ORISDO = 1- Nao ha alteracao em RA_SALARIO			               ���
���			 �RA_ORISDO = 2- RA_SALARIO igual a RJ_SALARIO						   ���
���			 �RA_ORISDO = 3- Calcula Antiguidade e busca na tabela S027 o salario e���
���			 �				altera RA_SALARIO	  								   ���
����������������������������������������������������������������������������������Ĵ��
��� Uso      �GPEA010 					                                           ���
�����������������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������*/
Function SalarioAntig()     

Local aArea		:= GetArea()
Local cOrisdo 	:= alltrim(M->RA_ORISDO)
Local cFuncao	:= alltrim(M->RA_CODFUNC)
Local cConvenio	:= alltrim(M->RA_CODCONV)
Local nReturn	:= M->RA_SALARIO
Local dReconhec 
Local nAntig	
Local cFiltro, cFilRCC
Local cMsg:=""   
Local cTamConv	
Local cTamFuncao

If !(cOrisdo $ ('1')) .and. !EMPTY(cFuncao)
	
	if cOrisdo $ ('2')
		dbSelectArea("SRJ")
		dbSetOrder(1) 
		dbSeek( xFilial("SRJ") + cFuncao )
		If !eof("SRJ") 
		    If !empty(SRJ->RJ_SALARIO) 
		    	nReturn:=SRJ->RJ_SALARIO  
		    	
			Else
				cMsg	:=Oemtoansi(STR0001)+CRLF 						//"La funcion asociada al empleado est� con sueldo VACIO, por favor averiguar. "
				cMsg	:=+cMsg+Oemtoansi(STR0002)						//El Sueldo no ser� cambiado."
				alert(cMsg)  
			Endif		
		Else 
			cMsg	:= OemtoAnsi(STR0007)+CRLF 							//"A fun��o associada ao empregado n�o existe, por favor averiguar."
			cMsg	:= cMsg + OemtoAnsi(STR0002)            			//"El Sueldo no ser� cambiado." 
			Alert(cMsg) 
		EndIf
	ElseIf cOrisdo $ ('3') 
		If empty(cConvenio)
			cMsg	:=Oemtoansi(STR0003)+CRLF    						//"El campo Convenio asociado al empleado est� VACIO."
			cMsg	:=+cMsg+Oemtoansi(STR0002)        					//"El Sueldo no ser� cambiado." 
			alert(cMsg)
		ElseIf empty(M->RA_ADMISSA) .AND. empty(M->RA_DTREC)
			cMsg	:=Oemtoansi(STR0004)+CRLF   						//"Fecha Ingreso o Fecha Reconocimiento deber�n ser llenados obligatoriamente. "
			cMsg	:=+cMsg+Oemtoansi(STR0002)			         		//"El Sueldo no ser� cambiado."
			Alert(cMsg)  
		Else
			dReconhec := IIF (!EMPTY(M->RA_DTREC),M->RA_DTREC, M->RA_ADMISSA)
			nAntig	:= (ddatabase - dReconhec)/365
		
	    	cTamConv	:= GetSx3Cache("RA_CODCONV", "X3_TAMANHO")
	    	cTamFuncao	:= GetSx3Cache("RA_CODFUNC", "X3_TAMANHO")
	    	
	    	If (cTamConv > 3) .or. (cTamFuncao >5)
	    		alert(OemtoAnsi(STR0005)) 								//"Tamanho do campo RA_CODCONV ou RA_CODFUNC, n�o est�o compat�veis com a especificao da tabela S027. Entre em contato com Administrador de dados."                                                                                                                                                                                                                                                                                                                                                                   
	    	Else
		       	
		       	cConvenio	:= IIf (len(cConvenio)<3, cConvenio+space(cTamConv-(len(cConvenio))), cConvenio)	
 	      		cFuncao		:= IIf (len(cFuncao)<3, cFuncao+space(cTamFuncao-(len(cFuncao))), cFuncao) 
		   	    	
		    	cFiltro:=cConvenio+cFuncao
		    	cFilRCC:=xFilial("RCC")
		    	DbSelectArea("RCC")
				DbSetOrder(1)      
				DbSeek(xFilial()+"S027")
				Do While cFilRCC == RCC_FILIAL .and. RCC_CODIGO == "S027"    
					If (SubStr(RCC_CONTEU,1,8) == cFiltro ) 
						cAnosDe		:= VAL(AllTrim(SubStr(RCC_CONTEU,9,5)))
						cAnosAte	:= VAL(AllTrim(SubStr(RCC_CONTEU,14,5)))
						If (nAntig >= cAnosDe) .and. (nAntig <= cAnosAte)
							nReturn := VAL(AllTrim(SubStr(RCC_CONTEU,19,12)))	
						Endif
					EndIf
					DbSkip()	
				EndDo    
            EndIf
		EndIf	
	     
	Endif
	
ElseIF cOrisdo $ ('2/3') .AND. EMPTY(cFuncao)
	cMsg	:= OemtoAnsi(STR0006)+CRLF 							//"El empleado no posee funci�n asociada. Por favor llenar el campo funci�n."
	cMsg	:= cMsg + OemtoAnsi(STR0002)            			//"El Sueldo no ser� cambiado." 
	Alert(cMsg) 
EndIf

RestArea(aArea)

Return (nReturn)

/*
��������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������
����������������������������������������������������������������������������������Ŀ��
���Fun��o    �fDiasFerArg   � Autor �  Equipe RH	           � Data � 06/12/12   ���
����������������������������������������������������������������������������������Ĵ��
���Descri��o �Retorna a quantidade de dias de ferias, que o funcion�rio tem direito���
����������������������������������������������������������������������������������Ĵ��
���Parametro �ExpL1 - Se ser� considerado Ano Civil.						       ���
���			 �ExpD2 - Data de Inicial para verificacao dos Dias de Direito. 	   ���
���			 �ExpD3 - Data de Final para verificacao dos Dias de Direito.   	   ���
���			 �ExpN4 - Dias de Direito do periodo, indicado entre ExpD2 e ExpD3.    ���
���			 �ExpN5 - Dias de Proporcionais Ferias.                                ���
���			 �ExpL6 - Se � apenas calculo de dias proporcionais para rescisao.     ���
����������������������������������������������������������������������������������Ĵ��
���Pre-Requi.�Tabela S011 - prenchida. RA_CODCONV preenchido. Tabela RGM preenchida���
����������������������������������������������������������������������������������Ĵ��
���Retorno   �Numero total de dias ferias do funcionario.                          ���
����������������������������������������������������������������������������������Ĵ��
��� Uso      �GPEA010 - GPEM120 - GPEM031 - GPEM042                                ���
�����������������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������*/

Function fDiasFerArg(lAnoCivil,dDtIni,dDtFim,nDias, nDiasProp, lRescisao)

Local nAfastFunc	:= 0
Local nAnos			:= 0
Local aAfast		:= {}
Local aMat			:= {}
Local lRet			:= .F.
Local cCodTab       := ""
Local dDataRec		:= IIf (!empty(SRA->RA_DTREC), SRA->RA_DTREC, SRA->RA_ADMISSA)

DEFAULT nDias 		:= 0
DEFAULT nDiasProp	:= 0 
DEFAULT lRescisao	:= .F.

If Year(dDataRec) == Year(dDtFim)   
   nAnos   := 1
Else
   nAnos	:= fAnosRec(dDataRec, dDtFim)
Endif           

// Obtem dias de falta
fBuscaACM(FGETCODFOL("0054"),,dDtIni,dDtFim,"H",,@nAfastFunc)
nAfastFunc *= -1
// Obtem dias de afastamento
fRetAfas(dDtIni,dDtFim,"F",,,,@aAfast)
aEval(aAfast,{ |X| nAfastFunc += If(X[7]="2",X[2],0) })

If !Empty(SRA->RA_CODCONV) .And. ;
	fPosReg("RGM",1,xFilial("RGM")+SRA->RA_CODCONV) .And. ;
	!Empty(RGM->RGM_TABFER)
	cCodTab := RGM->RGM_TABFER
Endif

If !Empty(cCodTab) 
	nPosTab := fPosTab("S011",cCodTab,"=",4,nAnos,"<=",6)		
	nDias := If(nPosTab>0,FTABELA("S011",nPosTab,7),0)
				
	If !lRescisao .And. Year(dDataRec) == Year(dDtFim)  
		//Verifica se o empregado foi admitido antes de 01/07,
		//caso sim os dias de direito passam a ser integral
		If Month(SRA->RA_ADMISSA) <= 6 
		    nDiasProp    := nDias
		Else
			nHabilesFunc := DateWorkDay(SRA->RA_ADMISSA,dDtFim,.T.)
		    nDiasProp    := Int(nHabilesFunc / 20 )
		    nDias        := nDiasProp
		EndIf
	Else    
		
		/*�����������������������������������������������������������Ŀ
		//� Calcula dias de ferias proporcionais.                     �
		//�������������������������������������������������������������*/
		nDiasTot	:= Min(dDtFim - dDtIni + 1, 365)
		nDiasProp	:= nDias/365 * nDiasTot
	Endif
Endif

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �ChkDtRec	� Autor � Equipe RH             � Data � 13.02.12 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Verifica Data Reconhecimento / Data Nascimento			  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � Generico 												  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
FUNCTION ChkDtRec(dDtNas,dDtRec)
Local cAlias := Alias()

If dDtNas >= dDtRec 
	Help(" ",1,"HELP",OemtoAnsi(STR0009),OemtoAnsi(STR0008),1,0)			//"Data Inv�lida"	## "A data de reconhecimento n�o poder� ser menor, que a data de nascimento."
	dbSelectArea( cAlias )
	Return (.F.)
Endif

dbSelectArea( cAlias )

Return (.T.)

/*/{Protheus.doc} fS10ARG
Consulta padrao para os campos RA_ATIV, RA_COND, RA_MODALID
@author  Equipe RH
@since   15/02/2012
@param cCampo, caractere, "1" - O retorno da consulta padr�o campo RA_ATIV, "2" - campo RA_COND e "3" - campo RA_MODALID 
/*/
Function fS10ARG(cCampo)
Local aArea			:= GetArea()
Local oDlgSXB		:= Nil   
Local oListBox		:= Nil
Local aAliquotas	:= {} 
Local lRet			:= .F.
Local oCmbOrdem		:= Nil
Local aOrdem		:= {OemtoAnsi(STR0010),OemtoAnsi(STR0011)} 						//"C�digo"###"Descri��o"
Local nOrdem		:= 1  
Local cPesq			:= Space(40)
Local bPesq			:= {||fS10Pesq(@oCmbOrdem,@aAliquotas,@oListBox,cPesq)}
Local lMultGroup 	:= .F.
Local cQuery		:= ""
Local cGrupos		:= ""
Local bOk			:= ""   
Local cTitulo		:= ""

Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}

Local aAdv1Size		:= {}
Local aInfo1AdvSize	:= {}
Local aObj1Size		:= {}
Local aObj1Coords	:= {}

Local aAdv2Size		:= {}
Local aInfo2AdvSize	:= {}
Local aObj2Size		:= {}
Local aObj2Coords	:= {}

aAdvSize	:= MsAdvSize(.T.,.T.,380)
aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 5 }					 
aAdd( aObjCoords , { 000 , 030 , .T. , .F.  } )  			//1- Cabecalho
aAdd( aObjCoords , { 000 , 000 , .T. , .T. , .T.  } )		//2- ListBox
aObjSize	:= MsObjSize( aInfoAdvSize , aObjCoords )

//Divisao em 2 Linhas o cabecalho
aAdv1Size		:= aClone(aObjSize[1])
aInfo1AdvSize	:= { aAdv1Size[2] , aAdv1Size[1] , aAdv1Size[4] , aAdv1Size[3] , 1 , 1 }
aAdd( aObj1Coords , { 000 , 000 , .T. , .T. } )			//LINHA1
aAdd( aObj1Coords , { 000 , 000 , .T. , .T. } )			//LINHA2
aObj1Size		:= MsObjSize( aInfo1AdvSize , aObj1Coords)//,,.T. )   

//Divisao em colunas LINHA1 em duas colunas
aAdv2Size		:= aClone(aObj1Size[1])
aInfo2AdvSize	:= { aAdv2Size[2] , aAdv2Size[1] , aAdv2Size[4] , aAdv2Size[3] , 1 , 1 }
aAdd( aObj2Coords , { 260, 000 , .F. , .T. } )				//1-Coluna1
aAdd( aObj2Coords , { 000 , 000 , .T. , .T. } )			//3-Coluna2
aObj2Size		:= MsObjSize( aInfo2AdvSize , aObj2Coords,,.T. )  

If cCampo =="1" 
	cQuery := "	SELECT DISTINCT(SUBSTRING(RCC_CONTEU,1,3)) CODIGO, SUBSTRING(RCC_CONTEU,4,6) FECHADE, "
	cQuery += " SUBSTRING(RCC_CONTEU,10,6) FECHAHASTA ,SUBSTRING(RCC_CONTEU,16,45) DESCRICAO "
	cQuery += "	FROM " + RetSQLName("RCC") + " RCC "
	cQuery += "	WHERE RCC.RCC_FILIAL  = '"  + xFilial("RCC") + "' AND "		
	cQuery += "		RCC.D_E_L_E_T_ = ' ' AND "
	cQuery += "		RCC_CODIGO IN ('S005') AND "
	cQuery += "		SUBSTRING(RCC_CONTEU,1,3) " 
	cQuery += " 	IN ( "
	cQuery += "		SELECT DISTINCT(SUBSTRING(RCC_CONTEU,1,3)) "
	cQuery += "		FROM " + RetSQLName("RCC") + " RCC1 "
	cQuery += "			WHERE RCC_CODIGO IN ('S010') AND "
	cQuery += "			RCC1.D_E_L_E_T_ = ' ' )"  
	bOk		:= {||	M->RA_ATIV := aAliquotas[oListBox:nAt][1], oDlgSXB:End(),lRet := .T.  }
	cTitulo := OemToAnsi(STR0016)																		//"C�digo de Atividades (S005)"

ElseIf cCampo =="2"	
	If(empty(M->RA_ATIV) .OR. TYPE("M->RA_ATIV")<>"C")
		cMsg	:= OemToAnsi(STR0012)+CRLF																//"O campo C�digo de Atividade est� vazio."                                                                                                                                                                                                                                                                                                                                                                                                                                                                           "O campo C�digo de Atividade est� vazio."+CRLF 	 			//"O campo C�digo de Atividade est� vazio."
		cMsg	:=+cMsg+OemtoAnsi(STR0013)										 						//"E n�o ser� poss�vel preencher este campo."
		MsgAlert(cMsg)  
		Return(.F.)
	Else
		cQuery := " SELECT DISTINCT(SUBSTRING(RCC_CONTEU,1,2)) CODIGO, SUBSTRING(RCC_CONTEU,3,6) FECHADE, "
		cQuery += " SUBSTRING(RCC_CONTEU,9,6) FECHAHASTA ,SUBSTRING(RCC_CONTEU,15,45) DESCRICAO " 
		cQuery += "	FROM " + RetSQLName("RCC") + " RCC "
		cQuery += "	WHERE RCC.RCC_FILIAL  = '"  + xFilial("RCC") + "' AND "		
		cQuery += "		RCC.D_E_L_E_T_ = ' ' AND "
		cQuery += "		RCC_CODIGO IN ('S006')  AND "
		cQuery += " 	SUBSTRING(RCC_CONTEU,1,2) "
		cQuery += " 	IN ( "
		cQuery += " 		SELECT DISTINCT(SUBSTRING(RCC_CONTEU,4,2)) "
		cQuery += "			FROM " + RetSQLName("RCC") + " RCC1 "
		cQuery += " 				WHERE RCC_CODIGO IN ('S010')  AND SUBSTRING(RCC_CONTEU,1,3) = " + M->RA_ATIV + " AND "
		cQuery += " 				RCC1.D_E_L_E_T_ = ' ' ) "
		bOk		:= {||	M->RA_COND := aAliquotas[oListBox:nAt][1], oDlgSXB:End(),lRet := .T.  }
		cTitulo := OemToAnsi(STR0017)																	//"Condi��o de Contrata��o (S006)"
	 Endif
	 	
ElseIf cCampo =="3"

	If(empty(M->RA_ATIV) .OR. TYPE("M->RA_ATIV")<>"C") .OR.   (empty(M->RA_COND) .OR. TYPE("M->RA_COND")<>"C")
		cMsg	:=OemToAnsi(STR0014)+CRLF 	 															//"O campo C�digo de Atividade ou C�digo de Condi��o est�o vazios."
		cMsg	:=+cMsg+OemtoAnsi(STR0013)							 									//"E n�o ser� poss�vel preencher este campo."
		MsgAlert(cMsg)
		Return(.F.)
	Else                 
		cQuery := " SELECT DISTINCT(SUBSTRING(RCC_CONTEU,1,3)) CODIGO, SUBSTRING(RCC_CONTEU,4,6) FECHADE, "
		cQuery += " SUBSTRING(RCC_CONTEU,10,6) FECHAHASTA , SUBSTRING(RCC_CONTEU,16,48) DESCRICAO "
		cQuery += "	FROM " + RetSQLName("RCC") + " RCC "
		cQuery += "	WHERE RCC.RCC_FILIAL  = '"  + xFilial("RCC") + "' AND "		
		cQuery += "		RCC.D_E_L_E_T_ = ' ' AND "
		cQuery += "		RCC_CODIGO IN ('S008') AND "  
		cQuery += " 	SUBSTRING(RCC_CONTEU,1,3) "
		cQuery += " 	IN ( "
		cQuery += " 		SELECT DISTINCT(SUBSTRING(RCC_CONTEU,6,3)) "
		cQuery += "			FROM " + RetSQLName("RCC") + " RCC1 "
		cQuery += " 				WHERE RCC_CODIGO IN ('S010')  AND SUBSTRING(RCC_CONTEU,1,3) = " + M->RA_ATIV + " AND "
		cQuery += "					SUBSTRING(RCC_CONTEU,4,2) = " + M->RA_COND + " AND "
		cQuery += " 				RCC1.D_E_L_E_T_ = ' ' ) "
		bOk		:= {||	M->RA_MODALID := aAliquotas[oListBox:nAt][1], oDlgSXB:End(),lRet := .T.  }
		cTitulo := OemToAnsi(STR0018)																	//"Modalidade de Contrata��o (S008)"
	Endif
Else
    cMsg	:=OemToAnsi(STR0020)+CRLF 																		//"A consulta padr�o deste campo, est� com par�metros inexistentes." 
    cMsg	:=+cMsg+OemtoAnsi(STR0021)																		//"Procure o Administrador do Sistema." 
    MsgAlert(cMsg)
    Return()
Endif	
			
	cQuery := ChangeQuery(cQuery)
	If Select("RCCQRY") <> 0
		DbSelectArea("RCCQRY")
		DbCloseArea()
	Endif
	
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),"RCCQRY",.F.,.T.)		
	
	While RCCQRY->(!Eof()) 
		If AScan(aAliquotas,{|x| x[1] == RCCQRY->CODIGO }) <= 0
			Aadd(aAliquotas,{	RCCQRY->CODIGO,  RCCQRY->FECHADE, RCCQRY->FECHAHASTA,RCCQRY->DESCRICAO })
  		EndIf
		RCCQRY->(dbSkip())
	EndDo

If Len(aAliquotas) <= 0  
	cMsg	:=OemToAnsi(STR0015)+CRLF 	 															//"N�o existem Aliquotas Gerais (S010), que atendam a condi��o:"			
	cMsg	:=+cMsg+OemToAnsi(STR0016)+" x "+OemToAnsi(STR0017)+" x "+ OemToAnsi(STR0018)+"."			//"C�digo de Atividades (S005)" ### "Condi��o (S006)" ### "Modalidade (S008)"	
	MsgAlert(cMsg)  
	Return(.F.)   
EndIf

//Tela de consulta
oDlgSXB := TDialog():New(aAdvSize[7],0,aAdvSize[6],aAdvSize[5],cTitulo,,,,,,,,oMainWnd,.T.) 
	
@ aObj1Size[1,1], aObj1Size[1,2] MSCOMBOBOX oCmbOrdem VAR nOrdem  ITEMS aOrdem SIZE 250,010 OF oDlgSXB ON CHANGE fS10Ordem(oCmbOrdem,@aAliquotas,@oListBox) PIXEL
@ aObj2Size[2,1], aObj2Size[2,2] BUTTON OemToAnsi(STR0019) SIZE 041, 011 OF oDlgSXB PIXEL Action Eval(bPesq)  			//"Buscar"
@ aObj1Size[2,1], aObj1Size[2,2] MSGET cPesq SIZE 250, 010 OF oDlgSXB PIXEL Valid (Eval(bPesq))
	
oListBox := TWBrowse():New(aObjSize[2,1], aObjSize[2,2] ,aObjSize[2,3], aObjSize[2,4],,{UPPER(OemToAnsi(STR0010)),UPPER(OemToAnsi(STR0022)),UPPER(OemToAnsi(STR0023)),UPPER(OemToAnsi(STR0011))},,oDlgSXB,,,,,,,,,,,,.F.,,.T.,,.F.,,,) //"CODIGO"###"DATA DE"###"DATA ATE"###"DESCRICAO"
oListBox:bLDblClick := bOk
		
fS10Ordem(@oCmbOrdem,@aAliquotas,@oListBox)		
		
oDlgSXB:bInit := {|| EnchoiceBar(oDlgSXB, bOK, {||oDlgSXB:End()},,)}
oDlgSXB:lCentered := .T.
oDlgSXB:Activate(,,,.T.)

If lRet .AND. (INCLUI .OR. ALTERA)
	VAR_IXB := ""
	if cCampo=="1"
		VAR_IXB := M->RA_ATIV
	ElseIf cCampo=="2"
		VAR_IXB := M->RA_COND	
	ElseIf cCampo=="3"
		VAR_IXB := M->RA_MODALID	
	EndIf
EndIf

RestArea(aArea)
Return lRet

/*
��������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������
����������������������������������������������������������������������������������Ŀ��
���Fun��o    �fS10Pesq		� Autor �  Equipe RH	           � Data � 15/02/2012 ���
����������������������������������������������������������������������������������Ĵ��
���Descri��o �Realiza a pesquisa na listagem de Atividades, Condicao ou Modalidade ���
����������������������������������������������������������������������������������Ĵ�� 
���Parametro �ExpO1 - Objeto do combo de ordenacao  							   ���
���			 �ExpA2 - Array de aliquotas S010  									   ���
���			 �ExpO3 - Objeto da listbox		  									   ���
���			 �ExpC4 - Texto para pesquisa										   ���
����������������������������������������������������������������������������������Ĵ��
��� Uso      �GPEXFUNARG - fS10ARG 		                                           ���
�����������������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������*/

Static Function fS10Pesq(oCmbOrdem,aAliquotas,oListBox,cPesq)

Local nPos		:= 0 
Local nOrdem	:= oCmbOrdem:nAt
Local nSize		:= 0

cPesq := AllTrim(Upper(cPesq))
nSize := Len(cPesq)

If nOrdem == 1		//Por codigo
	nPos := aScan(aAliquotas,{|x| Left(AllTrim(Upper(x[1])),nSize) == cPesq })
ElseIf nOrdem == 2	//Por Descricao
	nPos := aScan(aAliquotas,{|x| Left(AllTrim(Upper(x[4])),nSize) == cPesq })
EndIf

If nPos > 0
	oListBox:nAt := nPos
	oListBox:Refresh()
EndIf

Return .T.


/*
��������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������
����������������������������������������������������������������������������������Ŀ��
���Fun��o    �fS10Ordem		� Autor �  Equipe RH	           � Data � 15/02/2012 ���
����������������������������������������������������������������������������������Ĵ��
���Descri��o �Realiza a pesquisa na listagem de Atividades, Condicao ou Modalidade ���
����������������������������������������������������������������������������������Ĵ�� 
���Parametro �ExpO1 - Objeto do combo de ordenacao 							       ���
���			 �ExpA2 - Array de aliquotas S010			   						   ���
���			 �ExpO3 - Objeto da listbox		  									   ���
����������������������������������������������������������������������������������Ĵ��
��� Uso      �GPEXFUNARG - fS10ARG 		                                           ���
�����������������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������*/
Static Function fS10Ordem(oCmbOrdem,aAliquotas,oListBox)

Local nOrdem := oCmbOrdem:nAt

If nOrdem == 1 
	//Ordena pelo codigo
	ASort(aAliquotas,,,{|x,y| x[1] < y[1] })
ElseIf nOrdem == 2
	//Ordena por Descri��o
	ASort(aAliquotas,,,{|x,y| x[4] < y[4] })
EndIf

oListBox:SetArray(aAliquotas)
oListBox:bLine := {||{	aAliquotas[oListBox:nAt][1],;
						aAliquotas[oListBox:nAt][2],; 
						aAliquotas[oListBox:nAt][3],;
						aAliquotas[oListBox:nAt][4]}} 
oListBox:GoTop()
oListBox:Refresh()

Return .T.


/*
��������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������
����������������������������������������������������������������������������������Ŀ��
���Fun��o    �fAliquARG		� Autor �  Equipe RH	           � Data � 22/02/2012 ���
����������������������������������������������������������������������������������Ĵ��
���Descri��o �Realiza validacao do cadastro de funcionario, onde a combinacao dos  ���
���			 �campos RA_ATIV, RA_COND e RA_MODALID devem existir na tabela S010.   ���
����������������������������������������������������������������������������������Ĵ��
���Pre-Requis�E obrigatorio que a tabelas S010 exista					 		   ���
���			 �E estejam conforme layout definido na especifica��o deste Requisito  ���
����������������������������������������������������������������������������������Ĵ��
���Parametro �ExpC1 - "1" - O retorno da validacao campo RA_ATIV			   	   ���
���			 �		- "2" - O retorno da validacao campo RA_COND			  	   ���
���			 �		- "3" - O retorno da validacao campo RA_MODALID		   		   ���
���			 �		- "4" - O retorno da validacao no momento confirma GPEA010	   ���
����������������������������������������������������������������������������������Ĵ��
��� Uso      �GPEA010  			 		                                           ���
�����������������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������*/
Function fAliquARG(cCampo)

Local lRet 	:= .F.
Local cMsg	:=""  
Local cQuery:=""
Local lTab	:= .T.
Local lAtivi
Local lCondi
Local lModal

lAtivi := ( Type("M->RA_ATIV")<>"C" .Or. Empty(M->RA_ATIV) )
lCondi := ( Type("M->RA_COND")<>"C" .Or. Empty(M->RA_COND) )
lModal := ( Type("M->RA_MODALID")<>"C" .Or. Empty(M->RA_MODALID) )

//Valida adequadamente cada campo para impedir erro na execucao da query   
If lAtivi 
	lTab := .F.
ElseIf cCampo == "4" .And. ( lAtivi .Or. lCondi .Or. lModal )
	lTab := .F.
ElseIf cCampo == "2" .And. lCondi
	lTab := .F.
ElseIf cCampo $ "34" .And. ( lCondi .Or. lModal )
	lTab := .F.
EndIf

If !lTab
	cMsg	:=OemToAnsi(STR0024)+CRLF 	//"Campos: Atividade, Condi��o e Modalidade s�o obrigat�rios."
	cMsg	:=+cMsg+OemtoAnsi(STR0025)	//"Por favor averiguar."
	MsgAlert(cMsg)  
	Return(lRet)
Endif

cQuery := " SELECT COUNT(*) TOTALS10 "
cQuery += "	FROM " + RetSQLName("RCC") + " RCC "
cQuery += "	WHERE RCC.RCC_FILIAL  = '"  + xFilial("RCC") + "' AND "		
cQuery += "		RCC.D_E_L_E_T_ = ' ' AND "
cQuery += "		RCC_CODIGO IN ('S010') AND "  
cQuery += " 	SUBSTRING(RCC_CONTEU,1,3) = " + M->RA_ATIV + " " 

If cCampo $ "2" .and. !empty(M->RA_COND)
	cQuery += "		AND SUBSTRING(RCC_CONTEU,4,2) = " + M->RA_COND + " "
ElseiF cCampo $ ("34") .and. !empty(M->RA_COND).and. !empty(M->RA_MODALID)
	cQuery += "		AND SUBSTRING(RCC_CONTEU,4,2) = " + M->RA_COND + " "
	cQuery += "		AND SUBSTRING(RCC_CONTEU,6,3) = " + M->RA_MODALID + " " 	
Endif
			
	cQuery := ChangeQuery(cQuery)
	If Select("RCCQRY2") <> 0
		DbSelectArea("RCCQRY2")
		DbCloseArea()
	Endif
	
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),"RCCQRY2",.F.,.T.)		
	
	If RCCQRY2->TOTALS10 <> 0  
		If RCCQRY2->TOTALS10 > 1 .and. cCampo $('34')
			cMsg	:=OemToAnsi(STR0026)+CRLF 	 															//"Tabela Aliquotas Gerais (S010), possui mais de um registro com a mesma combinacao de: Atividade, Condi��o e Modalidade."                                                                                                                                                                                                                                                                                                                                                                                           
			cMsg	:=+cMsg+OemtoAnsi(STR0027)							 									//"Por favor verifique a tabela Aliquotas Gerais (S010)."                                                                                                                                                                                                                                                                                                                                                                                                                                                             
			MsgAlert(cMsg) 
		Else
			if cCampo $ ("1") .AND. !EMPTY(M->RA_COND)
				M->RA_COND=""
			Endif
			If cCampo $ ("12") .and. !EMPTY(M->RA_MODALID)
				M->RA_MODALID=""
			Endif
			lRet:=.T.
		Endif                                                       
	Else
		cMsg	:=OemToAnsi(STR0015)+CRLF 	 																//"N�o existem Aliquotas Gerais (S010), que atendam a condi��o:"			
		cMsg	:=+cMsg+OemToAnsi(STR0016)+" x "+OemToAnsi(STR0017)+" x "+ OemToAnsi(STR0018)+"."			//"C�digo de Atividades (S005)" ### "Condi��o (S006)" ### "Modalidade (S008)"	
		MsgAlert(cMsg)
	EndIf

Return(lRet)



/*
��������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������
����������������������������������������������������������������������������������Ŀ��
���Fun��o    �fAnosRec		� Autor �  Equipe RH	           � Data � 23/01/2013 ���
����������������������������������������������������������������������������������Ĵ��
���Descri��o �Calcula e retorna o numero de anos de Data de reconhecimento do fun- ���
���			 �cionario, baseado nos parametros recebidos.                          ���
����������������������������������������������������������������������������������Ĵ��
���Parametro �ExpD1 - Data de Inicio para contagem de Anos do funcion�rio.         ���
���			 �ExpD2 - Data de Final para contagem de Anos do funcion�rio. 	  	   ���
����������������������������������������������������������������������������������Ĵ��
���Retorno   �Numero total de anos, baseado nos parametros ExpD1 e ExpD2.          ���
����������������������������������������������������������������������������������Ĵ��
��� Uso      �GPEXFUNARG - fun�ao: fDiasFerArg   	                               ���
�����������������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������*/
Function fAnosRec(dDataIni, dDataFim)
Local nTempo		:= DateDiffMonth( dDataIni, dDataFim)
Local nTotTempo		:= 0
Local nTotalAnos	:= 0

nTotTempo := (nTotTempo + nTempo)
nTotalAnos := (nTotTempo / 12)

//# Acrescenta 1 nos Meses
If (nTotTempo - INT(nTotTempo)) > 0
	If !lTruncMes
		nTotTempo += 1
	EndIf
EndIf

//# Acrescenta 1 nos Anos
If ( ((nTotTempo/12) - INT(nTotTempo/12)) * 12 ) >= 12
	nTotalAnos += 1
EndIf

Return(nTotalAnos)

