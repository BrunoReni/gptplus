#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "MSOBJECT.CH"

Function LOJA761; Return  // "dummy" function - Internal Use

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Classe    �LJCMultNeg       �Autor  �Vendas Clientes     � Data �  15/10/10   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Classe responsavel em manipular um arquivo.                   	 ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
Class LJCMultNeg
	
	Data oDadosMult								
	Data oDlg									
	Data nItem
	Data cCodigo
	Data cItemNeg
	Data cProduto
	Data cFormPag
	Data cAdm
	Data nPacelar
	Data nValor
	Data oDados
	Data oDadosCab
	Data oDadosIten
	Data oPagts
	Data oRetPagMn    
	Data nNcc
	Data nDescont 	
	Data nValEnt

	Method New( )								//Metodo construtor
	Method GetMultNeg(aItens)                        	//Altera motivo 
	Method TrataRetNeg(oGetIdMn)				//Trata retorno Cab
	Method TratReIten(cCodigo)					//Trata retorno Iten
	Method ValidaNeg(cCodPro, cCodGru)			//Filtra Negocia��o     
	Method IdProd(cCodPro, cCodGru)				//Identifica produto
	Method SetValor(nValor)						//Informa o valor da Multi negcocia��o 
	Method GetValor()							//Retorno o valor informado
	Method SetValNcc(nNcc)						//Seta valor da Ncc
	Method GetValNcc()							//Retorna Valor da Ncc 
	Method RmNeg()								//rEMOVE nEGOCIA��O 		
	Method AddMnPad()							//Adiciona Mn Padrao 
	Method GetDescont()							//Adiciona Mn Padrao 
	Method SetDescont()							//Adiciona Mn Padrao 	
	Method GetVEntrad()							//retorna o Valor de Entrada
	Method SetVEntrad()							//Seta o valor de Entrada

EndClass

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �New       �Autor  �Vendas Clientes     � Data �  15/10/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Construtor da classe LJCClaDes. 				              ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method New( ) Class LJCMultNeg
	
	Self:cCodigo		:= Space(3)
	Self:oDadosCab 	 	:= LJC_CabRetNeg():New() 
	Self:oPagts			:= LJCPagtsMn():New() 
	Self:oRetPagMn		:= LJCRetPagMn():New() 	
	Self:nValor			:= 0
	Self:nDescont		:= 0 
	Self:nValEnt       := 0

Return()
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �GetMultNeg�Autor  �Vendas Clientes     � Data �  15/10/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Chama Retorna Muli Negocia��o                               ���
�������������������������������������������������������������������������͹��
���Parametros�aExp1 - Produtos											  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetMultNeg(aItens) Class LJCMultNeg

	Local cRet := "" 			// Retorno da base de dados
	Local oRet := Nil			// Retorno tratado do Method
	Local cGrupoProd := ""		// Grupo de Produto	
	Local aBkArea := GetArea()	// Backup da area
	Local nX := 0				// Contador 			
	Local cProduto 		:= ""	// Produto		
	Local nValPro		:= 0	// Valor to item
	Local nPosProd		:= 0 	// Posicao da codigo do produto
	Local nPosVlrItem   := 0 	// Posicao do Valor Total do Item	
	Local nNumItens		:= 1	// Numero do itenns ser verificado
	Local cCodGru		:= "" 	// Grupo
	//As vari�veis lEmitNfce - alimentada pela rotina LjEmitNFCe, lFtvdVer12 - alimentada pela rotina - LjFTVD() e cNomeProg - alimentada pela vari�vel  lFtvdVer12  tiveram seu escopo alterado para vari�veis locais, pois o cliente pode mudar de modulo para o SigaFAT atrav�s do SIGAADV e essas vari�veis mudam o seu valor conforme o m�dulo
	Local lFtvdVer12	:= LjFTVD()	//Verifica se � Release 11.7 e o FunName � FATA701 - Compatibiliza��o Venda Direta x Venda Assisitida
	
	Default aItens		:= {}
	
	If nModulo == 12 .OR. lFtvdVer12	
		nPosProd	:= aPosCpo[Ascan(aPosCpo,{|x| Alltrim(Upper(x[1])) == "LR_PRODUTO"})][2]	// Posicao da codigo do produto
		nNumItens	:= Len(aCols)
	Else
		nNumItens	:= Len(aItens)
	EndIf	                 
	
	
	//�����������������Ŀ
	//�Adiciona os Itens�
	//�������������������
	For nX := 1 To nNumItens
			cProduto 	:= ""
			If nModulo == 12 .OR. lFtvdVer12
				If !aCols[nX][Len(aCols[nX])]
					cProduto 	:= aCols[nX][nPosProd]		
				EndIf	
	   		Else
	   			cProduto :=	aItens[nX][3]
	   		EndIf
		
			If!Empty(cProduto)
				Self:IdProd(cProduto, @cCodGru)
				
				oRet := Self:ValidaNeg(cProduto, cCodGru)
				
				                                                
				If oRet:Count() > 0  
					Self:TrataRetNeg(oRet)
				EndIf                                                          
				
				cCodGru		:= ""
				oRet		:= Nil
			EndIf	
	Next nX
	
	//���������������Ŀ
	//�Remove os Itens�
	//�����������������
	For nX := 1 To nNumItens
		cProduto := ""
		If nModulo == 12 .OR. lFtvdVer12
			If !aCols[nX][Len(aCols[nX])]
				cProduto 	:= aCols[nX][nPosProd]		
			EndIf	
   		Else
   			cProduto :=	aItens[nX][3]
   		EndIf
		
		If!Empty(cProduto)
			Self:IdProd(cProduto, @cCodGru)
			
			Self:RmNeg(cProduto, cCodGru)
			
			cCodGru		:= ""
			oRet		:= Nil
		EndIf
	Next nX	
	
	//��������������������������������Ŀ
	//�Adiciona Multi Negocia��o Padr�o�
	//����������������������������������
	DbSelectArea("MBS")
	MBS->( DbSetOrder(4) )	//MBS_FILIAL + MBS_PADRAO
	MBS->( DbSeek(xFilial("MBS") + "1") )
	
	MA7->( !EOF() )

	While MBS->( !EoF() ) .AND. MBS->MBS_FILIAL + MBS->MBS_PADRAO ==  xFilial("MBS") + "1"
		oRet := Self:AddMnPad()
		If oRet:Count() > 0  
			Self:TrataRetNeg(oRet)
		EndIf                                                          
		MBS->( DbSkip() )
	End

	RestArea(aBkArea)

Return oRet
/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Metodo    �TrataRetNeg�Autor  �Vendas Clientes     � Data �  15/01/11   ���
��������������������������������������������������������������������������͹��
���Desc.     �Trata retorno da negociacao                                  ���
��������������������������������������������������������������������������͹��
���Parametros�oExp1 - Iten												   ���
��������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                         ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Method TrataRetNeg(oGetIdMn) Class LJCMultNeg

    Local oDadosCabRet	:= Nil					//  Campos da cole��o
    Local aBkArea		:= GetArea()			// 	Faz Backup da area
	Local nX			:= 0 					//
	
	Default oGetIdMn := Nil
	
	//�������������������������������Ŀ
	//�Se ja existe, so adiciona valor�
	//���������������������������������	
	For nX := 1 To oGetIdMn:Count() 	
		
		//��������������������
		//�Adiciona cabe�alho�
		//��������������������
		If !Self:oDadosCab:Contains(oGetIdMn:Elements(nX):cCodMn) 		
			oDadosCabRet := LJCCabRetNeg():New(oGetIdMn:Elements(nX):cCodMn, 0, oGetIdMn:Elements(nX):cDesMn, dDataBase ) 
			Self:oDadosCab:Add(oGetIdMn:Elements(nX):cCodMn, oDadosCabRet)			
			oDadosCabRet := Nil
		EndIf
		
		RestArea(aBkArea)
	Next nX

Return()

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �TratReIten�Autor  �Vendas Clientes     � Data �  15/01/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Trata retorno da negociacao (Iten)                          ���
�������������������������������������������������������������������������͹��
���Parametros�cExp1 - Produto											  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method TratReIten(cCodigo) Class LJCMultNeg

	Local oDadosRet 	:= Nil 					// Campos da cole��o
    Local aBkArea		:= GetArea()			// Faz Backup da area
	Local nSeq			:= 1					// Sequencia
		
	Default cCodigo := ''

	DbSelectArea("MBT")
	DbSetOrder(1)
	
	If DbSeek(xFilial("MBT")+cCodigo)
		//������������������������Ŀ
		//�Adiciona objeto de itens�
		//��������������������������
		Self:oDadosIten  	:= LJC_RetNeg():New()
		
		While (MBT->MBT_CODIGO == cCodigo) .AND. (!Eof())
			oDadosRet := LJCRetNeg():New() 
	  		oDadosRet:SetRetDados(Self:GetValor())
			Self:oDadosIten:Add(nSeq, oDadosRet )
			// Mata o componente
			oDadosRet := Nil
			MBT->(DbSkip())
			nSeq := nSeq + 1
		End
	
	EndIf
	RestArea(aBkArea)

Return(Self:oDadosIten)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �ValidaNeg �Autor  �Vendas Clientes     � Data �  15/01/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Trata retorno da negociacao (Iten)                          ���
�������������������������������������������������������������������������͹��
���Parametros�cExp1 - Produto											  ���
���          �cExp2 - Grupo produto										  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method ValidaNeg(cCodPro, cCodGru) Class LJCMultNeg

Local oLjValNeh := LJCValidMn():New(cCodPro, cCodGru)	// Valida Multi Negocia��o

Default cCodPro	:= ""
Default cCodGru	:= ""

//verifica se o produto existe no cabecalho da MultiNegociacao (MBS)
oLjValNeh:TemProdMBS()

//verifica se o grupo existe no cabecalho da MultiNegociacao (MBS)
oLjValNeh:TemGrpMBS()

//verifica se o produto existe nos itens da MultiNegociacao (MBK)
oLjValNeh:TemProdMEK()

//verifica se o grupo existe nos itens da MultiNegociacao (MBK)
oLjValNeh:TemGrpMEK()

Return(oLjValNeh:GetRetorno())


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �IdProd	�Autor  �Vendas Clientes     � Data �  15/01/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Identifica��o do Produto			                          ���
�������������������������������������������������������������������������͹��
���Parametros�cExp1 - Produto											  ���
���          �cExp2 - Grupo produto										  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method IdProd(cCodPro, cCodGru) Class LJCMultNeg
Local lPos		:= FindFunction("STFIsPOS") .AND.  STFIsPOS()
Local cAreaProd := If((!lPos .And. nModulo==23) , "SBI","SB1") 
Local cSufixo	:= SubStr(cAreaProd,2,2)
Local aBkArea  	:= GetArea("SB1")

Default cCodPro := ""
Default cCodGru := ""

DbSelectArea(cAreaProd)
DbSetOrder(1)

If (!Empty(cCodPro)) .AND. (DbSeek(xFilial(cAreaProd)+cCodPro))
	cCodPro	:=	&(cAreaProd+"->"+cSufixo+"_COD")
	cCodGru	:=	&(cAreaProd+"->"+cSufixo+"_GRUPO")
Else
	cCodPro := ""
	cCodGru := ""
EndIf 

RestArea(aBkArea)

Return()
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �GetValor	�Autor  �Vendas Clientes     � Data �  15/01/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Retorna valor da venda                                      ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetValor() Class LJCMultNeg
Return(Self:nValor)
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �SetValor	�Autor  �Vendas Clientes     � Data �  15/01/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Passa alor da venda										  ���
�������������������������������������������������������������������������͹��
���Parametros�nExp1 - Valor da Venda									  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method SetValor(nValor) Class LJCMultNeg
	Default nValor := 0
	Self:nValor := nValor
Return()
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �GetValNcc �Autor  �Vendas Clientes     � Data �  15/01/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Retorna valor da ncc                                       ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetValNcc() Class LJCMultNeg
Return(Self:nNcc)
/*              	
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �SetValNcc �Autor  �Vendas Clientes     � Data �  15/01/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Informa o calor da ncc				                      ���
�������������������������������������������������������������������������͹��
���Parametros�nExp1 -Nota Credito Cliente								  ���
���          �								  							  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method SetValNcc(nNcc) Class LJCMultNeg
	
	Default nNcc := 0
	
	Self:nNcc := nNcc

Return()


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �RmNeg 	�Autor  �Vendas Clientes     � Data �  15/01/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Trata retorno da negociacao (Item)                          ���
�������������������������������������������������������������������������͹��
���Parametros�cExp1 - Produto											  ���
���          �cExp2 - Grupo produto										  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method RmNeg(cCodPro, cCodGru) Class LJCMultNeg

Local nX 	:= 1    	// Contador
Local lRet 	:= .T.		// Retorno
Local aRm	:= {}		// Mn a ser excluida

Default cCodPro	:= ""
Default cCodGru	:= ""

For nX := 1 To Self:oDadosCab:Count()

	lRet := .T.

	//verifica se o PRODUTO existe nos itens da Multi Negociacao MEK
	DbSelectArea("MEK")
	MEK->( DbSetOrder(1) )		//MEK_FILIAL + MEK_CODIGO + MEK_PRODUT
	If MEK->( DbSeek(xFilial("MEK") + Self:oDadosCab:Elements(nX):cCodigo+cCodPro) )
    	lRet := .T.
	Else
		lRet := .F.	
	EndIf

	//se o PRODUTO nao existe, verificamos se o GRUPO existe nos itens da Multi Negociacao MEK
	If !lRet
		MEK->( DbSetOrder(2) )	//MEK_FILIAL + MEK_CODIGO + MEK_GRPROD
		If !Empty(cCodGru) .AND. MEK->( DbSeek(xFilial("MEK") + Self:oDadosCab:Elements(nX):cCodigo + cCodGru) )
			lRet := .T.
		Else
			lRet := .F.	    
		 EndIf
	EndIf

	//se nao encontrou nada, verificamos se o PRODUTO existe no cabecalho da Multi Negociacao MBS
	If !lRet
		DbSelectArea("MBS")
		MBS->( DbSetOrder(2) )	//MBS_FILIAL + MBS_PRODUT
		If MBS->( DbSeek(xFilial("MBS") + cCodPro) )
	    	lRet := .T.
		Else
			lRet := .F.
		EndIf
	EndIf	

	//se o PRODUTO nao existir, verificamos se o GRUPO existe no cabecalho da Multi Negociacao MBS
	If !lRet
		MBS->( DbSetOrder(3) )	//MBS_FILIAL + MBS_GRPROD
		If !Empty(cCodGru) .AND. MBS->( DbSeek(xFilial("MBS") + cCodGru) )
    		lRet := .T.
		Else
			lRet := .F.
		EndIf
	EndIf

	//���������������������������������������������������������������������Ŀ
	//�Se for falso, � que  ess produto n�o pertence a essa multi negocia��o�
	//�����������������������������������������������������������������������
	If !lRet
		AaDD( aRm, {Self:oDadosCab:Elements(nX):cCodigo} )
	EndIF

Next nX

//���������������������������������������Ŀ
//�Contador para excluir MN n�o encontrada�
//�����������������������������������������
If Len(aRm) > 0
	For nX := 1 To Len(aRm)
		Self:oDadosCab:Remove( aRm[nX][1] )
	Next nX
EndIf

Return()

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �ValidaNeg �Autor  �Vendas Clientes     � Data �  15/01/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Trata retorno da negociacao (Iten)                          ���
�������������������������������������������������������������������������͹��
���Parametros�cExp1 - Produto											  ���
���          �cExp2 - Grupo produto										  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method AddMnPad() Class LJCMultNeg

Local oLjValNeh     := LJCValidMn():New()	// Valida Multi Negocia��o

oLjValNeh:ValidaCabMbs()

Return(oLjValNeh:GetRetorno())


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �GetDescont�Autor  �Vendas Clientes     � Data �  06/03/12   ���
�������������������������������������������������������������������������͹��
���Desc.     �Transita Valor do Desconto de Multinegocia��o               ���
�������������������������������������������������������������������������͹��
���Parametros�															  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja				                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetDescont()	Class LJCMultNeg
Return(Self:nDescont)						 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �SetDescont�Autor  �Vendas Clientes     � Data �  06/03/12   ���
�������������������������������������������������������������������������͹��
���Desc.     � Modifica Variavel com Valor de Desconto                    ���
�������������������������������������������������������������������������͹��
���Parametros�cExp1 - Valor do Desconto 								  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja 			                                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method SetDescont(nDescont)	Class LJCMultNeg	
Self:nDescont := nDescont
Return()
 	
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �GetVEntrad�Autor  �Vendas Clientes     � Data �  06/03/12   ���
�������������������������������������������������������������������������͹��
���Desc.     �Valor digitado para a entrada na Mult-Negociacao            ���
�������������������������������������������������������������������������͹��
���Parametros�															  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja				                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetVEntrad()	Class LJCMultNeg
Return(Self:nValEnt)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �SetVEntrad�Autor  �Vendas Clientes     � Data �  06/03/12   ���
�������������������������������������������������������������������������͹��
���Desc.     � Modifica Variavel com Valor de Desconto                    ���
�������������������������������������������������������������������������͹��
���Parametros�cExp1 - Valor do Desconto 								  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja 			                                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Method SetVEntrad(nValEnt)	Class LJCMultNeg
Self:nValEnt := nValEnt

Return()
