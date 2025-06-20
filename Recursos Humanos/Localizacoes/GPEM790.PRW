#include "PROTHEUS.CH"
#INCLUDE "GPEM790.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � GPEM790  � Autor � Abel Ribeiro          � Data � 06/08/08 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � GERA ARQUIVO DE IRS                                        ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data  � BOPS          �  Motivo da Alteracao             ��� 
�������������������������������������������������������������������������Ĵ��
���Rodrigo L.   �14/01/11�000000001452011�Ajuste para nova interface 11.  ���
���             �        �               �utilizando a fun��o MsAdvSize   ���
���             �        �               �(p/ flexibilidade da tela de    ���
���	            �	     �		         �acordo com a resolu��o).        ���
�������������������������������������������������������������������������ٱ�*/ 
Function GPEM790()
Local nOpca 	    := 0
Local aSays		    := {}
Local aButtons	    := {} //<== arrays locais de preferencia                        
Local aFilterExp	:=  {} 					//expressao do filtro
Local aRetFiltro							//retorno do filtro
Local bNewFiltro							//bloco para inclusao de novos filtros
Local bAltFilter							//bloco para Alteracao do filtro selecionado
Local bBtnCalcule							//bloco do bot�o OK
Local bPergunte								//bloco para o pergunte
Local cSays1		 := OemToAnsi(STR0003)	//"Este programa gera informa��es para o IRS"
Local cSays2		 := OemToAnsi(STR0001)	//"de acordo com a movimenta��o do Ano anterior."
Local oDlg
Local oBtnNewFil
Local oBtnAltFil
Local oBtnCalcule
Local oBtnEnd
Local oBtnPergunte
Local lShowDlgFilt	:= .T.					//visualizar a dialog de filtros
Local bDialogInit							//bloco de inicializacao da janela 

//��������������������������������������������������������������Ŀ
//� Declara��o de arrays para dimensionar tela		         �
//����������������������������������������������������������������
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}

Private cFiltSRA    := ""
Private cPathFile   := ""
Private cExtRel     := ".##R"      
Private cCadastro   := OemToAnsi(STR0002)   //"Gera��o dos Dados de IRS"
Private cTabMestra  := "SRA" 
Private cExpFiltro	:= ""					//variavel com o retorno do filtro
Private cTxtFil     := ""
Private lTudo       := .F.


DEFINE FONT oFont1  NAME "Arial" SIZE 0,-13 BOLD
cBlkGet :=  "{ | u | If( PCount() == 0, cTxtFil,cTxtFil:= u ) }"
cBlKVld :=  "{|| .T. }"
cBlKWhen := "{|| .F. }"

Pergunte("GPM790",.F.)

bDialogInit 	:= { || ;
						Gpem790Arq(	@cTabMestra	,;
									oBtnNewFil	,;
									oBtnAltFil	,;
									oBtnCalcule	,;
									.T.			 ;
								 )								,;	// seta o arquivo Mestre
						Gpem020SetFil(@aFilterExp, cTabMestra)	,;	// Setar as opcoes que filtrara o cadastro de Filtro
						lShowDlgFilt := .F.						,;
						Gpem020Filter( 	aFilterExp	,;
							 			cTabMestra	,;
							 			@cExpFiltro ,;
							 			lShowDlgFil  ;
									),;	// setar o ultimo filtro utilizado
						lShowDlgFilt := .T.;
				   }
Gpem020SetFil(@aFilterExp, cTabMestra)
lShowDlgFilt := .F.
Gpem020Filter(aFilterExp,cTabMestra,@cExpFiltro,lShowDlgFil)

If !Empty(cExpFiltro)
	cTxtFil := Gpem790QbrFil(cExpFiltro)
Endif    

/*
��������������������������������������������������������������Ŀ
� Monta as Dimensoes dos Objetos         					   �
����������������������������������������������������������������*/
aAdvSize	 := MsAdvSize()
aAdvSize[5]	 :=	(aAdvSize[5]/100) * 68.5	//horizontal
aAdvSize[6]	 :=  (aAdvSize[6]/100) * 55	//Vertical
aInfoAdvSize := { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 0 , 0 }					 
aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
aObjSize	 := MsObjSize( aInfoAdvSize , aObjCoords )

DEFINE MSDIALOG oDlg TITLE STR0001 FROM aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] OF GetWndDefault() STYLE DS_MODALFRAME PIXEL// "Gera��o do Quadro de Pessoal"  
	/*/
	��������������������������������������������������������������������������Ŀ
	� Descricao da Janela                                                      �
	���������������������������������������������������������������������������� */
	@ aObjSize[1,1]+14,aObjSize[1,2]+2 TO aObjSize[1,3]*0.43,aObjSize[1,4]*0.685 OF oDlg PIXEL
	@ aObjSize[1,1]+17,aObjSize[1,2]+5 SAY cSays1  Of oDlg Pixel  FONT oFont1 
	@ aObjSize[1,1]+27,aObjSize[1,2]+5 SAY cSays2  Of oDlg Pixel  FONT oFont1 
	@ aObjSize[1,1]+37,aObjSize[1,2]+5 SAY STR0030 Of oDlg Pixel FONT oFont1 // "Filtro de Funcion�rio:"
	
	oTxtFil := TMultiGet():New(aObjSize[1,1]+47,aObjSize[1,2]+5,&cBlKGet,oDlg,aObjSize[1,4]*0.665,aObjSize[1,3]*0.16,,.F.,,,,.T.,,.F.,&(cBlkWhen),.F.,.F.,.F.,&(cBlkVld),,.F.,.F.,.T.)
	/*/
	��������������������������������������������������������������������������Ŀ
	� Funcoes em GpFiltro  - Blocos de Execucao dos filtros                    �
	� GpFiltro - Chama a janela principal do cadastro de filtros               �
	� GpFltAlsGet - Retorna a expressao para elaborar o filtro                 �
	����������������������������������������������������������������������������*/
	bLogProc 		:= { || GPM790Log() }
	bNewFiltro 		:= { || aRetFiltro := GpFiltro( aFilterExp ), cExpFiltro := GpFltAlsGet( aRetFiltro , cTabMestra ), Gpem790QbrFil(cExpFiltro),oTxtFil:Refresh() }
	bAltFilter 		:= { || Gpem790Filter( aFilterExp, cTabMestra, @cExpFiltro, lShowDlgFil ), Gpem790QbrFil(cExpFiltro),oTxtFil:Refresh() }
	bBtnCalcule		:= { || nOpca := 1, IF( GPM790Ok()( ),oDlg:End(), nOpca:=0 ) }
	bPergunte 		:= { || Pergunte("GPM790",.T.) }
	
	oBtnLogProc 	:= TButton():New( aObjSize[1,3]*0.45, aObjSize[1,2]+002, "&"+OemToAnsi(STR0014),NIL,bLogProc			, 040 , 012 , NIL , NIL , NIL , .T. )	// "Arq. Log"
	oBtnAltFil  	:= TButton():New( aObjSize[1,3]*0.45, aObjSize[1,2]+044, "&"+OemToAnsi(STR0020),NIL,bAltFilter			, 040 , 012 , NIL , NIL , NIL , .T. )	// "Alterar Filtro"
	oBtnNewFil  	:= TButton():New( aObjSize[1,3]*0.45, aObjSize[1,2]+086, "&"+OemToAnsi(STR0021),NIL,bNewFiltro			, 040 , 012 , NIL , NIL , NIL , .T. )	// "Incluir Filtro"
	oBtnPergunte	:= TButton():New( aObjSize[1,3]*0.45, aObjSize[1,2]+128, "&"+OemToAnsi(STR0022),NIL,bPergunte 			, 040 , 012 , NIL , NIL , NIL , .T. )	// "Par�metros"
	oBtnCalcule		:= TButton():New( aObjSize[1,3]*0.45, aObjSize[1,2]+170, "&"+OemToAnsi(STR0023),NIL,bBtnCalcule 		, 040 , 012 , NIL , NIL , NIL , .T. )	// "Processar"
	oBtnEnd			:= TButton():New( aObjSize[1,3]*0.45, aObjSize[1,2]+212, "&"+OemToAnsi(STR0024),NIL,{ || oDlg:End() }	, 040 , 012 , NIL , NIL , NIL , .T. )	// "Sair"

ACTIVATE DIALOG oDlg ON INIT Eval( bDialogInit ) CENTERED

//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                         �
//����������������������������������������������������������������
//��������������������������������������������������������������Ŀ
//� mv_par01 - Mes Referencia                                    �
//� mv_par02 - Nao Referencia                                    �
//����������������������������������������������������������������

IF nOpca == 1
	If Empty(cExpFiltro)
	
		lRet := MsgYesNo(OemToAnsi(STR0029),OemToAnsi(STR0018)) // "Nenhum filtro foi selecionado! Processar toda a tabela?"###"Aten��o"
		
		IF lRet
		   lTudo := .T.
		ENDIF   
	Else
		lRet := .T.
	EndIf	
	If lRet
		ProcGpe({|lEnd| GPM790Processa(cExpFiltro,cTabMestra)})  // Chamada do Processamento
	Endif
Endif

Return Nil

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Funcao    �GPM790Processa�Autor  �Abel Ribeiro    � Data �  09/01/06  ���
��������������������������������������������������������������������������͹��
���Desc.     �                                                             ���
���          �                                                             ���
��������������������������������������������������������������������������͹��
���Uso       � AP                                                          ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Static Function GPM790Processa(cExpFiltro,cTabMestra)
//��������������������������������������������������������������Ŀ
//� Define Variaveis LOCAIS DO PROGRAMA                          �
//����������������������������������������������������������������
Local nX
Local cQuery        

Private aLog	:= {}
Private aTitle	:= {}
Private aTotRegs:= array(9)         
Private aVerba	:= {}
Private cAliasSRD := "SRD"
//��������������������������������������������������������������Ŀ
//� Define Variaveis PRIVADAS BASICAS                            �
//����������������������������������������������������������������
Private aCRA 	:= { STR0004,STR0005,STR0006 } //"Confirma"###"Redigita"###"Abandona"

//��������������������������������������������������������������Ŀ
//� Define Variaveis PRIVADAS DO PROGRAMA                        �
//����������������������������������������������������������������
Private cInfOut   := ""
Private cDescri   := ""
Private cCodRet   := ""
Private cFilter   := ""
Private aFunc 	  := {}           
Private cAno	  := MV_PAR01
Private nTamCpf	  := TamSX3("RA_CIC")[1]
Private cAnoMesAb := MesAno(dDataBase)
Private nValRET   := 0
Private nValRend  := 0
Private	nValQSIND := 0
Private	nValDESOBR:= 0
Private	nValIsento:= 0

Private nTotFunc:= 0 

If File(cPathFile)
	FERASE(cPathFile)                      //Deleta o Arquivo
Endif

aFill(aTotRegs,0)

If !Empty(cExpFiltro)
    
    cExpFiltro := StrTran(cExpFiltro,".", ' ')            
    cExpFiltro := StrTran(cExpFiltro,'"', "'")            
    cExpFiltro := StrTran(cExpFiltro,'==', "=")            
    
	cFilter    := StrTran(cExpFiltro, "SRA->", 'SRA.')            
    
	If aTotRegs[2] == 0
		cLog := STR0019 // "Filtro da Tabela SRA: "
		Aadd(aTitle,cLog)  
		Aadd(aLog,{})
		aTotRegs[2] := len(aLog)
	EndIf	
	Aadd(aLog[aTotRegs[2]], cExpFiltro ) 
Else              
   If !MsgYesNo( OemToAnsi(STR0007),OemToAnsi(STR0018)) .AND. !lTudo
      RETURN
   ENDIF   
Endif                   


//�������������������������������Ŀ
//�Montagem das Datas para a Query�
//���������������������������������
         

cDtPesqI := MV_PAR01+"01"
cDtPesqF := MV_PAR01+ "12"

dbSelectArea( "SRA" )
       
 
//��������������������������������������������������������������Ŀ
//� Buscar Valores no Acumulado "SRD"                            �
//����������������������������������������������������������������                                       

	dbSelectArea("SRD")
	#IFDEF TOP
		If TcSrvType()<>"AS/400"
			lQuery 		:= .T.
			cAliasSRD 	:= "qryDados"
			aStru  		:= SRD->(dbStruct())
                      
            cQUERY := "SELECT DISTINCT RA_FILIAL,RA_MAT, "
            cQUERY += " TIPOREN= "
            cQUERY += " CASE "     
            cQUERY += " WHEN RA_CATFUNC='1' THEN 'H' "    
            cQUERY += " WHEN RA_CATFUNC='A' THEN 'B' " 
            cQUERY += " ELSE 'A'  END, "
            cQUERY += " (SELECT COALESCE(SUM(RDRET.RD_VALOR),0) " 
            cQUERY += " FROM "+ RetSqlName("SRD") + " RDRET "
			cQUERY += "	INNER JOIN " + RetSqlName("SRV") + " RVRET ON "	
			cQUERY += " RDRET.RD_PD  = RVRET.RV_COD " 
			cQUERY += " AND RVRET.RV_DIRF='1' "
 		    cQUERY += " AND RVRET.D_E_L_E_T_=''
			cQUERY += " WHERE RDRET.RD_FILIAL  =SRD.RD_FILIAL 
			cQUERY += " AND RDRET.RD_ROTEIR IN('FOL','NAT') "
			cQUERY += " AND RDRET.RD_MAT = SRD.RD_MAT "                                //TIpo = 1 (Valores Rendimentos no Ano)
			cQuery += " AND RD_DATARQ BETWEEN '"+cDtPesqI+"' AND '"+cDtPesqF+"'" 
		    cQUERY += " AND RDRET.D_E_L_E_T_='')  VLREND, "

			cQUERY += " (SELECT COALESCE(SUM(RDRET.RD_VALOR),0)  FROM "+ RetSqlName("SRD") + " RDRET "
			cQUERY += "	INNER JOIN " + RetSqlName("SRV") + " RVRET ON "	
			cQUERY += "	RDRET.RD_PD      = RVRET.RV_COD "
			cQUERY += "	AND RVRET.RV_DIRF    = '2' "		                          //TIpo = 2 (Valores Retidos IRS)
			cQUERY += "	AND RVRET.D_E_L_E_T_ = '' "     
			cQUERY += "	WHERE RDRET.RD_FILIAL= SRD.RD_FILIAL "  
			cQUERY += "	AND RDRET.RD_MAT     = SRD.RD_MAT "                     
			cQUERY += " AND RDRET.RD_ROTEIR IN('FOL','NAT') "
			cQuery += " AND RD_DATARQ BETWEEN '"+cDtPesqI+"' AND '"+cDtPesqF+"' " 
			cQUERY += "	AND RDRET.D_E_L_E_T_='')  VLRET, "

			cQUERY += " (SELECT COALESCE(SUM(RDRET.RD_VALOR),0)  FROM "+ RetSqlName("SRD") + " RDRET "
			cQUERY += "	INNER JOIN " + RetSqlName("SRV") + " RVRET ON "	
			cQUERY += "	RVRET.RV_FILIAL=RDRET.RD_FILIAL "
			cQUERY += "	AND RDRET.RD_PD=RVRET.RV_COD " 
			cQUERY += " AND RVRET.RV_DIRF='3' "                                //Tipo = 3 (Valores Descontos Obrigatorios
			cQUERY += "	AND RVRET.D_E_L_E_T_='' "     
			cQUERY += " WHERE RDRET.RD_FILIAL  =SRD.RD_FILIAL "		
			cQUERY += " AND RDRET.RD_MAT  =SRD.RD_MAT "
			cQUERY += " AND RDRET.RD_ROTEIR IN('FOL','NAT') "
			cQuery += " AND RD_DATARQ BETWEEN '"+cDtPesqI+"' AND '"+cDtPesqF+"' " 
			cQUERY += "	AND RDRET.D_E_L_E_T_='')  VLDESOBR, "

			cQUERY += " (SELECT COALESCE(SUM(RDRET.RD_VALOR),0)  FROM "+ RetSqlName("SRD") + " RDRET "
			cQUERY += "	INNER JOIN " + RetSqlName("SRV") + " RVRET ON "	
			cQUERY += "	RVRET.RV_FILIAL=RDRET.RD_FILIAL "		
			cQUERY += "	AND RDRET.RD_PD=RVRET.RV_COD " 
			cQUERY += "	AND RVRET.RV_DIRF='4' "                               //TIpo = 4 (Valores Quotiza�oes Sindicais)
			cQUERY += "	AND RVRET.D_E_L_E_T_='' "
			cQUERY += " WHERE RDRET.RD_FILIAL  =SRD.RD_FILIAL "
			cQUERY += "	AND RDRET.RD_MAT  = SRD.RD_MAT "    
			cQUERY += " AND RDRET.RD_ROTEIR IN('FOL','NAT') "
			cQuery += " AND RD_DATARQ BETWEEN '"+cDtPesqI+"' AND '"+cDtPesqF+"' " 
			cQUERY += "	AND RDRET.D_E_L_E_T_='') VLQSIND, "	
			
			cQUERY += " (SELECT COALESCE(SUM(RDRET.RD_VALOR),0)  FROM "+ RetSqlName("SRD") + " RDRET "
			cQUERY += "	INNER JOIN " + RetSqlName("SRV") + " RVRET ON "	
			cQUERY += "	RVRET.RV_FILIAL=RDRET.RD_FILIAL "		
			cQUERY += "	AND RDRET.RD_PD=RVRET.RV_COD " 
			cQUERY += "	AND RVRET.RV_DIRF='5' "                              //TIpo = 5 (Valores Remunera��o Isentas de IRS)
			cQUERY += "	AND RVRET.D_E_L_E_T_='' "
			cQUERY += " WHERE RDRET.RD_FILIAL  = SRD.RD_FILIAL "
			cQUERY += "	AND RDRET.RD_MAT  = SRD.RD_MAT "    
			cQUERY += " AND RDRET.RD_ROTEIR IN('FOL','NAT') "
			cQuery += " AND RD_DATARQ BETWEEN '"+cDtPesqI+"' AND '"+cDtPesqF+"' " 
			
			cQUERY += "	AND RDRET.D_E_L_E_T_='') VLISENTO "	
			cQUERY += " FROM " + RetSqlName("SRD") + " SRD "
			cQUERY += " INNER JOIN " + RetSqlName("SRA") + " SRA ON "
			cQUERY += " RD_FILIAL=RA_FILIAL "
			cQUERY += " AND RD_MAT=RA_MAT "
			cQUERY += " AND RD_ROTEIR IN('FOL','NAT') "
			cQuery += " AND RD_DATARQ BETWEEN '"+cDtPesqI+"' AND '"+cDtPesqF+"'" 
			If !Empty(cFilter)   //Adiciona o Filtro do Usu�rio
		       cQuery += " AND "+cFilter
	        Endif 
			cQUERY += " AND SRA.D_E_L_E_T_='' "
			cQUERY += " WHERE SRD.D_E_L_E_T_='' "
			cQuery += "	ORDER BY RA_MAT "

            cQuery := ChangeQuery(cQuery)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSRD,.T.,.T.)

			For nX := 1 To len(aStru)
				If aStru[nX][2] <> "C" .And. FieldPos(aStru[nX][1])<>0
					TcSetField(cAliasSRD,aStru[nX][1],aStru[nX][2],aStru[nX][3],aStru[nX][4])
				EndIf
			Next nX
			dbSelectArea(cAliasSRD)	
		Else
	#ENDIF
		(cAliasSRD)->(MsSeek(SRA->RA_FILIAL+SRA->RA_MAT+cDtPesqI,.T.))
	#IFDEF TOP
		EndIf
	#ENDIF
    
	GPProcRegua((cAliasSRD)->(RecCount()))

    lProcessou := .F.

	While (cAliasSRD)->(!Eof()) 
       
        lProcessou := .T.
        dbSelectArea( "SRA" )
        dbSetOrder(1)
        dbSeek( (cAliasSRD)->RA_FILIAL  + (cAliasSRD)->RA_MAT , .T. )
        
        cDistrito := SUBSTR(SRA->RA_BAIRRO,1,2)
        
        GPIncProc(SRA->RA_FILIAL+" - "+SRA->RA_MAT+" - "+SRA->RA_NOME)
       
		nValREN   := (cAliasSRD)->VLREND
		nValRET   := (cAliasSRD)->VLRET
		nValDESOBR:= (cAliasSRD)->VLDESOBR
		nValQSIND := (cAliasSRD)->VLQSIND
		nValIsento:= (cAliasSRD)->VLISENTO
				        
        If !empty(SRA->RA_CIC)
			//��������������������������������Ŀ
			//�Gravar Cabe�alho da Dirf/informe�
			//����������������������������������                      
			
			fGravaDados(SRA->RA_FILIAL,SRA->RA_CIC,(cAliasSRD)->RA_MAT,(cAliasSRD)->TIPOREN,cDISTRITO,cAliasSRD)
			
	    Else
			If aTotRegs[3] == 0
				cLog := STR0008         // "Funcion�rio sem CPF cadastrado."
				Aadd(aTitle,cLog)  
				Aadd(aLog,{})
				aTotRegs[3] := len(aLog)
			EndIf	
			Aadd(aLog[aTotRegs[3]], SRA->RA_FILIAL+"-"+SRA->RA_MAT+ space(02)+SRA->RA_NOME ) 
		Endif 
		
		nTotFunc ++
		 
		(cAliasSRD)->( dbSkip())
	Enddo
	
	#IFDEF TOP
		dbSelectArea(cAliasSRD)
		dbCloseArea()
	#ENDIF    


    If aTotRegs[9] == 0 .and. aTotRegs[4] == 0 .and. aTotRegs[5] == 0        
	
	  
	   If aTotRegs[4] == 0
          cLog := STR0026                                      //"Total de Funcion�rios Processados
	      Aadd(aTitle,cLog)  
	      Aadd(aLog,{})
	      aTotRegs[4] := len(aLog)                                                                                          
	   EndIf	                                
	   
	   Aadd(aLog[aTotRegs[4]], STR0027+STRZERO(nTOTFUNC,6))    //"Total Func: "
	   
	   IF nTOTFUNC > 0         
	      If aTotRegs[9] == 0 .AND. aTotRegs[3] == 0           //Verifica Se n�o tem Inconsist�ncia
		     cLog := STR0009                                   //"Informa��es Geradas com Sucesso !"
		     Aadd(aTitle,cLog)  
		     Aadd(aLog,{})
		     aTotRegs[9] := len(aLog)
	 
	   	     Aadd(aLog[aTotRegs[9]], STR0010)                  //"N�o foi encontrada nenhuma inconsist�ncia durante a gera��o.") 
	   	     If aTotRegs[5] == 0
                cLog := STR0011                                  //"Informa��es para gerar o IRS."
                Aadd(aTitle,cLog)  
                Aadd(aLog,{})
                aTotRegs[5] := len(aLog)                                         
             EndIf	

             Aadd(aLog[aTotRegs[5]], STR0012)                   //"Para consultar as informa��es Geradas, acesse a op��o Manuten��o do IRS do menu")

	      ELse
	      	 cLog := STR0032                                   //"Foram encontradas Inconsist�ncias na Gera��o"
		     Aadd(aTitle,cLog)  
		     Aadd(aLog,{})
		     aTotRegs[2] := len(aLog)
	 
	   	     Aadd(aLog[aTotRegs[2]], STR0031)                  
	   	  ENDIF                  
	   	  
          
	   Else
	      If aTotRegs[9] == 0
		     cLog := STR0028                                 //"N�o   foi encontrado movimento. Verifique os par�metro/Filtro."
		     Aadd(aTitle,cLog)  
		     Aadd(aLog,{})
		     aTotRegs[9] := len(aLog)
	      EndIf	                
	   
	   	  Aadd(aLog[aTotRegs[9]], STR0031)                   //"N�o Foi  Gerado Nenhum Registro")
	  ENDIF 	  
    EndIf   
    
fMakeLog(aLog,aTitle,,,"GPEM790",STR0013,"M","P",,.F.)     //"Log de ocorr�ncias "

Return Nil
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �GPM790Ok  �Autor  �Microsiga           � Data �  01/19/05   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function GPM790Ok()
Return (MsgYesNo(OemToAnsi(STR0007),OemToAnsi(STR0018))) //"Confirma configura��o dos par�metros?"###"Aten��o"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �fGravaDados�Autor  �ABEL RIBEIRO       � Data �  08/08/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Grava dados no Arquivo de Dados RGO,                        ���
�������������������������������������������������������������������������͹��
���Parametros� cFIL  = FILIAL                                             ���
����           cNIF  = NIF do Funcion�rio                                 ���
���          � cMat      = Matricula do Funcion�rio                       ���
���          � cTipoRen  = Conforme tabela cadastrada, no RCC e configurado���
���                        e configurado no campo RV_DIRF, da tabela SRV   ���
����           cDistrito = Codigo do Bairro para Definir localizacao      ���
���          � cAliasIRS = Alias que esta sendo usado no momento          ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function fGravaDados(cFIL,cNIF,cMat,cTipoRet,cDistrito,cAliasIRS)


cChave:= cFil+cANO+cMat+SUBSTR(ALLTRIM(cNIF),1,9)+cTipoRet   

dbSelectArea("RGO")           
dbSetOrder(1)
If dbSeek( cChave )
	RecLock("RGO",.F.)
Else
	RecLock("RGO",.T.)
    RGO->RGO_FILIAL  := cFil
    RGO->RGO_MAT     := cMat
    RGO->RGO_NIF     := cNIF
    RGO->RGO_ANO     := cANO
    RGO->RGO_TIPREN  := cTipoRet     
Endif

IF VAL(cDISTRITO) >=  1 .AND. VAL(cDistrito) <= 18
   RGO->RGO_LOCREN := "C"                 //Continente
ELSEIF VAL(cDISTRITO) >= 31 .and. VAL(cDistrito) <= 32 
   RGO->RGO_LOCREN := "M"                 //Madeira
ELSE
   RGO->RGO_LOCREN := "A"                 //A�ores
ENDIF                  

RGO->RGO_VLRREN := nValRen
RGO->RGO_VLRRET := nValRet
RGO->RGO_QUOTSI := nValQSind
RGO->RGO_DESOBR := nValDesobr
RGO->RGO_VLISEN := nValIsento

MsUnLock()
	
Return		
/*
�����������������������������������������������������������������������Ŀ
�Fun��o    �Gpem790Filter�Autor� Abel Ribeiro           �Data�22/08/2008�
�����������������������������������������������������������������������Ĵ
�Descri��o �Botao de alteracao do filtro                 				�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�������������������������������������������������������������������������
*/
Function Gpem790Filter(	aFilterExp 	,;		// opcoes do filtro  // MUDEI AQUI
						cTabMestra	,;		// alias do filtro
			 			cExpFiltro	,;		// string com o filtro - passado por referencia
						lShowDlg	 ;		// Se visualiza janela de filtros
					  		 )
Local aRetFiltro 	:= {}
Local aHeader 		:= {}

Local cTxtFil 		:= ""

DEFAULT lShowDlg	:= .T.

/*/
��������������������������������������������������������������Ŀ
�Elabora o cabecalho do arquivo Mestre                 	       �
����������������������������������������������������������������/*/
aHeader := GdMontaHeader(NIL,NIL,NIL,cTabMestra,NIL,.T.,.T.,.F.,.F.,.F.,.F.,.F.)

/*/
��������������������������������������������������������������Ŀ
�Retorna os filtros selecionados                       	       �
����������������������������������������������������������������/*/
aRetFiltro := GpFiltro( aFilterExp, .F. )

/*/
��������������������������������������������������������������Ŀ
�Se for na inicializacao da dialog, nao mostrar a janela       �
�Caso possua mais de 1 filtro selecionado-retornar filtro Vazio�
����������������������������������������������������������������/*/
If (;
		( Len(aRetFiltro) > 1 );
		.And.;
		( lShowDlg );
	)	
	aRetFiltro := GpFiltro( aFilterExp )
ElseIf (;
			( Len(aRetFiltro) > 1 );
			.And.;
			!( lShowDlg );
		)	
	aRetFiltro := NIL
EndIf

If !Empty(aRetFiltro)
	/*/
	��������������������������������������������������������������Ŀ
	�Retorna a expressao dos filtros                      	       �
	����������������������������������������������������������������/*/
	cExpFiltro := GpFltAlsGet( aRetFiltro , cTabMestra )

	If lShowDlg
		cTxtFil    := GpFltBldDesc( cExpFiltro, @aHeader, cTabMestra )
		/*/
		��������������������������������������������������������������Ŀ
		�Janela para alteracao dos valores do filtro          	       �
		����������������������������������������������������������������/*/
		AltValExp( cTabMestra , @cExpFiltro , @cTxtFil , NIL , aHeader )
	EndIf
EndIf

Return( NIL )

/*
�����������������������������������������������������������������������Ŀ
�Fun��o    �Gpem790Arq�Autor� ABEL RIBEIRO              �Data�22/08/2008�
�����������������������������������������������������������������������Ĵ
�Descri��o �                                             				�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�������������������������������������������������������������������������/*/
Function Gpem790Arq(	cTabMestra		,;	// nome do arquivo mestre  // MUDEI AQUI
						oBtnNewFil		,;	// botao de novo filtro
						oBtnAltFil		,;  // botao de alteracao do filtro
						oBtnCalcule		 ;	// botao OK
					  )
Local lBtn		:= .T.
/*/
��������������������������������������������������������������Ŀ
�Ativar / Desativar os botoes conforme arquivo selecionado     �
����������������������������������������������������������������/*/
IF lBtn
	lBtn	:= !Empty( cTabMestra )
EndIF
oBtnNewFil:lActive 	:= lBtn
oBtnAltFil:lActive 	:= lBtn
oBtnCalcule:lActive	:= lBtn
Return( NIL )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �Gpem790SetFil�Autor� ABEL RIBEIRO           �Data�22/08/2008�
�����������������������������������������������������������������������Ĵ
�Descri��o �Setar as opcoes do Filtro									�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�������������������������������������������������������������������������/*/
Function Gpem790SetFil( aFilterExp , cTabMestra )
Local aGrpUsr		:= {}	// Grupo dos Usuarios
Local cGrpUsr		:= ""	// string com o Grupo de usuario
Local nLoop			:= 0	
aAdd( aFilterExp , { "FILTRO_ALS" , cTabMestra 	, NIL , NIL    } )
/*/		
��������������������������������������������������������������������������Ŀ
� Localizar os grupos a que o usuario pertence                             �
���������������������������������������������������������������������������� */
aGrpUsr := UsrRetGrp( SubStr( cUsuario , 7 , 15 ) )
For nLoop := 1 To Len(aGrpUsr)
	cGrpUsr := aGrpUsr[nLoop]
	aAdd( aFilterExp , { "FILTRO_GRP" , cGrpUsr 	, NIL , NIL    } )
Next nLoop
Return( NIL )                                
/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Funcao    �GPM790Log     �Autor  �ABEL RIBEIRO      � Data �  07/08/08  ���
��������������������������������������������������������������������������͹��
���Desc.     �Visualizacao do Relatoiro de Log de Processamento.           ���
��������������������������������������������������������������������������͹��
���Uso       � AP                                                          ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Static Function GPM790Log()
cPathFile := ""
cExtRel := ".##R"
cPathFile := ( __RelDir + "GPEM790" + cExtRel )
If File(cPathFile)
	OurSpool( "GPEM790" )
	Ms_Flush()
Else
	MsgStop(STR0025) // "N�o existe Log de Corre��o para exibir"
Endif

Return

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �Gpem770QbrFil�Autor� Abel Ribeiro           �Data�22/08/2008�
�����������������������������������������������������������������������Ĵ
�Descri��o �Retorna o texto do filtro qubrado em linhas            		�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�������������������������������������������������������������������������/*/
Function Gpem790QbrFil(cExpFiltro)
nLinha := 1
nStrFil := 1
cTxtFil := ""
While nStrFil <= Len(cExpFiltro)
	If nLinha > 5
		Exit
	Endif
	cTxtFil += Substr(cExpFiltro,nStrFil,80)+Chr(13)
	nStrFil+=80  
	nLinha++
EndDo
While nLinha <= 5
	cTxtFil += Chr(13)
	nLinha++
EndDo
Return(cTxtFil)
