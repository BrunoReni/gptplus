#INCLUDE "PROTHEUS.CH"

Static aDePara  := {}// ter� valores refer�ncia quando as parcelas tiverem os valores de A a Z

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LOJA2500   �Autor  �Microsiga          � Data �  02/27/12   ���
�������������������������������������������������������������������������͹��
���Desc.     � Fun��o inicia o job para a sele��o dos t�tulos e envio ao  ���
���          �CAP na integra��o com o Financial Service.                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function LOJA2500(aPar)

    Local lJob := !( aPar == NIL )                        // Variavel l�gica que retorna se o aPAr nao esta nulo
	Local cEmpJob := IIF( lJob, aPar[1], "" )             // Variavel retorna Empresa
	Local cFilJob := IIF( lJob, aPar[2], "" )             // Variavel retorna Filial
    Local oObjX		:= NIL                                 // objeto para a classe LJClTitCAP que tratar� a chamada da Integdef
	Local cQry		:= ""                                  // string com a consulta a ser realizada
	Local cTip		:= ""      							   // Tipos dos t�tulos a serem enviados ao CAP
	Local cSit		:= ""							       // Situa��o dos t�tulos a serem enviados ao CAP
	Local cAliasQry := "cAliasQry"                         // nome da �rea de trabalho trabalho
    Local lMvParFa  := .F.                                 //Parametro habilitado para recalcular as parcelas
    Local nMVLjMiCAP:= SuperGetMv("MV_LJMICAP",,0)         //Valor m�nimo devido do contrato (Filial + Prefixo + Numero)
    Local aTamE1Saldo := SE1->(TamSX3("E1_SALDO"))
   
   
	If ( lJob )
		RpcSetType( 3 )
		RpcSetEnv( cEmpJob, cFilJob )

	EndIf  
	
	cTip		:= SuperGetMv("MV_LJTCPFS", ,"")
	cSit		:= SuperGetMV("MV_LJSTFS", , "")
	lMvParFa	:= SuperGetMV("MV_LJPARFA",,.F.)

	#IFDEF TOP
        
		If lMvParFa       
		
			SE1->(DbSetOrder(1))  // 1-> E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
	
			cQry := ""
			cQry := " SELECT SE11.E1_FILIAL,SE11.E1_PREFIXO,SE11.E1_NUM,SE11.E1_PARCELA,SE11.E1_TIPO "
			
			If nMVLjMiCAP > 0  
			
				cQry += ", ( Select SUM(SE12.E1_SALDO) From " + RetSqLName("SE1") + " SE12 " +;
						" WHERE " 
						
						 	If !Empty(cTip)     
								cQry += " SE12.E1_TIPO IN('" + StrTRan(cTip, ",", "','")  + "', 'FI' ) AND "
							Else
								cQry += " SE12.E1_TIPO = 'FI' AND "
							EndIf
							
							// filtra as situa��es conforme o par�metro MV_LJSTFS
							If !Empty(cSit)					
								cQry += " SE12.E1_SITUACA IN('" + StrTran(cSit, ",","','") + "') AND "
							EndIf
							
				cQry += "SE11.E1_FILIAL = SE12.E1_FILIAL AND  "  +;
						"SE11.E1_PREFIXO = SE12.E1_PREFIXO AND " +;
						"SE11.E1_NUM = SE12.E1_NUM AND " +;
						"SE12.D_E_L_E_T_ <> '*' AND " +;
						"SE12.E1_SALDO > 0 ) AS SLDDEVCTT " 
			EndIf
			
			cQry +=	" FROM " + RetSqLName("SE1") + " SE11 "
			cQry += " WHERE SE11.E1_FILIAL = '" + xFilial('SE1')+ "' AND"
			cQry += " SE11.D_E_L_E_T_ <> '*' AND" 
	
			// filtra os tipos conforme o par�metro MV_LJTCPFS
			If !Empty(cTip)     
				cQry += " SE11.E1_TIPO IN('" + StrTRan(cTip, ",", "','")  + "', 'FI' ) AND "
			Else
				cQry += " SE11.E1_TIPO = 'FI' AND "
			EndIf
			
			// filtra as situa��es conforme o par�metro MV_LJSTFS
			If !Empty(cSit)
	
				cQry += " SE11.E1_SITUACA IN('" + StrTran(cSit, ",","','") + "') AND "
			EndIf
			
			cQry += " SE11.E1_VENCREA < '" + DtoS(dDataBase) + "' AND SE11.E1_SALDO > 0"  
			cQry += " ORDER BY SE11.E1_FILIAL,SE11.E1_PREFIXO,SE11.E1_NUM,SE11.E1_TIPO"


			If Select(cAliasQry) > 0
				(cAliasQry)->(DbCloseArea())
			EndIf  
					
			// gera a �rea de trabalho tempor�ria e posiciona no registro inicial
			DbUseArea( .T., "TOPCONN", TcGenQry(,,cQry), cAliasQry, .F., .T. ) 		
			              
			DbSelectArea(cAliasQry) 
			
			If nMVLjMiCAP > 0
				TCSetField(cAliasQry,"SLDDEVCTT","N", aTamE1Saldo[1], aTamE1Saldo[2])
			EndIf
			
			// realiza o envio dos t�tulos filtrados para cada registro
			While !(cAliasQry)->(EOF()) 
			    
			    cChave := (cAliasQry)->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_TIPO)
				oObjX:=LJCLTitCAP():New(cAliasQry)	  
				
				// verifica se h� necessidade de enviar o t�tulo ao CAP
				
				
				If oObjX:VerifEnvio(nMVLjMiCAP)
					oObjX:GeraXML() 	
				EndIf
				
				
				If RTrim((cAliasQry)->E1_TIPO) == "FI"
				// verifica se o proximo registro � igual ao t�tulo processado
					While ( cChave == (cAliasQry)->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_TIPO) )
						(cAliasQry)->(dbSkip())
					End                                               
	            Else 
	            	(cAliasQry)->(dbSkip())
	            EndIf 
	            
			End   
			                     
			(cAliasQry)->(DbCloseArea())
			If oObjX <> Nil
				oObjX:Destruct()
				FreeObj(oObjX)
				oObjX := NIL
			EndIf
	Else
		ConOut("Para execucao do Job LOJA2500 e necessario que o parametro MV_LJPARFA esteja habilitado")
	EndIf
	
	#ENDIF	   
   
	If ( lJob )

		RpcClearEnv()

	EndIf 

	  	     		
Return NIL

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LjNumParc �Autor  �Protheus            � Data �  03/27/12   ���
�������������������������������������������������������������������������͹��
���Desc.     � Retornar o numero de uma parcela no sigaloja ou faturamento���
���          �considerando seu caracter/c�digo                            ���
�������������������������������������������������������������������������͹��
���Sintaxe   � LjNumParc( ExpC1, ExpC2 ) -> nRet                          ���
�������������������������������������������������������������������������͹��
���Retorno   � Numerico - nRet: posi��o ao qual corresponde o caracter    ���
�������������������������������������������������������������������������͹��
���Parametros�ExpC1 - C�digo da Parcela Ex.: Campo E1_PARCEL              ���
���          �ExpC2 - Tipo do sequenciamento da parcela                   ���
���          � A = sequencia alfa                                         ���
���          � 1 = sequencia num�rica                                     ���
�������������������������������������������������������������������������͹��
���Uso       � LOJA250                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function LjNumParc ( cParcela, cTipo )

	Local nRetParc    := 1                                 // retorno da fun��o
	Local nTam       := Len(Alltrim(cParcela))           // se o tamanho da vari�vel � 1
	Local lMvLJParc   := SuperGetMv( "MV_LJPARFA", ,.F.)  // se o sequenciamento est� conforme o Faturamento
	Local nValParc    := Val(cParcela)                     // transforma��o da parcela em sua forma num�rica
	Local nTamCampo   := TamSx3("E1_PARCELA")[1]           // controla o n�mero de posi��es para indica��o no Soma1
	Local cAuxParc    := ""        // possuir� conte�do auxiliar para controle da itera��o e compara��o com parcela procurada
	Local nI          := 0                   // controlador de repeti��o
	Local lCharVal    := .T.				//Lista de caracteres v�lidos
	
	Default cTipo     := RTrim(SuperGetMv( "MV_1DUP", ,"A"))
	cParcela         := Alltrim(cParcela)              // ajuste do valor de entrada para elimina��o dos espa�os
	
	If  lMvLjParc  //Calculo do faturamento
	    
	    nI := 0	     
		Do While lCharVal .AND. (nI := nI + 1) <= nTam
			cAuxParc := Substr( cParcela, nI, 1)
			lCharVal := ( Asc(cAuxParc) >= 48 .AND. Asc(cAuxParc) <= 57) .OR. ( Asc(cAuxParc) >= 65 .AND. Asc(cAuxParc) <= 90) 
		EndDo
	
	
		If lCharVal //Caracteres v�lidos
		
			// verifica a exist�ncia da vari�vel static com o conte�do para De x Para
			If ( Valtype(aDePara) == "U" .OR. Len(aDePara) == 0 )
				LoadDePara( cTipo, nTamCampo )
			EndIf
				
			nRetParc := aScan( aDePara, {|x| x[1]==cParcela } ) 
			
			Do While nTamCampo > 1 .AND. nRetParc == 0 .AND. Len(aDePara) <= 400 
				LoadDePara( cTipo, nTamCampo ) //Adiciona mais 100 posi��es 
				nRetParc := aScan( aDePara, {|x| x[1]==cParcela } ) 
			EndDo 
			
			If nRetParc  > 0
				nRetParc := aDePara[nRetParc, 2]  
			Else
				nRetParc := 1
			EndIf 
			
		EndIf

	Else 
		If cTipo == "A"
			// sequenciamento alfa, chr(k) at� o fim!
			nRetParc := Asc(cParcela) - 64 
		Else
			
				// trata de forma gen�rica o sequenciamento n�merico, independente do tamanho do campo
			If nTam > 1 .OR. (nValParc > 0 .AND. nValParc <= 9 )
				nRetParc := nValParc   
			Else 
				Do Case
				  Case Asc(cParcela) >= 65 .AND. Asc(cParcela) <= 90
				    nRetParc := Asc(cParcela) - 55
				  Case Asc(cParcela) >= 97 .AND. Asc(cParcela) <= 122
				  	nRetParc := Asc(cParcela) - 61
				  Otherwise
				    nRetParc := 1
				EndCase
			EndIf
		EndIf
	EndIf
	
Return nRetParc

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LoadDePara�Autor  �Protheus            � Data �  03/27/12   ���
�������������������������������������������������������������������������͹��
���Desc.     � Fun��o para carregar array com as indica��es das parcelas  ���
���          �na refer�ncia alfa                                          ���
�������������������������������������������������������������������������͹��
���Sintaxe   � LoadDePara( ExpC1 ) -> NIL                                 ���
�������������������������������������������������������������������������͹��
���Parametros�ExpC1 - Tipo do sequenciamento da parcela                   ���
���          � A = sequencia alfa                                         ���
���          � 1 = sequencia num�rica                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function LoadDePara ( cTipo, nTamCampo )

	Local nI := 0        //Vari�vel contadora
	Local cAux := 0      //Variavel com a sequencia gerada
	Local nAte := 0      //Variavel limite de intera��o
	Local nDe := 0       //Variavel inicial de interacao
	
	Default cTipo := "A"
	Default nTamCampo :=  TamSx3("E1_PARCELA")[1]
	
	If ValType(aDePara) == "U"
		aDePara := {}
	EndIf
	
	If Len(aDePara) > 0
		cAux := aTail(aDePara)[1]
		nDe := aTail(aDePara)[2] 
		nAte := nDe + 100  
		aSize(aDePara, nAte)
	Else
		cAux := cTipo
		nDe := 1
		nAte := IF(nTamCampo = 1, 27 + IIF(RTrim(cTipo) == "1",9,0) ,100)
		aDePara := Array(nAte)
		aDePara[1] := {cTipo, 1}
	EndIf  
	
	nDe := nDe + 1
	
	For nI := nDe  to nAte  
		cAux := MaParcela(cAux)
		aDePara[nI] := {cAux, nI}
	Next nI 
	
	
Return NIL