#INCLUDE "REPORT.CH"   
#INCLUDE "LOJR740.CH"

Static cAlias1	:= ""	// Pega o proximo Alias Disponivel
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � LOJR740	� Autor � Vendas Crm            � Data � 16/10/10 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Relatorio de Movimentos de Vendas Perdidas                 ���
�������������������������������������������������������������������������Ĵ��
���Uso       � SIGALOJA                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function LOJR740()
Local oReport	

cAlias1	:= GetNextAlias()	// Pega o proximo Alias Disponivel

//������������������������������������������Ŀ
//�Rotina disponivel a partir do Release 11.5�
//��������������������������������������������
If !GetRpoRelease("R5")   
	Return NIL
Endif

#IFDEF TOP
	//��������������������������������������������������������������Ŀ
	//� Verifica as perguntas selecionadas                           �
	//����������������������������������������������������������������
	Pergunte("LOJR740",.T.)
	//��������������������������������������������������������������Ŀ
	//� Variaveis utilizadas para parametros                         �
	//� MV_PAR01          // Filial De ?                             �
	//� MV_PAR02          // Filial At� ?                            �
	//� MV_PAR03          // Loja de ?                               �
	//� MV_PAR04          // Loja at� ?                              �
	//� MV_PAR05          // Vendedor de ?                           �
	//� MV_PAR06          // Vendedor at� ?                          �
	//� MV_PAR07          // Cliente de ?                            �
	//� MV_PAR08          // Cliente at� ?                           �
	//� MV_PAR09          // Produto de?                             �
	//� MV_PAR10          // Produto at�?                            �
	//� MV_PAR11          // Motivo venda perdida de?                �
	//� MV_PAR12          // Motivo venda perdida at�?               �
	//� MV_PAR13          // Data venda perdida de?                  �
	//� MV_PAR14          // Data venda perdida at�?                 �
	//� MV_PAR15          // Tipo de relat�rio                       �
	//����������������������������������������������������������������

	//��������������������������������������������������������������Ŀ
	//� A partir da release 12.1.30 os mpar�metros a baixo tiveram   �
	//� a ordem alterada											 �
	//� MV_PAR03          // Vendedor de ?                           �
	//� MV_PAR04          // Vendedor at� ?                          �
	//� MV_PAR05          // Cliente de ?                            �
	//� MV_PAR06          // Loja de ?                               �
	//� MV_PAR07          // Cliente at� ?                           �
	//� MV_PAR08          // Loja at� ?                              �	
	//����������������������������������������������������������������
	
	//����������������������Ŀ
	//�Interface de impressao�
	//������������������������
	oReport:=LOJR740Def() 
	oReport:PrintDialog() 

#ENDIF	

Return NIL


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �LOJR740Def   � Autor �Vendas Crm          � Data �16/10/2010���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Rotina que define os itens que serao apresentados           ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGALOJA                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/                       
Static Function LOJR740Def()
Local oReport						//Objeto relatorio TReport (Release 4)
Local oSection1 					//Objeto secao 1 do relatorio (Lista, campos das tabelas SB1) 
//Local cAlias1	:= GetNextAlias()	// Pega o proximo Alias Disponivel
Local cTitulo   := ""				// Titulo do relatorio 

//cAlias1		:= GetNextAlias()						


//��������������Ŀ
//�TIPO ANALITICO�
//����������������
If MV_PAR15 == 1
	cTitulo := STR0001 //"Relat�rio de vendas perdidas - Anal�tico"	
Else
	cTitulo := STR0002//"Relat�rio de vendas perdidas - Sint�tico"	
EndIf
oReport := TReport():New("LOJR740",cTitulo,"LOJR740",{|oReport| LOJR740RPT( oReport )}, STR0003 )// "Venda Perdida"

//��������������Ŀ
//�TIPO ANALITICO�
//����������������
If MV_PAR15 == 1

	//�����������������������������������������������������������������Ŀ
	//�Define a secao1 do relatorio, informando que o arquivo principal �
	//�������������������������������������������������������������������
	oSection1 := TRSection():New( oReport,STR0003,{ "MBR","MBQ","SA1","SA3","SB1" } )	//"Venda Perdida"   
	oSection1 :SetLineStyle()
	                                
	//���������������������������������������������Ŀ
	//�Define as celulas que irao aparecer na secao1�
	//����������������������������������������������� 
	
	/*Linha 1*/
	TRCell():New(oSection1,"MBR_FILIAL"	,"MBR"	,,,70,,,"LEFT")	  
	TRCell():New(oSection1,"MBR_LOJA"	,"MBR" 	,,,70,,,"LEFT")	  	
	
	/*Linha 2*/
	TRCell():New(oSection1,"A1_NOME"	,"SA1"	,STR0004,,69,,{ || Rtrim((cAlias1)->MBR_CODCLI) + ' - ' + Rtrim((cAlias1)->A1_NOME) },"LEFT")//"Cliente"
	TRCell():New(oSection1,"A1_CGC"		,"SA1"	,,,70,,,"LEFT")	  	
	
	/*Linha 3*/
	TRCell():New(oSection1,"A1_EMAIL"	,"SA1"	,,,70,,,"LEFT")	
	TRCell():New(oSection1,"A3_NOME"	,"SA3"	,STR0005,,70,,,"LEFT")//"Vendedor"
	
	/*Linha 4*/
	TRCell():New(oSection1,"MBR_NUMORC"	,"MBR" 	,,,67,,,"LEFT")			
	TRCell():New(oSection1,"MBR_DOC"	,"MBR"	,STR0012,,70,,{ || Rtrim((cAlias1)->MBR_DOC) + '/' + Rtrim((cAlias1)->MBR_SERIE) },"LEFT")		
	
	/*Linha 5*/
	TRCell():New(oSection1,"MBR_EMISSA"	,"MBR"	,,,69,,,"LEFT")		
	TRCell():New(oSection1,"MBR_ITEM"	,"MBR"	,,,72,,,"LEFT")		
	
	/*Linha 6*/
	TRCell():New(oSection1,"B1_DESC"	,"SB1"	,STR0006,,69, ,{ || Rtrim((cAlias1)->MBR_PROD) + ' - ' + Rtrim((cAlias1)->B1_DESC) },"LEFT")//"Produto"	
	TRCell():New(oSection1,"MBQ_DSCVEP"	,"MBR"	,STR0007,,70, ,{ || Rtrim((cAlias1)->MBR_MOTIVO) + ' - ' + Rtrim((cAlias1)->MBQ_DSCVEP) },"LEFT")//"Motivo" 
	
	/*Linha 7*/
	TRCell():New(oSection1,"MBR_JUSTIF"	,"MBR"	,STR0008,,63, ,,"LEFT")	//"Justificativa"	
	TRCell():New(oSection1,"MBR_AVDISP"	,""		,STR0009,,68, ,{ || Iif((cAlias1)->MBR_AVDISP,STR0013,STR0014)},"LEFT")//Enviar aviso ?"
	
	/*Linha 8*/
	TRCell():New(oSection1,"MBR_DTENAV"	,"MBR"	,STR0015,,70, ,,"LEFT")	//"Data do Aviso"
	
  	
Else  
	
	oReport:SetTotalInLine(.T.)
	oReport:SetLandScape()    
	
	//�����������������������������������������������������������������Ŀ
	//�Define a secao1 do relatorio, informando que o arquivo principal �
	//�������������������������������������������������������������������
	oSection1 := TRSection():New( oReport,STR0003,{ "MBR","MBQ","SA1","SA3" } )	//"Venda Perdida"   
		                                
	//���������������������������������������������Ŀ
	//�Define as celulas que irao aparecer na secao1�
	//�����������������������������������������������
	 
	
	TRCell():New(oSection1,"MBQ_DSCVEP"	,STR0007) //"Motivo"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            
	TRCell():New(oSection1,"TOTAL"	,STR0010) //"Total de movimentos no periodo"
	
	oSection1:Cell("MBQ_DSCVEP"):SetSize (90)	
	oSection1:Cell("MBQ_DSCVEP"):SetBlock ({ || Rtrim((cAlias1)->MBQ_CODVEP) + ' - ' + Rtrim((cAlias1)->MBQ_DSCVEP) })
	
   	TRFunction():New(oSection1:Cell("TOTAL"),NIL,"SUM",,STR0011,,,.F.)  //"TOTAL DE VENDAS PERDIDAS"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          
	
Endif

                    
Return(oReport) 
Return Nil    


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �LOJR740RPT   � Autor �Leandro Nogueira    � Data �16/10/2010���
���          �             �       �                    �      �          ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Rotina responsavel pela impressao do relatorio              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGALOJA                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function LOJR740RPT (oReport)
Local oSection1 	:= oReport:Section(1) 		//Objeto secao 1 do relatorio (Lista, campos das tabelas SB1)
Local cFiltro		:= ""   					//String contendo o filtro de busca a ser utilizado com DBF   

Local cVendDe		:= ''
Local cVendAte		:= ''
Local cClienteDe 	:= ''
Local cClienteAte	:= ''
Local cLojaDe		:= ''
Local cLojaAte		:= ''

MakeSqlExpr("LOJR740")      


// Foi alterado a ordem dos par�metros na release 12.1.30, pois os par�metros Loja De e Loja At� estavam em posi��es incorretas
If GetRPORelease() > "12.1.027"
	cVendDe		:= MV_PAR03
	cVendAte	:= MV_PAR04
	cClienteDe 	:= MV_PAR05
	cClienteAte	:= MV_PAR07
	cLojaDe		:= MV_PAR06
	cLojaAte	:= MV_PAR08
Else
	cLojaDe		:= MV_PAR03
	cLojaAte	:= MV_PAR04
	cVendDe		:= MV_PAR05
	cVendAte	:= MV_PAR06
	cClienteDe 	:= MV_PAR07
	cClienteAte	:= MV_PAR08	
EndIf

// FILIAL
If !Empty(MV_PAR01) .OR. !Empty(MV_PAR02)
	cFiltro += 	" AND (MBR_FILIAL BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "') "           
Endif
		
//VENDEDOR
If !Empty(cVendDe) .OR. !Empty(cVendAte)
	cFiltro += 	" AND (MBR_VEND BETWEEN '" + cVendDe + "' AND '" + cVendAte + "') "           
Endif

//CLIENTE
If !Empty(cClienteDe) .OR. !Empty(cClienteAte)
	cFiltro += 	" AND (MBR_CODCLI BETWEEN '" + cClienteDe + "' AND '" + cClienteAte + "') "           
Endif

//LOJA
If !Empty(cLojaDe) .OR. !Empty(cLojaAte)
	cFiltro += 	" AND (MBR_LOJA BETWEEN '" + cLojaDe + "' AND '" + cLojaAte + "') "           
Endif

//PRODUTO
If !Empty(MV_PAR09) .OR. !Empty(MV_PAR10)
	cFiltro += 	" AND (MBR_PROD BETWEEN '" + MV_PAR09 + "' AND '" + MV_PAR10 + "') "           
Endif

//MOTIVO
If !Empty(MV_PAR11) .OR. !Empty(MV_PAR12)
	cFiltro += 	" AND (MBR_MOTIVO BETWEEN '" + MV_PAR11 + "' AND '" + MV_PAR12 + "') "           
Endif

//DATA
If !Empty(MV_PAR13) .OR. !Empty(MV_PAR14)
	cFiltro += 	" AND (MBR_EMISSA BETWEEN '" + DTOS(MV_PAR13) + "' AND '" + DTOS(MV_PAR14) + "') "           
Endif

cFiltro := "%"+cFiltro+"%"
    

//��������������������Ŀ
//�Inicializa a secao 1�
//����������������������
oSection1:BeginQuery()	   
	

//��������������Ŀ
//�TIPO ANALITICO�
//����������������
If MV_PAR15 == 1	

	BeginSQL alias cAlias1                          	
		SELECT 	MBR_FILIAL, 
				MBR_LOJA,
				MBR_CODCLI,
				A1_NOME,
				A1_CGC,
				A1_EMAIL,
				MBR_DOC,
				MBR_SERIE,				
				A3_NOME ,
				MBR_NUMORC,
				MBR_EMISSA,
				MBR_PROD,
	   			B1_DESC ,
	   			MBR_ITEM,
	   			MBR_MOTIVO,
	   			MBQ_DSCVEP,
	   			MBR_JUSTIF,
	   		   	MBR_AVDISP,
	   			MBR_DTENAV
	    FROM %table:MBR% MBR
			INNER JOIN %table:SA1% SA1 ON MBR.MBR_CODCLI = SA1.A1_COD AND MBR.MBR_LOJA = SA1.A1_LOJA
			INNER JOIN %table:MBQ% MBQ ON MBR.MBR_MOTIVO = MBQ.MBQ_CODVEP   
			INNER JOIN %table:SA3% SA3 ON MBR.MBR_VEND = SA3.A3_COD 
			INNER JOIN %table:SB1% SB1 ON MBR.MBR_PROD = SB1.B1_COD AND
			SA1.%notDel% AND   
			MBQ.%notDel% AND   
			SB1.%notDel% AND   
			SA3.%notDel%    
	   	WHERE MBR.%notDel% %Exp:cFiltro%
			     
	     ORDER BY MBR_FILIAL, MBR_LOJA
	EndSql   	
	
//��������������Ŀ
//�TIPO SINTETICO�
//����������������
Else
	BeginSQL alias cAlias1                          	
   		SELECT 	
   			MBQ_CODVEP,
   			MBQ_DSCVEP ,
   			COUNT(MBQ_CODVEP) AS TOTAL   			
	    FROM %table:MBR% MBR
			INNER JOIN %table:SA1% SA1 ON MBR.MBR_CODCLI = SA1.A1_COD AND MBR.MBR_LOJA = SA1.A1_LOJA
			INNER JOIN %table:MBQ% MBQ ON MBR.MBR_MOTIVO = MBQ.MBQ_CODVEP   
			INNER JOIN %table:SA3% SA3 ON MBR.MBR_VEND = SA3.A3_COD AND		         
			SA1.%notDel% AND   
			MBQ.%notDel% AND   
			SA3.%notDel%
	   	WHERE MBR.%notDel% %Exp:cFiltro%
   		GROUP BY MBQ_CODVEP,MBQ_DSCVEP		     
	    ORDER BY MBQ_CODVEP
	EndSql  

EndIf    

oSection1:EndQuery() 
	
//�������������������������������������������Ŀ
//�Quebra a linha, caso existam muitas colunas�
//���������������������������������������������
oSection1:SetLineBreak()
//��������������������������������������������������������������Ŀ
//�Executa a impressao dos dados, de acordo com o filtro ou query�
//����������������������������������������������������������������
oSection1:Print()    

Return NIL
