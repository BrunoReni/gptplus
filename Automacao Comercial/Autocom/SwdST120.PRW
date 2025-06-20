#INCLUDE "PROTHEUS.CH"   

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
��� Classe   � LJSwedaTER �Autor  � Vendas Clientes    � Data �  MAR/09     ���
���������������������������������������������������������������������������͹��
���Descricao � Classe da impressora Sweda ST120 para a biblioteca AUTOCOM  	���
���������������������������������������������������������������������������͹��
���Uso       � Todos os produtos de Automacao Comercial - bibl. AUTOCOM   	���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/   

CLASS  LJSwedaTER  FROM LJSweda9000 
	//���������Ŀ
	//�Atributos�
	//�����������

	//���������Ŀ
	//�Metodos  �
	//����������� 
	METHOD New()
	METHOD IFAbrCNFis( cCondicao, cValor, cTotalizador, cTexto, nParcelas )//retorna caracter	   
	METHOD IFSupr(nTipo,cValor,cForma,cTotal,nModo)//reorna caracter
	METHOD IFRecbNFis(cTotalizador, cValor, cForma)	
	METHOD IFPegCupom(cCancelamento)	
ENDCLASS
//-------------------------------------------------------------
METHOD New() CLASS LJSwedaTER    
Return

//----------------------------------------------------------------------------    

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �IFAbrCNFis�Autor  �Vendas Clientes     �Data  �  MAR/09 	  ���
�������������������������������������������������������������������������͹��
���Desc.     �Abre um comprovante Vinculado ou nao fiscal Vinculado       ���
�������������������������������������������������������������������������͹��
���Uso       �SIGALOJA / FRONTLOJA, interfaces de venda  - Autocom.dll    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

METHOD IFAbrCNFis( cCondicao,cValor,cTotalizador,cTexto,nParcelas) CLASS LJSwedaTER
Local cRet := ""
Local cNumAnt := ""
Local nI := 0
Local aFormas := {}
Local cFormas := ""
Local cPos := ""
Local cPosTot := ""
Local nPos := 0
Local nTamanho := 0
Local cRetorno := ""
Local nVz := 0
Local lContinua := .T.
Local cTotFormaPagto := ""
Local cTotRecIni := ""
Local cDescTot   := ""     
Local cRecebTot   := ""
  

Conout("SWEDA Termica ST120 NIX  - METHOD IFAbrCNFis - Inicio - "+ Time() )

If AllTrim(cTotalizador)= "" 
    cTotalizador := "SIGALOJA"
Endif

If Val(cCondicao) <= 0   


Endif
cTotRecIni := GetPvProfString("Recarga Celular", "Totalizador", "", GetClientDir()+"SIGALOJA.INI")  
cRecebTot  := GetPvProfString("Receb. Contas", "Totalizador", "", GetClientDir()+"SIGALOJA.INI")  
nVz := 1
While nVz <= 5 .AND. lContinua
    //���������������������������������Ŀ
    //�Pegando o numero do ultimo cupom �
    //�impresso							�
    //�����������������������������������           
	cNumAnt := ::EnviaComando( Chr(27)+".271}")// Metodo da classe SWEDA 	
	If SubStr( ::TrataRetorno(1,cNumAnt),1,1 ) = "0"// Metodo da classe SWEDA 
	   cNumAnt := SubStr(cNumAnt,14,4)
	   lContinua := .F.
	Else
	   nVz++
	Endif

	If nVz > 5 .AND. lContinua
		Return 1
	Endif

End     
//���������������������������������Ŀ
//�Monta vetor com formas existentes�
//�����������������������������������          
cRet  := ::FormasPgto   
While (At("|", cRet) > 0) 
   nPos := At("|", cRet)
   cFormas := SubStr(cRet, 1, nPos-1)
   AAdd(aFormas,cFormas)
   cRet := SubStr(cRet, nPos+1, Len(cRet))
End
//���������������������������������Ŀ
//�Verificando qual o codigo da 	�
//�condicao de pagamento utilizado	�
//�����������������������������������          
cPos := "0"   
VarInfo("aFormas",aformas)
For nI := 1 to Len(aFormas) 
   If Upper(AllTrim(aFormas[nI])) = Upper(AllTrim(cCondicao)) 
     cPos := AllTrim(Str(nI))
   Endif  
Next nI  
If Len(cPos) < 2 
  cPos := "0" + cPos
Endif  
cTotFormaPagto := cPos  

//���������������������������������Ŀ
//�Abrindo cupom nao fiscal 		�
//�vinculado "00"					�
//�����������������������������������           

If (cTotRecIni <> cTotalizador) .AND. cTotalizador <> cRecebTot
    cRet := ::EnviaComando( Chr(27)+".1900"+cNumAnt+cPos+Space(20)+StrZero(nParcelas,2)+"}")// Metodo da classe SWEDA 
    cRetorno := ::TrataRetorno( 1,cRet )// Metodo da classe SWEDA	    
	If SubStr(cRet,1,2) <> ".+"
		cNumAnt := AllTrim(StrZero(Val(cNumAnt)-1, 4 ) ) 
		//���������������������������������Ŀ
		//�Abrindo cupom nao fiscal 		�
		//�vinculado "00"					�
		//�����������������������������������
		cRet := ::EnviaComando( Chr(27)+".1900"+cNumAnt+cPos+Space(20)+StrZero(nParcelas,2)+"}")// Metodo da classe SWEDA 
		cRetorno := ::TrataRetorno( 1,cRet )// Metodo da classe SWEDA			
	EndIf
Else
	cRetorno := '1'   	
EndIf 
If SubStr(cRetorno,1,1) = "1" // Impressao do Cupom nao fiscal nao vinculado
	cRet    := " -"
	cValor  := FormataTexto(AllTrim(cValor),12,2,2)
	cRet    := "789ABCD"
	cFormas := ""
    For nI := 1 to 7
		cPos     := ::EnviaComando( Chr(27)+".29"+SubStr(cRet,nI,1)+"}")// Metodo da classe SWEDA
		nTamanho := Len(cPos)
		cFormas  := cFormas+SubStr(cPos,8,nTamanho)
	Next nI
	
	cFormas := SubStr(cFormas,31,Len(cFormas))
	aFormas := {}
	While AllTrim(cFormas) <> ""
		AAdd(aFormas, SubStr(cFormas,1,15))
		cFormas := SubStr(cFormas,16,Len(cFormas))
	End  
	If Val(cTotalizador) > 0//== "C"
		bTotalizadorIsNum := .T.
	Else
		bTotalizadorIsNum := .F.
	EndIf
	cPos       := "0"
	cPosTot    := "0"
	
	For nI := 1 to Len(aFormas)
		//��������������������������������������������������������������������������������Ŀ
		//�Inicializando o TOTALIZADOR para que sPos nao pegue uma legenda de outro Titulo.�
		//�Pois a legenda somente podera ser do mesmo titulo.                              �
		//�Ex.                                                                             �
		//�01 &GAVETA                -> Titulos                                            �
		//�02    + Recebimento       -> Legendas                                           �
		//�03    - Sangria           -> Legendas                                           �
		//�04 &Sigaloja              -> Titulos                                            �
		//�05    + Entrada Diversas  -> Legendas                                           �
		//�06    - Saidas diversas   -> Legendas                                           �
		//����������������������������������������������������������������������������������
		If bTotalizadorIsNum
			cPos  := cTotalizador
			If SubStr(aFormas[nI],1,1)="&"
				cPosTot:= FormataTexto(Str(nI),2,0,2)
			EndIf
			If FormataTexto(AllTrim(Str(nI)),2,0,2) = AllTrim(cPos)
				Exit
			Else
				cPos := "0"	
			EndIf
		Else 
	    	If SubStr(aFormas[nI],1,1)="&"
				cPosTot:= FormataTexto(Str(nI),2,0,2)			
			ElseIf AllTrim(Upper(SubStr(aFormas[nI],2,15))) == AllTrim(Upper(cTotalizador))
				cPos := FormataTexto(Str(nI),2,0,2)
				Exit			
			EndIf				
		EndIf

	Next nI
    
     
	If cPos == "0"
		Alert("Totalizador " + cTotalizador + " n�o encontrado na Impressora Fiscal")
		cRet := "1"	
	Else
	   	//���������������������������������Ŀ
		//�Abre o cupom n�o vinculado		�
		//�����������������������������������		 
		cDescTot  := SubStr(Alltrim(UPPER(cTotalizador)),1,7)
		If cDescTot == "RECARGA"  
		    //���������������������������������Ŀ
		    //�TRATAMENTO PARA A RECARGA 	    �
		    //�����������������������������������		    
		   	cPosTot := aScan(aFormas,{|X|X == cDescTot} )	   				
		Elseif cTotalizador == cRecebTot  		    
		    cPosTot := cTotalizador    	
		EndIf		
		If Len(AllTrim(cPos)) < 2
			cPos := "0" + AllTrim(cPos)
		EndIf
		If Len(AllTrim(cPosTot)) < 2
			cPosTot := "0" + AllTrim(cPosTot)
		EndIf
		oAutocom:cBuffer := Space(128) 
		//�����������������������������������Ŀ
	    //�Abertura do Comprovante nao Fiscal �
	    //�������������������������������������		
		cRet := ::EnvCmdEspera( Chr(27) +".19" + AllTrim(cPosTot) + "      }" )  	
		If cRet = "0"
			//���������������������������������Ŀ
			//�Faz o recebimento nao fiscal		�
			//�����������������������������������		
			//���������������������Ŀ
	        //� Soma dos Valores    �
	        //�����������������������	 
	       	oAutocom:cBuffer := Space(128)  	
			cRet := ::EnvCmdEspera( Chr(27) +".07" + AllTrim(cPos) + cValor + "}", 3 ) 		
			If cRet = "0"
				//���������������������������������Ŀ
				//�Faz o recebimento nao fiscal		�
				//�����������������������������������
				oAutocom:cBuffer := Space(128)  			
				cRet := ::EnvCmdEspera( Chr(27) +".10" + cTotFormaPagto + cValor+"}", 3 )  							
				If cRet = "0"
					//���������������������������������Ŀ
					//�Fecha o cupom indicando que 		�
					//�havera' um vinculado				�
					//�����������������������������������
					oAutocom:cBuffer := Space(128) 					
					cRet := ::EnvCmdEspera( Chr(27) +".12N}", 3 )
					If cRet = "0"
						oAutocom:cBuffer := Space(128)						
						cRet := ::EnvCmdEspera( Chr(27) +".271}", 10 )
						If cRet = "0"
							cNumAnt := SubStr( ::cBuffer, 14, 4 )
							oAutocom:cBuffer := Space(128)						
							cRet := ::EnvCmdEspera( Chr(27) +".1900"+cNumAnt+cTotFormaPagto+Space(20)+"01}", 10 ) 
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf	
	oAutocom:cBuffer := cRet
	nRet := Val(::TrataRetorno( 1, oAutocom:cBuffer ))
EndIf
If cDescTot == "RECARGA"                                   
	Conout("SWEDA Termica ST120 NIX - METHOD Comando da Gaveta - "+ Time() )   
    cComando := ::EnvCmdEspera( Chr(27) + ".21"+"}" ) //abre gaveta de Dinheiro 	
EndIf	
Conout("SWEDA Termica ST120 NIX - METHOD IFAbrCNFis - Termino - "+ Time() )
Return Val(cRet)

//----------------------------------------------------------------------------     

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �IFSupr    �Autor  �Vendas Clientes     �Data  �  MAR/09 	  ���
�������������������������������������������������������������������������͹��
���Desc.     �Suprimento Variacao do tipo   	                          ���
���          �Tipo = 1 - Verifica se tem troco disponivel				  ���
���          �Tipo = 2 - Grava o valor informado no Suprimentos			  ��� 
���          �Tipo = 3 - Sangra o valor informado						  ���
�������������������������������������������������������������������������͹��
���Uso       �SIGALOJA / FRONTLOJA, interfaces de venda  				  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

METHOD IFSupr(nTipo,cValor,cForma,cTotal,nModo) CLASS LJSwedaTER

Local cRet 		:= ""
Local nI   		:= 0
Local aFormas 	:= {}
Local cFormas 	:= ""
Local cPos 		:= ""
Local nTamanho  := 0
Local cCondicao := ""
Local aPgto 	:= {}
Local cRetorno  := ""

Conout("SWEDA Termica ST120 NIX - METHOD IFSupr - Inicio - "+ Time() )
    					
cRet := " -"
cCondicao := cForma
cValor    := FormataTexto(cValor,12,2,2)
cRet      := "789ABCD"
cFormas   := ""

//���������������������������������Ŀ
//�Verifica se tem troco disponivel	�
//�����������������������������������
If nTipo = 1 
	cRet    :="67"
    For nI  := 1 to 2 
	  //���������������������������������Ŀ
	  //�Lendo os totais das modalidades  �
	  //�de pagamento					  �
	  //�����������������������������������
      cPos     := ::EnviaComando( Chr(27)+".27"+SubStr(cRet,nI,1)+"}")// Metodo da classe SWEDA 
      nTamanho := (At("}",cPos)-1) - 7
      If nI = 2 
        cFormas  := cFormas+SubStr(cPos,8,48)
      Else
        cFormas  := AllTrim(SubStr(cPos,8,nTamanho))
      Endif
      
      While AllTrim(cFormas) <> "" 
        AAdd(aFormas, SubStr(cFormas,5,12))
        cFormas := SubStr(cFormas,17,Len(cFormas))        
      End
    Next nI  
    
    //���������������������������������Ŀ
    //�Le as condicoes de pagamento		�
    //�����������������������������������
    cRet := ::IFLeConPag()//Metodo da classe SWEDA
    cRet := SubStr(cRet, 3, Len(cRet))
    aPgto := MontArray(cRet)
    
    For nI := 1 to Len(aPgto)
	  If Upper(AllTrim(aPgto[nI]))="DINHEIRO" 
        cPos:=Str(nI)
        Exit
      End
    Next nI
    
    If Val(aFormas[Val(sPos)]) >= Val(Valor)
      Return "8"
    Else
      Return "9" 
    Endif
Else
	cFormas :="DINHEIRO"
	If AllTrim(SubStr(cForma,3,Len(cForma))) <> "" 
		cFormas := AllTrim(SubStr(cForma,3,Len(cForma)))
	Endif
    //���������������������������������Ŀ
    //�Grava o valor informado no 		�
    //�Suprimentos						�
    //�����������������������������������	  
	If (nTipo = 2) .AND. (AllTrim(cForma) = "") 
		cCondicao:="SUPRIMENTO"
	Endif  
    //���������������������������������Ŀ
    //�Sangra o valor informado			�
    //�����������������������������������	  	  
	If (nTipo = 3) .AND. (AllTrim(cForma) = "")
		cCondicao:="SANGRIA"
	Endif
	If ( AllTrim(SubStr(cForma,1,2)) <> "") .AND. (AllTrim(SubStr(cTotal,1,2)) <> "")
		cPos := SubStr(cForma,1,2) + SubStr(cTotal,1,2)
	Else
		cCondicao := LOWER(cCondicao)
		cPos := GetPvProfString(cCondicao, "totalizador", "01", GetClientDir()+"SIGALOJA.INI")
		cPos := cPos + cPos		
	Endif   
	
	If (AllTrim(SubStr(cTotal,1,2)) = "") .AND. ((SubStr(cPos,1,2) = "00") .OR. (SubStr(cPos,3,2) = "00")) 
	    MsgStop("N�o existe o Totalizador N�o-Fiscal "+cCondicao+;
	      		'" dentro do T�tulo N�o-Fiscal "SIGALOJA".'+Chr(13)+'Adicione-o ap�s uma Redu��o Z e antes de realizar uma venda.')
	    cRetorno := "1"
	Else
		cRet := ::EnviaComando( Chr(27)+".19" + SubStr(cPos,3,2)+ Space(26)+"00}")// Metodo da classe SWEDA 
		cRetorno := ::TrataRetorno( 1,cRet )// Metodo da classe SWEDA
		Sleep(2000) 
		If SubStr(cRetorno,1,1) = "0" 
			cRet := ::EnviaComando( Chr(27)+".07" + SubStr(cPos,1,2)+cValor+"}")// Metodo da classe SWEDA 
		    cRetorno := ::TrataRetorno( 1,cRet )// Metodo da classe SWEDA
		    If SubStr(cRetorno,1,1) = "0"
		      Sleep(500)
		      If nTipo = 2
				cValor   := AllTrim(Str(Val(cValor)))
		        ::IFPagto(cFormas+"|"+cValor,"N")
		        Sleep(500)
		      Endif
		    Endif
		    cRet := ::EnviaComando( Chr(27)+".12N}")// Metodo da classe SWEDA 
		    Sleep(2000) 
		    cRetorno := ::TrataRetorno( 1,cRet )// Metodo da classe SWEDA
		Endif
	Endif
Endif

Conout("SWEDA Termica ST120 NIX - METHOD IFSupr - Termino - "+ Time() )

Return Val(cRetorno)   

//----------------------------------------------------------------------------   

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �IFRecbNFis�Autor  �Vendas Clientes     �Data  �  MAR/09 	  ���
�������������������������������������������������������������������������͹��
���Desc.     �Abre um comprovante nao fiscal	                          ���
�������������������������������������������������������������������������͹��
���Uso       �SIGALOJA / FRONTLOJA, interfaces de venda  - Autocom.dll    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

METHOD IFRecbNFis(cTotalizador, cValor, cForma) CLASS LJSwedaTER
Local cRet     				//Retorno na impressora
Local cRetorno	:= ""	 	// Retorno da fun��o
Local cPos
Local nVz 		:= 0   	 	// Controle de laco

Conout("SWEDA Termica ST120 NIX - METHOD IFRecbNFis - Inicio - "+ Time() )
If UPPER(cForma) == "RECEB. CONTAS"      
	Return 0
EndIf
//��������������������������������������������������������������������������������������������Ŀ
//�Tem que escrever no SIGALOJA.INI o acumulador que vai ser utilizado para o recebimento. 	   �
//�Ex.:																						   �
//�                                                                                            �
//�[Recebimento Titulos]                                                                       �
//�Totalizadores=RECEBIMENTO                                                                   �
//�                                                                                            �
//�Esse totalizador dever� estar abaixo do t�tulo &SIGALOJA.                                   �
//�Ex.:                                                                                        �
//�                                                                                            �
//�04 &SIGALOJA              -> Titulos                                                        �
//�05    + FUNDO DE CAIXA    -> Legendas                                                       �
//�06    + RECEBIMENTOS      -> Legendas                                                       �
//����������������������������������������������������������������������������������������������

    //���������������������������������Ŀ
    //�A forma de pagamento a ser 		�
    //�utilizada nesse comprovante, 	�
    //�sera' a apontada no parametro 	�
    //�MV_NATRECEB						�
    //�����������������������������������  		

    //���������������������������������Ŀ
    //�Inicializada a variavel 			�
    //�nUltimoSeq						�
    //�����������������������������������  		
	::nUltimoSeq := 1 
    cValor   :=FormataTexto(AllTrim(cValor),12,2,2)
	//���������������������������������Ŀ
	//� Faz um controle de 5 tentativas �
	//� para registrar o recebimento 	�
	//�����������������������������������
	While nVz <= 5 .AND. SubStr(cRetorno,1,1) <> "0"
	    cCondicao := LOWER(cForma)
	    cPos := GetPvProfString(cForma, "totalizador", "01", GetClientDir()+"SIGALOJA.INI")
	    cPos := cPos + cPos      
	    cRet := ::EnviaComando( Chr(27)+".19" + SubStr(cPos,3,2)+ "      " + Space(20) + "}")
	    cRetorno := ::TrataRetorno( 1,cRet )
	    if SubStr(cRetorno,1,1) = "0"
	       Sleep(2000) //2000
	       cRet := ::EnviaComando( Chr(27) + ".07" + SubStr(cPos,1,2) + cValor + "}")
	       cRetorno := ::TrataRetorno( 1,cRet )
	       Sleep(500)
	       cValor := AllTrim(cValor)
	
	       cRet:=::IFPagto(cForma+"|"+cValor,"N")
	
	       if SubStr(cRetorno,1,1) = "0" 
	          cRet := ::EnviaComando( Chr(27)+	".12}")
	          Sleep(2000)
	          cRetorno := ::TrataRetorno( 1,cRet )
	       Endif
	    Endif   
	    
	    nVz ++ 
	    Sleep(1000) 
	End
	    
Conout("SWEDA Termica ST120 NIX - METHOD IFRecbNFis - Termino - "+ Time() )
	    
Return (Val(cRetorno))

//-------------------------------------------------------------
METHOD IFPegCupom(cCancelamento) CLASS LJSwedaTER
Local nRet		:= 1
Local cRet
Local cComando   

Conout("SWEDA Termica ST120 NIX - METHOD IFPegCupom - Inicio - "+ Time() )   

If cCancelamento == "T"     
	cComando := Chr(27)+".28}"
	cRet := SubStr(::EnviaComando(cComando),11,8) 
	If cRet <> " VENDAS "
		oAutocom:cBuffer := "0000"   
		Return(0)
	EndIf
EndIf
    
cComando := Chr(27)+".27H}"
cRet := ::EnviaComando(cComando)
nRet := ::TrataRet(cRet)
If nRet == 1
	cComando := Chr(27)+".27H}"
	cRet := ::EnviaComando(cComando)
	nRet := ::TrataRet(cRet)
	If nRet == 1
		MsgStop("Erro ao Ler o Numero do Cupom no ECF.") 
		oAutocom:cBuffer := "0000"
	EndIf
EndIf 
If nRet == 0
	oAutocom:cBuffer := SubStr(cRet,73,6)+"  "
EndIf	                                                            	



Conout("SWEDA Termica ST120 NIX - METHOD IFPegCupom - Termino - "+ Time() )

Return(nRet)
	