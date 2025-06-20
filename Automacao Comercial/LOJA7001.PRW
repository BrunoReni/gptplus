#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "MSOBJECT.CH"
#INCLUDE "LOJA7001.CH"


Function LOJA7001; Return  // "dummy" function - Internal Use

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Classe    �LJCClaDes       �Autor  �Vendas Clientes     � Data �  15/10/07   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Classe responsavel em manipular um arquivo.                   	 ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
Class LJCClaDes
	
	Data oDadosCDes							//Nome do arquivo
	Data oDlg									//Objeto controla a tela de Motivo de Desconto
	Data cCodigo								//Var do codigo de motivo
	Data oCodigo                            	//Objeto do codigo de motivo
	Data cObs 									//Var do obs de motivo
	Data oObs 									//Objeto do obs de motivo
	Data cDesMotDes 							//Descricao Motivo de desconto
	Data cDescricao 							//Descricao Motivo de desconto
	Data oDescricao 							//Objeto da Descricao Motivo de desconto

	
	
	Method New( )								//Metodo construtor
	Method ChamaTela(n) 						//Metodo que ira abrir o arquivo
	Method AddValida( )                     	//Adiciona Motivo  
	Method RmValida(n)                     	//Remove  Motivo  
	Method AltValida(n)                		//Altera motivo 
	Method ValidaMt(n, lRet)	            //Valida Motivo
	Method ValidaCod()                	    //Valida codigo
	Method ValidaObs()						//Valida Observacao

EndClass

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �New       �Autor  �Vendas Clientes     � Data �  15/10/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Construtor da classe LJCClaDes. 				              ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�	  			                                              ���
���          �          			                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method New( ) Class LJCClaDes
	
	Self:cCodigo		:= Space(Len(MDT->MDT_CODIGO)) 
	Self:cObs 			:= Space(Len(MDT->MDT_DESCRI)) 
	Self:oCodigo   		:= Nil
	Self:oDescricao		:= Nil
	Self:oObs      		:= Nil
	Self:cDesMotDes 	:= ""
	Self:cDescricao	:= ""
		
	Self:oDadosCDes 	:= LJC_DadosCDes():New()

Return()

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �ChamaTela �Autor  �Vendas Clientes     � Data �  15/10/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Chama tela de classificacao de desconto                     ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�	  			                                              ���
���          � 			                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method ChamaTela(n) Class LJCClaDes
	
	Local lRet := .F. 	// retorno
	
	Default n := 0		//Numero do Registro
	
	DEFINE MSDIALOG Self:oDlg FROM 0,0 TO 160,400 TITLE STR0001 PIXEL //"Motivo de Desconto" 
	
			@ 08,08 SAY STR0002 SIZE 35,15 PIXEL OF Self:oDlg   //"Motivo de Desconto"
			@ 10,43 MSGET Self:oCodigo VAR Self:cCodigo SIZE 40,9 PIXEL F3 "MDT" OF Self:oDlg PICTURE PesqPict("MDT", "MDT_CODIGO") ;
			Valid Self:ValidaCod()
			
			@ 23,08 SAY STR0003 SIZE 35,15 PIXEL OF Self:oDlg   //"Obs de Desconto"
			@ 25,43 MSGET Self:oDescricao VAR Self:cDescricao When .F. SIZE 140,09 PIXEL OF Self:oDlg
					
			DEFINE SBUTTON               FROM 50,132 TYPE 01 ENABLE OF Self:oDlg ACTION Self:ValidaMt(n, @lRet) 
			DEFINE SBUTTON               FROM 50,170 TYPE 02 /*ENABLE*/ OF Self:oDlg ACTION Self:oDlg:End()
			
	ACTIVATE MSDIALOG Self:oDlg CENTERED
	
	if ! lRet															
		Self:cCodigo := Space(Len(MDT->MDT_CODIGO))				
	Else
		
	Endif																
Return(lRet)															



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �AddValida �Autor  �Vendas Clientes     � Data �  15/10/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Chama tela de classificacao de desconto                     ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�	  			                                              ���
���          �                                           			      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method AddValida(n) Class LJCClaDes

	Local oDados := Nil // dados 
	Local nPosProd	:= aPosCpo[Ascan(aPosCpo,{|x| Alltrim(Upper(x[1])) == "LR_PRODUTO"})][2] 		// Posicao da codigo do produto	
	
	If n == 99999
		oDados := LJCDadosDes( ):New(n , Self:cCodigo, AllTrim(Self:cDescricao) + ' - ' + Self:cObs, '') // Dados
	Else
		oDados := LJCDadosDes( ):New(n , Self:cCodigo, AllTrim(Self:cDescricao) + ' - ' + Self:cObs, aCols[n][nPosProd]) // Dados
	EndIf
	
	Self:oDadosCDes:Add(oDados:nItem, oDados)
	
    Self:cCodigo		:= Space(Len(MDT->MDT_CODIGO)) 
	Self:cObs 			:= Space(Len(MDT->MDT_DESCRI)) 
	Self:cDesMotDes 	:= ""
	Self:cDescricao	:= ""

Return(.T.)



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �AddValida �Autor  �Vendas Clientes     � Data �  15/10/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Chama tela de classificacao de desconto                     ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�	  			                                              ���
���          �                                           			      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method RmValida(n) Class LJCClaDes
    
	Default n := 0  	// Numero de Registros
	
	If Self:oDadosCDes:Contains(n)
	 	
	 	Self:oDadosCDes:ElementKey(n):lAtivo := .F.
    
    EndIf

Return(.T.)
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �AltValida �Autor  �Vendas Clientes     � Data �  15/10/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Chama tela de classificacao de desconto                     ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�	  			                                              ���
���          �                                           			      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method AltValida(n) Class LJCClaDes

	Default n := 0				// Numero de Registro
	
	Self:oDadosCDes:ElementKey(n):cCodigo	:= Self:cCodigo
	Self:oDadosCDes:ElementKey(n):cObs 		:= Self:cDescricao + ' - ' + Self:cObs
	// Na alteracao do desconto, n vem igual 99999, sendo uma posicao que nao existe no Array
	If n <> 99999
	Self:oDadosCDes:ElementKey(n):cProduto  := aCols[n][aPosCpo[Ascan(aPosCpo,{|x| Alltrim(Upper(x[1])) == "LR_PRODUTO"})][2]]
	EndIf	
	Self:oDadosCDes:ElementKey(n):lAtivo 	:= .T.
	
	
	Self:cCodigo		:= Space(Len(MDT->MDT_CODIGO)) 
	Self:cObs 			:= Space(Len(MDT->MDT_DESCRI)) 
	Self:cDesMotDes 	:= ""
	Self:cDescricao		:= ""


Return(.T.)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �AltValida �Autor  �Vendas Clientes     � Data �  15/10/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Chama tela de classificacao de desconto                     ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�	  			                                              ���
���          �                                           			      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method ValidaMt(n, lRet) Class LJCClaDes

	Default n 	 	:= 0	 	// Numero de registro 
	Default lRet  	:= .F.		// Retorno 
	
	If !Self:ValidaCod()
		Return(.F.)
	ElseIf !Self:ValidaCod()
		Return(.F.)
	Else
	
		If Self:oDadosCDes:Contains(n)
			
			Self:AltValida(n)
		
		Else
		
			Self:AddValida(n)
	
		EndIf
	    
		lRet := .T.
		
		Self:oDlg:End()
		
	EndIf	

	

Return()


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �ValidaCod �Autor  �Vendas Clientes     � Data �  15/10/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Chama tela de classificacao de desconto                     ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�	  			                                              ���
���          �                                           			      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method ValidaCod() Class LJCClaDes
	Local lRet := 	.T.

DbSelectArea('MDT')
	DbSetOrder(1)
	
	If !DbSeek(xFilial("MDT")+Self:cCodigo)
    	lRet := 	.F.
    	Alert(STR0004) // "Codigo Inexistente"
	Else 
		Self:cDescricao := MDT->MDT_DESCRI
	EndIf    
                      
Return lRet
                       
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �ValidaObs �Autor  �Vendas Clientes     � Data �  15/10/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Chama tela de classificacao de desconto                     ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�	  			                                              ���
���          �                                           			      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method ValidaObs() Class LJCClaDes

	Local lRet := .T.		// Retorno
	
	If Len(Trim(Self:cObs)) < 5 
		lRet := 	.F.
		Alert(STR0005) // "Observacao Invalida"
	EndIf
	
Return lRet
