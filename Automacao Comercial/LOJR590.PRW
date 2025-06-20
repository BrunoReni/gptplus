#INCLUDE "REPORT.CH"   
#INCLUDE "LOJR590.CH"

#IFDEF TOP
	Static	cAlias1	:= GetNextAlias()// Pega o proximo Alias Disponivel
#ENDIF	

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � LOJR590	� Autor � Vendas Crm            � Data �27/12/2010���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Orcamento x Solicitacao de compras                         ���  
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � LOJR590()										          ���
�������������������������������������������������������������������������Ĵ��
���Retorno	 � Nil                         		      		              ���
�������������������������������������������������������������������������Ĵ��
���Uso       � SIGALOJA                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������    
*/                                                          
Function LOJR590()
Local oReport   := Nil                         // Objeto relatorio
Local lR5       := GetRpoRelease("R5")        // Indica se o release e 11.5

//������������������������������������������Ŀ
//�Rotina disponivel a partir do Release 11.5�
//��������������������������������������������                                             
If !lR5
	Return (Nil)
Endif

//��������������������������������������������������������������Ŀ
//� Verifica as perguntas selecionadas                           �
//����������������������������������������������������������������
Pergunte("LOJR590",.T.)
//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                         �
//� MV_PAR01          // Filial De ?                             �
//� MV_PAR02          // Filial Ate ?                            �
//� MV_PAR03          // Cliente de ?                            �
//� MV_PAR04          // Loja de ?                               �
//� MV_PAR05          // Cliente ate ?                           �
//� MV_PAR06          // Loja ate ?                              �
//� MV_PAR07          // Produto de ?                            �
//� MV_PAR08          // Produto ate ?                           �
//� MV_PAR09          // Data venda de ?                         �
//� MV_PAR10          // Data venda ate ?                        �
//� MV_PAR11          // Data SC de ?  			                 �
//� MV_PAR12          // Data SC ate ?       		             � 
//� MV_PAR13          // Pedido de Compra ?                      � 
//����������������������������������������������������������������

//����������������������Ŀ
//�Interface de impressao�
//������������������������
oReport:=LOJR590Def() 
oReport:PrintDialog() 	

Return (Nil)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �LOJR590Def   � Autor � Vendas Crm         � Data �27/12/2010���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Rotina que define os itens que serao apresentados          ��� 
�������������������������������������������������������������������������Ĵ�� 
���Sintaxe	 � LOJR590Def()										          ���
�������������������������������������������������������������������������Ĵ��
���Retorno	 � oReport - Objeto Relatorio  		      		              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGALOJA                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/                       
Static Function LOJR590Def()
Local oReport	:= Nil				// Objeto relatorio TReport (Release 4)
Local oSection1 := Nil				// Objeto secao 1 do relatorio (Lista, campos das tabelas)   

//�������������������Ŀ
//�TITULO DA IMPRESSAO�
//���������������������
oReport := TReport():New("LOJR590",STR0001,"LOJR590",{|oReport| LOJR590RPT( oReport )}, STR0001 ) //"Relatorio de Orcamento x Solicitacao de Compras"

//�����������������������������������������������������������������Ŀ
//�Define a secao1 do relatorio, informando que o arquivo principal �
//�������������������������������������������������������������������
oSection1 := TRSection():New( oReport,STR0001,{ "SL2","SL1","SC1","SA1"} )	//"Relatorio de Orcamento x Solicitacao de Compras"   
                                
//���������������������������������������������Ŀ
//�Define as celulas que irao aparecer na secao1�
//����������������������������������������������� 

TRCell():New(oSection1,"L2_FILIAL"	,"SL2") 		//"Filial" 

#IFDEF TOP
	TRCell():New(oSection1,"CLIENTE"	,""   ,STR0002,,,,{|| (cAlias1)->L1_CLIENTE + " - " + Rtrim((cAlias1)->A1_NOME)})//"Cliente"
#ELSE		 
 	TRCell():New(oSection1,"CLIENTE"	,""   ,STR0002,,,,{|| ("SL1")->L1_CLIENTE 	 + " - " + Rtrim(("SA1")->A1_NOME)})  //"Cliente"						
#ENDIF                                                         

TRCell():New(oSection1,"L1_LOJA"	,"SL1",STR0003)	//"Loja"         
TRCell():New(oSection1,"L2_PRODUTO"	,"SL2",STR0004)	//"Produto"
TRCell():New(oSection1,"C1_QUANT" 	,"SC1",STR0005)	//"Qtde.Sol.Com"	
TRCell():New(oSection1,"L2_NUM"	    ,"SL2",STR0006)	//"Orcamento"	
TRCell():New(oSection1,"C1_NUM" 	,"SC1",STR0007)	//"Sol.Compra"
TRCell():New(oSection1,"L1_EMISSAO"	,"SL1",STR0008)	//"Dt Or�am"
TRCell():New(oSection1,"C1_EMISSAO"	,"SC1",STR0009)	//"Dt.Sol.Com"	

#IFDEF TOP
	TRCell():New(oSection1,"L2_FDTENTR"	,"SL2",STR0010,,,,{|| Iif(Empty((cAlias1)->L2_FDTENTR),"",(cAlias1)->L2_FDTENTR)})//"Dt.Entrega"
#ELSE		 
 	TRCell():New(oSection1,"L2_FDTENTR"	,"SL2",STR0010,,,,{|| Iif(Empty(("SL2")->L2_FDTENTR),"",("SL2")->L2_FDTENTR)})    //"Dt.Entrega"						
#ENDIF 

TRCell():New(oSection1,"C1_FILENT"	,"SC1",STR0011)	//"Fil.Entrega"	     
TRCell():New(oSection1,"C1_PEDIDO"	,"SC1",STR0012)	//"Pedido"

//���������������������������������������������Ŀ
//�Define alinhamento e tamanho das celulas 	�
//�����������������������������������������������
 
oSection1:Cell("L2_FILIAL"):SetAlign ("LEFT")
oSection1:Cell("L2_FILIAL"):SetSize (05)
 
oSection1:Cell("CLIENTE"):SetAlign ("LEFT")
oSection1:Cell("CLIENTE"):SetSize (35)

oSection1:Cell("L1_LOJA"):SetAlign ("LEFT")
oSection1:Cell("L1_LOJA"):SetSize (05)	 
	
oSection1:Cell("L2_PRODUTO"):SetAlign ("LEFT")
oSection1:Cell("L2_PRODUTO"):SetSize (20)

oSection1:Cell("C1_QUANT"):SetAlign ("LEFT")
oSection1:Cell("C1_QUANT"):SetSize (10) 

oSection1:Cell("L2_NUM"):SetAlign ("LEFT")
oSection1:Cell("L2_NUM"):SetSize (10)  

oSection1:Cell("C1_NUM"):SetAlign ("LEFT")
oSection1:Cell("C1_NUM"):SetSize (10)

oSection1:Cell("L1_EMISSAO"):SetAlign ("LEFT")
oSection1:Cell("L1_EMISSAO"):SetSize (11)	

oSection1:Cell("C1_EMISSAO"):SetAlign ("LEFT")
oSection1:Cell("C1_EMISSAO"):SetSize (11)	  

oSection1:Cell("L2_FDTENTR"):SetAlign ("LEFT")
oSection1:Cell("L2_FDTENTR"):SetSize (11)
 
oSection1:Cell("C1_FILENT"):SetAlign ("LEFT")
oSection1:Cell("C1_FILENT"):SetSize (05)	

oSection1:Cell("C1_PEDIDO"):SetAlign ("LEFT")
oSection1:Cell("C1_PEDIDO"):SetSize (10)
                   
Return(oReport) 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �LOJR590RPT   � Autor � Vendas Crm         � Data �27/12/2010���
���          �             �       �                    �      �          ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Rotina responsavel pela impressao do relatorio              ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ�� 
���Sintaxe	 � LOJR590RPT (ExpO1)  		   	    				          ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpO1 - Objeto relatorio     							  ���
�������������������������������������������������������������������������Ĵ��
���Retorno	 � Nil						  		      		              ���
�������������������������������������������������������������������������Ĵ�� 
��� Uso      � SIGALOJA                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function LOJR590RPT (oReport) 

Local oSection1 := oReport:Section(1) 		// Objeto secao 1 do relatorio (Lista, campos das tabelas)
Local cFiltro	:= ""   					// String contendo o filtro de busca a ser utilizado com DBF   

#IFDEF TOP      

	MakeSqlExpr("LOJR590")              
	
	cFiltro += " AND L1_DOCPED = '' AND L1_DOC = ''"
	
    // FILIAL
	If !Empty(MV_PAR01) .OR. !Empty(MV_PAR02)
		cFiltro += " AND L2_FILIAL >= '" + MV_PAR01 + "'"           
	Endif	
	
	If !Empty(MV_PAR02)
		cFiltro += " AND L2_FILIAL <= '" + MV_PAR02 + "'"           
	Endif	

	//CLIENTE
	If !Empty(MV_PAR03)
		cFiltro += " AND L1_CLIENTE >= '" + MV_PAR03 + "'"            
	Endif  
	
	If !Empty(MV_PAR05)
		cFiltro += " AND L1_CLIENTE <= '" + MV_PAR05 + "'"            
	Endif  
	
	//LOJA
	If !Empty(MV_PAR04) 
		cFiltro += " AND L1_LOJA >= '" + MV_PAR04 + "'"           
	Endif 
	
	If !Empty(MV_PAR06)
		cFiltro += " AND L1_LOJA <= '" + MV_PAR06 + "'"           
	Endif		

	//PRODUTO
	If !Empty(MV_PAR07) 
		cFiltro += " AND L2_PRODUTO >= '" + Rtrim(MV_PAR07) + "'"           
	Endif 
	
	If !Empty(MV_PAR08)
		cFiltro += " AND L2_PRODUTO <= '" + Rtrim(MV_PAR08) + "'"           
	Endif  
    
	//DATA VENDA
	If !Empty(MV_PAR09)
		cFiltro += " AND L2_EMISSAO >= '" + DTOS(MV_PAR09) + "'"           
	Endif 
	
	If !Empty(MV_PAR10)
		cFiltro += " AND L2_EMISSAO <= '" + DTOS(MV_PAR10) + "'"           
	Endif  
	
	//DATA SC
	If !Empty(MV_PAR11)
		cFiltro += " AND C1_EMISSAO >= '" + DTOS(MV_PAR11) + "'"           
	Endif 
	
	If !Empty(MV_PAR12)
		cFiltro += " AND C1_EMISSAO <= '" + DTOS(MV_PAR12) + "'"           
	Endif

	// PEDIDO DE COMPRA
	If !Empty(MV_PAR13)
	
		Do Case
   			Case MV_PAR13 == 2
   				cFiltro += 	" AND C1_PEDIDO <> ''" 
   			Case MV_PAR13 == 3                                                                                 
   				cFiltro +=  " AND C1_PEDIDO = ''" 
		EndCase
		          
	Endif  	 

	cFiltro := "%"+cFiltro+"%"    
	
	//��������������������Ŀ
	//�Inicializa a secao 1�
	//����������������������
	oSection1:BeginQuery()	
	
	BeginSQL alias cAlias1
		SELECT 	
			L2_FILIAL, 
			L1_CLIENTE,
			A1_NOME,								
			L1_LOJA,	
			L2_PRODUTO,	
			C1_QUANT, 	
			L2_NUM,	    
			C1_NUM, 	
			L1_EMISSAO,	
			C1_EMISSAO,	
			L2_FDTENTR,	
			C1_FILENT,	
			C1_PEDIDO
		FROM %table:SL2% SL2
			INNER JOIN %table:SL1% SL1 ON 
				SL2.L2_NUM = SL1.L1_NUM    	
			INNER JOIN %table:SA1% SA1 ON 
				SL1.L1_CLIENTE = SA1.A1_COD 
				AND	SA1.%notDel%
			INNER JOIN %table:SC1% SC1 ON
				SL2.L2_SOLCOM = SC1.C1_NUM			      
				AND SC1.%notDel%    
	   	WHERE SL2.%notDel% %Exp:cFiltro%
			     
	    ORDER BY L2_FILIAL, L1_LOJA, L2_NUM, L2_EMISSAO
	EndSql
	
	oSection1:EndQuery() 	
	
#ELSE
        
    MakeAdvplExpr("LOJR590")     
	
	cFiltro := "!Empty(SL2->L2_SOLCOM) .AND. !Empty(SC1->C1_ORCAM)" 	
    
    // FILIAL
	If !Empty(MV_PAR01) .OR. !Empty(MV_PAR02)
		cFiltro += " .AND. SL2->L2_FILIAL >= '" + MV_PAR01 + "'"           
	Endif	
	
	If !Empty(MV_PAR02)
		cFiltro += " .AND. SL2->L2_FILIAL <= '" + MV_PAR02 + "'"           
	Endif
	
	//CLIENTE
	If !Empty(MV_PAR03)
		cFiltro += " .AND. SL1->L1_CLIENTE >= '" + MV_PAR03 + "'"            
	Endif  
	
	If !Empty(MV_PAR05)
		cFiltro += " .AND. SL1->L1_CLIENTE <= '" + MV_PAR05 + "'"            
	Endif
	
	//LOJA
	If !Empty(MV_PAR04) 
		cFiltro += " .AND. SL1->L1_LOJA >= '" + MV_PAR04 + "'"           
	Endif 
	
	If !Empty(MV_PAR06)
		cFiltro += " .AND. SL1->L1_LOJA <= '" + MV_PAR06 + "'"           
	Endif		

	//PRODUTO
	If !Empty(MV_PAR07) 
		cFiltro += " .AND. SL2->L2_PRODUTO >= '" + Rtrim(MV_PAR07) + "'"           
	Endif 
	
	If !Empty(MV_PAR08)
		cFiltro += " .AND. SL2->L2_PRODUTO <= '" + Rtrim(MV_PAR08) + "'"           
	Endif  
    
	//DATA VENDA
	If !Empty(MV_PAR09)
		cFiltro += " .AND. DTOS(SL2->L2_EMISSAO) >= '" + DTOS(MV_PAR09) + "'"           
	Endif 
	
	If !Empty(MV_PAR10)
		cFiltro += " .AND. DTOS(SL2->L2_EMISSAO) <= '" + DTOS(MV_PAR10) + "'"           
	Endif  
	
	//DATA SC
	If !Empty(MV_PAR11)
		cFiltro += " .AND. DTOS(SC1->C1_EMISSAO) >= '" + DTOS(MV_PAR11) + "'"           
	Endif 
	
	If !Empty(MV_PAR12)
		cFiltro += " .AND. DTOS(SC1->C1_EMISSAO) <= '" + DTOS(MV_PAR12) + "'"           
	Endif

	// PEDIDO DE COMPRA
	If !Empty(MV_PAR13)
	
		Do Case
   			Case MV_PAR13 == 2
   				cFiltro += 	" .AND. !Empty(SC1->C1_PEDIDO)" 
   			Case MV_PAR13 == 3                                                                                 
   				cFiltro += 	" .AND.  Empty(SC1->C1_PEDIDO)" 
		EndCase
		          
	Endif  	 

	DbSelectArea("SL2")
	DbSetOrder(6) // L2_FILIAL+L2_SOLCOM   
	
   	TRPosition():New(oSection1,"SL1", 1, {|| xFilial("SL1") + SL2->L2_NUM } )      
  	TRPosition():New(oSection1,"SA1", 1, {|| xFilial("SA1") + SL1->L1_CLIENTE } ) 	 
  	TRPosition():New(oSection1,"SC1", 10, {|| xFilial("SC1") + SL2->L2_NUM } )     
 	 
	//��������������������������������������������������������������������
	//�Efetua o filtro de acordo com a expressao (somente do SL2)		 �
	//��������������������������������������������������������������������   
    oSection1:SetFilter( "!SL2->(EOF())") 
 	
	oSection1:SetLineCondition({|| &(cFiltro) })	
	
#ENDIF
	
//�������������������������������������������Ŀ
//�Quebra a linha, caso existam muitas colunas�
//���������������������������������������������
oSection1:SetLineBreak()
//��������������������������������������������������������������Ŀ
//�Executa a impressao dos dados, de acordo com o filtro ou query�
//����������������������������������������������������������������
oSection1:Print()    

Return (Nil)