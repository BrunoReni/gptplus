#Include "PLSMGER.CH"
#Include "PROTHEUS.CH"
#Include "COLORS.CH"                                   
/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    � PLSA631 � Autor � Daher                  � Data � 20.01.06 ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Exclusao de descontos em folha individuais                 ����
�������������������������������������������������������������������������Ĵ���
���Sintaxe   � PLSA631                                                    ����
�������������������������������������������������������������������������Ĵ���
��� Uso      � Advanced Protheus                                          ����
�������������������������������������������������������������������������Ĵ���
��� Alteracoes desde sua construcao inicial.                              ����
�������������������������������������������������������������������������Ĵ���
��� Data     � BOPS � Programador � Breve Descricao                       ����
��������������������������������������������������������������������������ٱ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
STATIC cMenu := 0

Function PLSA631()

//��������������������������������������������������������������������������Ŀ
//� Define o cabecalho da tela de atualizacoes                               �
//����������������������������������������������������������������������������
PRIVATE aRotina		:= {}
PRIVATE cCadastro	:= PLSRetTit("BDC")                       
PRIVATE nLeg	  	:= 0

cMenu := 1

aRotina := MenuDef()

//��������������������������������������������������������������������������Ŀ
//� Ajustes no dicionario...                                                 �
//� Caso o indice 19 da tabea BEAJ nao tenha cido criada nao deixa o sistema �
//� processeguir, alteracao requisita e aprovado pelo Tulio.                 �
//����������������������������������������������������������������������������
If ! CheckBEAIndex("BEAJ")
	Return .F.	
EndIf

//��������������������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE                                              �
//����������������������������������������������������������������������������
BDC->(DbSetOrder(1))
BDC->(msSeek(xFilial("BDC")))
BDC->(mBrowse(06,01,22,75,"BDC",,,,,,)) //aCores
//��������������������������������������������������������������������������Ŀ
//� Fim da Rotina Principal                                                  �
//����������������������������������������������������������������������������

Return

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    PLSA631MOV� Autor � Daher                  � Data � 02.01.06 ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Markbrowse da rotina de exlclusao		                  ����
�������������������������������������������������������������������������Ĵ���
���Sintaxe   � PLSA631                                                    ����
�������������������������������������������������������������������������Ĵ���
��� Uso      � Advanced Protheus                                          ����
�������������������������������������������������������������������������Ĵ���
��� Alteracoes desde sua construcao inicial.                              ����
�������������������������������������������������������������������������Ĵ���
��� Data     � BOPS � Programador � Breve Descricao                       ����
��������������������������������������������������������������������������ٱ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Function PLSA631MOV(cAlias,nRec,nOpc)
//���������������������������������������������������������������������Ŀ
//� Declaracao de variaveis...                                          �
//�����������������������������������������������������������������������
LOCAL   cFiltro   := ''
PRIVATE aRotina   := {}
PRIVATE cCadastro 	:= PLSRetTit("BBT")        

PRIVATE cMarcaRC	:= ''

cMenu := 2

aRotina := MenuDef()

//���������������������������������������������������������������������Ŀ
//� Chama funcao de Browse...                                           �
//�����������������������������������������������������������������������
cFiltro := "@BBT_NUMCOB = '" + BDC->(BDC_CODOPE+BDC_NUMERO) + " ' " 
//���������������������������������������������������������������������Ŀ
//� Chama funcao para pegar as marcas do mark browse...                 �
//�����������������������������������������������������������������������
cMarcaRC := GetMark()
//���������������������������������������������������������������������Ŀ
//� Limpa a marca para evitar trazer titulos marcados anteriormente     �
//�����������������������������������������������������������������������
cQuery := "UPDATE " + RetSqlName("BBT")
cQuery += " SET BBT_OK = '  ' "
cQuery += " WHERE BBT_FILIAL = '"+xFilial("BBT") +"' AND BBT_OK ='" + cMarcaRC + "' AND D_E_L_E_T_ = ' ' "

TCSqlExec( cQuery )
//���������������������������������������������������������������������Ŀ
//� filtra tabela...                                                    �
//�����������������������������������������������������������������������
dbSelectarea("BBT")
dbSetorder(2)
SET FILTER TO &cFiltro

BBT->( dbGotop() )
//���������������������������������������������������������������������Ŀ
//� Chama mark browse...                                                �
//�����������������������������������������������������������������������
BBT->(MarkBrow("BBT","BBT_OK",,,,cMarcaRC,,,,,))  

//���������������������������������������������������������������������Ŀ
//� Limpa as marcas do bBt deixadas pelo markbrow()                     �
//�����������������������������������������������������������������������
cQuery := "UPDATE " + RetSqlName("BBT")
cQuery += " SET BBT_OK = '  ' "
cQuery += " WHERE BBT_FILIAL = '"+xFilial("BBT") +"' AND BBT_OK ='" + cMarcaRC + "' AND D_E_L_E_T_ = ' ' "

TCSqlExec( cQuery )

//���������������������������������������������������������������������Ŀ
//� Fim da Rotina Principal...                                          �
//�����������������������������������������������������������������������
Return Nil                                            

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    PLSA631EXC� Autor � Daher                  � Data � 02.01.06 ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Rotina de exclusao						                  	  ����
�������������������������������������������������������������������������Ĵ���
���Sintaxe   � PLSA631                                                    ����
�������������������������������������������������������������������������Ĵ���
��� Uso      � Advanced Protheus                                          ����
�������������������������������������������������������������������������Ĵ���
��� Alteracoes desde sua construcao inicial.                              ����
�������������������������������������������������������������������������Ĵ���
��� Data     � BOPS � Programador � Breve Descricao                       ����
��������������������������������������������������������������������������ٱ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Function PLSA631EXC()   
LOCAL aFuncio   := {}
LOCAL aCritReal := {}
LOCAL nI 		:= 1     
LOCAL nJ		:= 1
LOCAL cSql      := ""    
//���������������������������������������������������������������������Ŀ
//� Confirma a exclusao dos lanctos marcados...                         �
//�����������������������������������������������������������������������
If  Aviso("Confirmacao de exclusao","Deseja realmente excluir todos os lancamentos marcados?",{"Sim","Nao"}) == 2
	Return(.F.)
Endif

//���������������������������������������������������������������������Ŀ
//� Seleciona os registros marcados para delecao...                     �
//�����������������������������������������������������������������������
cSql := "SELECT BBT_CODIGO FROM "+RetSqlName("BBT")
cSql += " WHERE BBT_FILIAL =  '" + xFilial("BBT") + "' AND BBT_OK   = '" + cMarcaRC + "' AND D_E_L_E_T_ = ' ' "
PlsQuery(cSql, "TRB1")            

TRB1->(DBEval( { | | aadd(aFuncio, {BBT_CODIGO,{}}) }))	    	
TRB1->(DbCloseArea())

For nI:= 1 to Len(aFuncio)
	
	cSql := "SELECT B1T.R_E_C_N_O_ RECB1T, B1T_AGFTFU,B1T_AGMTFU,B1T_ANO,B1T_MES,B1T_VERSIG, "
	cSql += "       B1T_PLNUCO,B1T_FILIAL,B1T_CODINT,B1T_CODEMP,B1T_MATRIC,B1T_CODBBT,B1T_CODSEQ "
	cSql += " FROM "+RetSqlName("B1T") + " B1T "
	cSql += "WHERE "
	cSql += "B1T_FILIAL = '" + xFilial("B1T") + "' AND "
	cSql += "B1T_CODBBT = '" + aFuncio[nI][1] + "' AND D_E_L_E_T_ = ' ' "
	
	PlsQuery(cSql, "TRB1T")            
	If !TRB1T->(Eof())
		TRB1T->(DBEval( { | | aadd(aFuncio[nI][2], {B1T_AGFTFU+B1T_AGMTFU+B1T_ANO+B1T_MES+B1T_VERSIG,; //[1] CHAVE SRD
														 			 .F.,;					//[2] TEM PROBLEMAS ?
														 			 B1T_AGFTFU,;			//[3] FILIAL FUN
														 			 B1T_AGMTFU,;			//[4] MATRIC FUN
														 			 B1T_PLNUCO,;			//[5] NUMERO LOTE COB
														 			 B1T_AGFTFU+B1T_AGMTFU+B1T_VERSIG,;//[6] CHAVE SRC
														 			 RECB1T,;				//[7] RECNO B1T
																	 B1T_CODINT,;           //[8] OPERADORA
														 			 B1T_CODEMP,;			//[9] EMPRESA
														 			 B1T_MATRIC,;      		//[10] MATRICULA
														 			 B1T_ANO,;				//[11] ANO
														 			 B1T_MES,;				//[12] MES
														 			 B1T_FILIAL+B1T_CODINT+B1T_CODEMP+B1T_MATRIC+B1T_ANO+B1T_MES,;//[13] CHAVE BM1
														 			 B1T_CODBBT,;//[14] CHAVE BBT 
														 			 B1T_FILIAL+B1T_ANO+B1T_MES+B1T_CODINT+B1T_CODEMP+B1T_MATRIC,; //[15]CHAVE BK2
														 			 B1T_CODINT+B1T_CODEMP+B1T_MATRIC+B1T_ANO+B1T_MES,;//[16]CHAVE BDF
														 			 B1T_CODSEQ;//[17] CHAVE B1T
														 			 }) }))	    	
	Else
		aadd(aCritReal,{"Nao existem lancamentos na folha para esta cobranca."})
	Endif
	TRB1T->(DbCloseArea())	
Next
//���������������������������������������������������������������������Ŀ
//� Verifico se os dados que ele selecionou estao consistentes          �
//�����������������������������������������������������������������������
SRD->(DbSetOrder(1))
For nI := 1 to Len(aFuncio)
	For nJ := 1 to Len(aFuncio[nI][2])
		If SRD->(MsSeek(aFuncio[nI][2][nJ][1]))
			aadd(aCritReal,{"Nao se pode excluir porque existe(m) lancamentos(s) "})
		   	aadd(aCritReal,{"ja acumulados (SRD) para o funcionario:"})			 
		   	aadd(aCritReal,{'['+aFuncio[nI][2][nJ][3]+'-'+aFuncio[nI][2][nJ][4]+']  '})
		Endif
	Next
Next                                                                     
//���������������������������������������������������������������������Ŀ
//� Se encontrei crirticas critico, se nao processo a delecao			�
//�����������������������������������������������������������������������
If  Len(aCritReal) > 0
	PLSCRIGEN(aCritReal,{ {"Criticas","@C",200} }, "  Falha na exclusao",NIL,NIL,NIL,NIL, NIL,NIL,"G",220)
	Return(.F.)
Else               
	Proc2BarGauge({|| PL631EXCLA(aFuncio) }, "Exclusao dos dados.")
Endif

Return (.T.)
/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    PL631EXCLA� Autor � Daher                  � Data � 02.01.06 ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Rotina de exclusao						                  	  ����
�������������������������������������������������������������������������Ĵ���
���Sintaxe   � PLSA631                                                    ����
�������������������������������������������������������������������������Ĵ���
��� Uso      � Advanced Protheus                                          ����
�������������������������������������������������������������������������Ĵ���
��� Alteracoes desde sua construcao inicial.                              ����
�������������������������������������������������������������������������Ĵ���
��� Data     � BOPS � Programador � Breve Descricao                       ����
��������������������������������������������������������������������������ٱ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/

Function PL631EXCLA(aFuncio)
LOCAL nI := 1
LOCAL nJ := 1          
LOCAL nForReg := 1
LOCAL nCnt := 1
Begin Transaction                                    
				             
BarGauge1Set(Len(aFuncio))     
BarGauge2Set(7*Len(aFuncio))     

For nI:= 1 to Len(aFuncio)                        
		
		IncProcG1("Excluindo ["+aFuncio[nI][1]+"]")
		ProcessMessage()            
		//���������������������������������������������������������������������Ŀ
		//� Desmarco o rembolso... 												�
		//�����������������������������������������������������������������������			
		For nJ := 1 to Len(aFuncio[nI][2])
			IncProcG2("Desmarcando [ Reembolso ]")	    
			BBT->(DbSetOrder(6))
			If BBT->(MsSeek(xFilial("BBT")+aFuncio[nI][2][nJ][14]))
				aRegs := {}
				B44->( dbSetorder(3) )
				If B44->( dbSeek(xFilial("B44")+BBT->(BBT_PREFIX + BBT_NUMTIT + BBT_PARCEL + BBT_TIPTIT)) )
					While !B44->( Eof() ) .and. B44->(B44_FILIAL+B44_PREFIX+B44_NUM+B44_PARCEL+B44_TIPO) ==;
											 xFilial("B44")+BBT->(BBT_PREFIX + BBT_NUMTIT + BBT_PARCEL + BBT_TIPTIT)

						Aadd( aRegs, B44->(Recno()) )
						B44->( dbSkip() )
					Enddo
				Endif

				For nCnt := 1 To Len(aRegs)
					B44->( dbGoto(aRegs[nCnt]) )

					If !B44->( Eof() )
						B44->( RecLock("B44", .F.) )
						B44->B44_PREFIX := ''
						B44->B44_NUM := ''
						B44->B44_PARCEL := ''
						B44->B44_TIPO := ''
						B44->( MsUnlock() )
					Endif
				Next
				
				If BKD->(DbSeek(xFilial("BKD")+BBT->BBT_NUMCOB))
					While ! BKD->(Eof()) .And. BKD->(BKD_FILIAL+BKD_PLNUCO) == xFilial("BBT")+BBT->BBT_NUMCOB
						
							If BKD->BKD_CHVSE1 == BBT->(BBT_PREFIX+BBT_NUMTIT+BBT_PARCEL+BBT_TIPTIT)
								BKD->(Reclock("BKD",.F.))
									BKD->BKD_PLNUCO := '' 
				       			BKD->BKD_CHVSE1 := ''
								BKD->(Msunlock())
							Endif
							
							BKD->(Dbskip())
					Enddo                                 
				
					
				Endif	
			Endif
		Next
		//���������������������������������������������������������������������Ŀ
		//� Desmarco as movimentacoes de co-participacao e custo operacional... �
		//�����������������������������������������������������������������������		
		For nJ := 1 to Len(aFuncio[nI][2])
			IncProcG2("Desmarcando [ BDH ]")	
			BBT->(DbSetOrder(6))
			If BBT->(MsSeek(xFilial("BBT")+aFuncio[nI][2][nJ][14]))
					aRegs := {}    
					BDH->(DbSetOrder(5))
					If BDH->(DbSeek(xFilial("BDH")+BBT->BBT_CODOPE+BBT->BBT_NUMCOB))
						While ! BDH->(Eof()) .And. BDH->(BDH_FILIAL+BDH_OPEFAT+BDH_NUMFAT) == xFilial("BDH")+BBT->BBT_CODOPE+BBT->BBT_NUMCOB
							//���������������������������������������������������������������������Ŀ
							//� Desmarco as movimentacoes de co-participacao e custo operacional... �
							//�����������������������������������������������������������������������	
					   		If BBT->(BBT_PREFIX+BBT_NUMTIT+BBT_PARCEL+BBT_TIPTIT) == BDH->(BDH_PREFIX+BDH_NUMTIT+BDH_PARCEL+BDH_TIPTIT)
						    		aadd(aRegs,BDH->(Recno()))
						    	Endif
				    	    	BDH->(DbSkip())
				        Enddo
				   Endif    
				       
				   For nForReg := 1 To Len(aRegs)
				        BDH->(DbGoTo(aRegs[nForReg]))
				        If ! FindFunction("PLSNOTXBDH") //nova funcao que alem de atualizar o bdh atualiza as notas e eventos. plsmctmd.prw
						   BDH->(RecLock("BDH",.F.))
						   		BDH->BDH_STATUS := "1"
						     	BDH->BDH_OPEFAT := ""
					            BDH->BDH_NUMFAT := ""
					            BDH->BDH_PREFIX := ""
					            BDH->BDH_NUMTIT := ""
					            BDH->BDH_PARCEL := ""
					            BDH->BDH_TIPTIT := ""
					       	BDH->(MsUnLock())
				        Else
				           PLSNOTXBDH("1","","",{"","","",""},.F.)
				        Endif   
					Next
			Endif
		Next		
		
		//���������������������������������������������������������������������Ŀ
		//� Desmarco as movimentacoes de debito / credito...                    �
		//�����������������������������������������������������������������������
		
		For nJ := 1 to Len(aFuncio[nI][2])
			IncProcG2("Desmarcando [ BSQ ]")	    
			BBT->(DbSetOrder(6))
			If BBT->(MsSeek(xFilial("BBT")+aFuncio[nI][2][nJ][14]))		
					aRegs := {}    
					BSQ->( dbSetorder(03) )
					If BSQ->( dbSeek(xFilial("BSQ")+BBT->BBT_PREFIX+BBT->BBT_NUMTIT+BBT->BBT_PARCEL+BBT->BBT_TIPTIT) )	
						While !BSQ->( Eof() ) .and. BSQ->(BSQ_PREFIX+BSQ_NUMTIT+BSQ_PARCEL+BSQ_TIPTIT) ==;
													 BBT->BBT_PREFIX+BBT->BBT_NUMTIT+BBT->BBT_PARCEL+BBT->BBT_TIPTIT
						
							Aadd( aRegs, BSQ->(Recno()) )
							BSQ->( dbSkip() )
						Enddo
					Endif
					
					For nCnt := 1 To Len(aRegs)
						BSQ->( dbGoto(aRegs[nCnt]) )
						
						If !BSQ->( Eof() )
							BSQ->( RecLock("BSQ", .F.) )
								BSQ->BSQ_NUMCOB := ''
								BSQ->BSQ_PREFIX := ''
								BSQ->BSQ_NUMTIT := ''
								BSQ->BSQ_PARCEL := ''
								BSQ->BSQ_TIPTIT := ''
							BSQ->( MsUnlock() )
						Endif
					Next
			Endif
		Next			
		//���������������������������������������������������������������������Ŀ
		//� Exclusao B1T								                        			�
		//�����������������������������������������������������������������������
		For nJ := 1 to Len(aFuncio[nI][2])
			IncProcG2("Excluindo [ B1T ]")	
			B1T->(DbGoTo(aFuncio[nI][2][nJ][7]))
			B1T->(RecLock("B1T",.F.))   
				B1T->(DbDelete())
			B1T->(MsUnlock())
		Next
		//���������������������������������������������������������������������Ŀ
		//� Exclusao BDF								                        			�
		//�����������������������������������������������������������������������
		For nJ := 1 to Len(aFuncio[nI][2])
			IncProcG2("Excluindo [ BDF ]")	
			BDF->(DbSetOrder(11))
			If BDF->(MsSeek(xFilial("BDF")+"4"+aFuncio[nI][2][nJ][16]))
					While BDF->(!Eof()) .and. xFilial("BDF")+"4"+aFuncio[nI][2][nJ][16] == BDF->(BDF_FILIAL+BDF_NIVEL+BDF_CODOPE+BDF_CODEMP+BDF_MATRIC+BDF_ANOTIT+BDF_MESTIT)
						
						BDF->(RecLock("BDF",.F.))   
							BDF->(DbDelete())
						BDF->(MsUnlock())
						
						BDF->(DbSkip())
					Enddo
			Endif
		Next
		
		//���������������������������������������������������������������������Ŀ
		//� Exclusao SRC								                        			�
		//�����������������������������������������������������������������������
		For nJ := 1 to Len(aFuncio[nI][2])
			IncProcG2("Excluindo [ SRC ]")
			SRC->(DbSetOrder(1))
			If SRC->(MsSeek(aFuncio[nI][2][nJ][6]))
				While SRC->(!Eof()) .and. aFuncio[nI][2][nJ][6] == SRC->(RC_FILIAL+RC_MAT+RC_PD)
				    If SRC->RC_PLNUCO == aFuncio[nI][2][nJ][5]
				    	If SRC->(FieldPos("RC_CODB1T")) > 0 
				    		If SRC->RC_CODB1T == aFuncio[nI][2][nJ][17]
								 SRC->(RecLock("SRC",.F.))
								 		SRC->(DbDelete())
								 SRC->(MsUnlock())
					      Endif
					   Else
					    	SRC->(RecLock("SRC",.F.))
					    		SRC->(DbDelete())
					    	SRC->(MsUnlock())
				    	Endif
				    Endif
					SRC->(DbSkip())
				Enddo
			Endif
		Next    
  		//���������������������������������������������������������������������Ŀ
		//� Exclusao RHR/RHO                                        			�
		//����������������������������������������������������������������������� 
		For nJ := 1 to Len(aFuncio[nI][2])
			IncProcG2("Excluindo [ RHR/RHO ]")
			cQuery := "DELETE FROM " + RetSqlName("RHR")
			cQuery += " WHERE RHR_FILIAL = '"+aFuncio[nI][2][nJ][3] +"' AND RHR_PLNUCO = '"+ aFuncio[nI][2][nJ][5]+"' "
			cQuery += " AND  RHR_MAT ='"+aFuncio[nI][2][nJ][4]+"' " 
			TCSqlExec( cQuery )      
			
			cQuery := "DELETE FROM " + RetSqlName("RHO")
			cQuery += " WHERE RHO_FILIAL = '"+aFuncio[nI][2][nJ][3] +"' AND RHO_PLNUCO = '"+ aFuncio[nI][2][nJ][5]+"' "
			cQuery += " AND  RHO_MAT ='"+aFuncio[nI][2][nJ][4]+"' " 
			TCSqlExec( cQuery )
	
		Next
		//���������������������������������������������������������������������Ŀ
		//� Exclusao BK2								                        			�
		//�����������������������������������������������������������������������
		For nJ := 1 to Len(aFuncio[nI][2])
			IncProcG2("Excluindo [ BK2 ]")	
			BK2->(DbSetOrder(4))
			If BK2->(MsSeek(aFuncio[nI][2][nJ][15]))
				While BK2->(!Eof()) .and. aFuncio[nI][2][nJ][15] == BK2->(BK2_FILIAL+BK2_ANO+BK2_MES+BK2_CODINT+BK2_CODEMP+BK2_MATRIC)
				    If BK2->BK2_PLNUCO == aFuncio[nI][2][nJ][5]
				    	BK2->(RecLock("BK2",.F.))
				    		BK2->(DbDelete())
				    	BK2->(MsUnlock())
				    Endif
					BK2->(DbSkip())
				Enddo
			Endif
		Next
		//���������������������������������������������������������������������Ŀ
		//� Exclusao BM1								                        			�
		//�����������������������������������������������������������������������
		For nJ := 1 to Len(aFuncio[nI][2])
			IncProcG2("Excluindo [ BM1 ]")
			BM1->(DbSetOrder(1))
			If BM1->(MsSeek(aFuncio[nI][2][nJ][13]))
				While BM1->(!Eof()) .and. aFuncio[nI][2][nJ][13] == BM1->(BM1_FILIAL+BM1_CODINT+BM1_CODEMP+BM1_MATRIC+BM1_ANO+BM1_MES)
				    If BM1->BM1_PLNUCO == aFuncio[nI][2][nJ][5] 
				    	BM1->(RecLock("BM1",.F.))
				    		BM1->(DbDelete())
				    	BM1->(MsUnlock())
				    Endif
					BM1->(DbSkip())
				Enddo
			Endif
		Next
		//���������������������������������������������������������������������Ŀ
		//� Exclusao BBT								                        			�
		//�����������������������������������������������������������������������
		For nJ := 1 to Len(aFuncio[nI][2])
			IncProcG2("Excluindo [ BBT ]")
			BBT->(DbSetOrder(6))
			If BBT->(MsSeek(xFilial("BBT")+aFuncio[nI][2][nJ][14]))
				While BBT->(!Eof()) .and. xFilial("BBT")+aFuncio[nI][2][nJ][14] == BBT->(BBT_FILIAL+BBT_CODIGO)
				    If BBT->BBT_NUMCOB == aFuncio[nI][2][nJ][5]
				    	BBT->(RecLock("BBT",.F.))
				    		BBT->(DbDelete())
				    	BBT->(MsUnlock())
				    Endif
					BBT->(DbSkip())
				Enddo
			Endif
		Next
Next  
End transaction      
                                                   
return


Function PLSA631VIS

AxVisual("BBT",BBT->(Recno()),K_Visualizar)
                                                                            
Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Darcio R. Sporl       � Data �05/01/2007���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Utilizacao de menu Funcional                               ���
���          �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Array com opcoes da rotina.                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Parametros do array a Rotina:                               ���
���          �1. Nome a aparecer no cabecalho                             ���
���          �2. Nome da Rotina associada                                 ���
���          �3. Reservado                                                ���
���          �4. Tipo de Transa��o a ser efetuada:                        ���
���          �		1 - Pesquisa e Posiciona em um Banco de Dados           ���
���          �    2 - Simplesmente Mostra os Campos                       ���
���          �    3 - Inclui registros no Bancos de Dados                 ���
���          �    4 - Altera o registro corrente                          ���
���          �    5 - Remove o registro corrente do Banco de Dados        ���
���          �5. Nivel de acesso                                          ���
���          �6. Habilita Menu Funcional                                  ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef()
	Private aRotina := {}

	If cMenu == 1

		aRotina := {	{ STRPL01	, 'AxPesqui' 							 , 0 , K_Pesquisar	, 0, .F.},;  //"Pesquisar"
		{ "Selecionar"	, 'PLSA631Menu' , 0 , K_Incluir 	, 0, Nil} }   

	Elseif cMenu == 2
		aRotina :=          { 	{ STRPL01        ,'AxPesqui' , 0 ,K_Pesquisar   },; 
		{ STRPL02        ,'PLSA631VIS' , 0 ,K_Visualizar   },; 
		{ STRPL05	          ,'PLSA631EXC' , 0 ,K_Excluir     }}

	Else
		aRotina := {	{ STRPL01	, 'AxPesqui' 							 , 0 , K_Pesquisar	, 0, .F.},;  //"Pesquisar"
		{ "Selecionar"	, 'PLSA631Menu' , 0 , K_Incluir 	, 0, Nil},;
		{ STRPL01        ,'AxPesqui' , 0 ,K_Pesquisar   },; 
		{ STRPL02        ,'PLSA631VIS' , 0 ,K_Visualizar   },; 
		{ STRPL05	          ,'PLSA631EXC' , 0 ,K_Excluir     }}
	Endif

Return(aRotina)

/*
PLSA631Menu
*/
Function PLSA631Menu ()
    PLSA631MOV("BDC", BDC->(Recno()), 3)
Return
