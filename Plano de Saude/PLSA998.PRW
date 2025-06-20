#include "PROTHEUS.CH"    
#include "PLSMGER.CH"   
#include "PLSA998.CH"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � PLSA998  � Autor � Microsiga             � Data � 23.04.12 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Contagem de beneficiarios para o PTU Online                ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � PLSA998()                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function PLSA998(cMes,cAno)     
//��������������������������������������������������������������������������Ŀ
//� Define o cabecalho da tela de atualizacoes                               �
//����������������������������������������������������������������������������
PRIVATE aRotina   := { 	{ STR0001   , 'AxPesqui'  , 0 , K_Pesquisar  	},; //'Pesquisar'
                        { STR0002   , 'AxVisual'  , 0 , K_Visualizar 	},; //'Visualizar'
                        { STR0003   , 'PLSA998MOV', 0 , K_Incluir    	},; //'Incluir'
                        { STR0004   , 'AxDeleta'  , 0 , K_Excluir     }} // 'Excluir'
PRIVATE cFilter	  := ""  
PRIVATE cCadastro := STR0005 //"Contagem de Benefici�rios"          

AjustaSX1()
//��������������������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE                                              �
//����������������������������������������������������������������������������
B0Z->(DbSetOrder(1))
B0Z->(mBrowse(006,001,022,075,"B0Z",,,,,,))

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �PLSA998MOV� Autor � Microsiga             � Data � 23.04.12 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Exibe parametros para realizar a contagem de beneficiarios ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � PLSA998()                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function PLSA998MOV()
Local cAno := ""
Local cMes := ""

If !Pergunte("PLS998")
	Return
EndIf 

cAno := mv_par01
cMes := mv_par02
                  
If Empty(cAno) .Or. Empty(cMes)
    MsgInfo(STR0006) //"� necess�rio informar o Ano e M�s"
Else
	MsAguarde({|| PLSA998Pro(cAno,cMes)}, "", STR0007, .T.) //"Processando Contagem de Benefici�rios"
EndIf	
         

Return
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �PLSA998Pro� Autor � Microsiga             � Data � 23.04.12 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Processa a contagem de  beneficiarios para o PTU Online    ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � PLSA998()                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function PLSA998Pro(cAno,cMes,lAuto)
Local cSQL1     := ""
Local cSQL2     := ""    
Local cSQL3     := ""  
Local cSQLCond1 := ""       
Local cSQLCond2 := ""       
Local aQtd      := {}    
Local dData      
Local cCodEmpInt := Alltrim(GetNewPar("MV_PLSGEIN","")) 
Default lAuto    := .F.
//��������������������������������������������������������������������������Ŀ
//� Verifica ultimo dia do mes                                               �
//����������������������������������������������������������������������������                
If cMes $ "01-03-05-07-08-10-12"        
	dData := Ctod("31/"+cMes+"/"+cAno)
ElseIf cMes $ "04-06-09-11"
	dData := Ctod("30/"+cMes+"/"+cAno)
Else
	dData := Ctod("29/"+cMes+"/"+cAno)
EndIf	      

B0Z->(DbSetOrder(1))//B0Z_FILIAL+B0Z_ANO+B0Z_MES
If B0Z->(DbSeek(xFilial("B0Z")+cAno+cMes))  
	if !lAuto
		MsgInfo(STR0008)//"Ano/M�s j� processado"
	endIf
	Return
EndIf
//��������������������������������������������������������������������������Ŀ
//� Monta Query b�sica                                                       �
//����������������������������������������������������������������������������
cSQL1 := " SELECT COUNT(BA1_FILIAL) QTD FROM "+RetSqlName("BA1")+" BA1 "
cSQL1 += " INNER JOIN "+RetSQLName("BA3")+" BA3 "
cSQL1 += " ON  BA1_FILIAL = BA3_FILIAL "
cSQL1 += " AND BA1_CODINT = BA3_CODINT "
cSQL1 += " AND BA1_CODEMP = BA3_CODEMP "
cSQL1 += " AND BA1_MATRIC = BA3_MATRIC "   
cSQL1 += " AND BA3_MOTBLO = ' ' "
cSQL1 += " AND BA1_CODEMP <> '"+cCodEmpInt+"' "

cSQL2 := " AND BA3.D_E_L_E_T_ = ' ' "
cSQL2 += " INNER JOIN "+RetSqlName("BI3")+" BI3 "
cSQL2 += " ON  BI3_FILIAL = CASE "
cSQL2 += "     WHEN BA1_CODPLA = ' ' THEN BA3_FILIAL "
cSQL2 += "     ELSE  BA3_FILIAL END " 
cSQL2 += " AND BI3_CODIGO = CASE " 
cSQL2 += "     WHEN BA1_CODPLA = ' ' THEN BA3_CODPLA " 
cSQL2 += "     ELSE  BA3_CODPLA END "
cSQL2 += " AND BI3_VERSAO = CASE " 
cSQL2 += "     WHEN BA1_CODPLA = ' ' THEN BA3_VERSAO "
cSQL2 += "     ELSE  BA1_VERSAO END "     
//��������������������������������������������������������������������������Ŀ
//� Monta cSQL3 para usuarios nao repassados para outra Operadora            �
//����������������������������������������������������������������������������     
cSQL3 := " AND BI3.D_E_L_E_T_ = ' ' "
cSQL3 += " WHERE "
cSQL3 += " BA1_FILIAL = '"+xFilial("BA1")+"' "  
cSQL3 += " AND BA1.D_E_L_E_T_ = ' ' "   
cSQL3 += " AND BA1_MOTBLO = ' ' "    
cSQL3 += " AND BA1_DATREP = ' ' "  
cSQl3 += " AND BA1_DATINC <= '"+Dtoc(dData)+"' "       
cSQL3 += " AND BA1_OPEORI = '"+PlsIntPad()+"' "
cSQL3 += " AND BA1_OPEDES = '"+PlsIntPad()+"' "    
//cSQL3 += " AND BA1_OPERES = '"+PlsIntPad()+"' "   

//��������������������������������������������������������������������������Ŀ
//� QT_BEN_PF_CO_LOC - N�mero de Benefici�rios ativos Pessoa F�sica com      �
//� contrato em Custo Operacional n�o repassado                              �
//����������������������������������������������������������������������������
cSQLCond1 := " AND BA3_TIPOUS = '1' "  
cSQLCond2 := " AND BI3_MODPAG <> '1' "  

cSQL := cSQL1 + cSQLCond1 + cSQL2 + cSQLCond2 + cSQL3 

cSQL := ChangeQuery(cSQL)  
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"TRB998",.T.,.F.)    

TRB998->(DbGotop())      
Aadd(aQtd,TRB998->QTD)//QT_PFCOLOC
TRB998->( dbClosearea() )                

//��������������������������������������������������������������������������Ŀ
//� QT_BEN_PF_PP_LOC - N�mero de Benefici�rios ativos Pessoa F�sica com      �
//� contrato em Pr� Pagamento n�o repassado                                  �
//����������������������������������������������������������������������������
cSQLCond1 := " AND BA3_TIPOUS = '1' "  
cSQLCond2 := " AND BI3_MODPAG = '1' "  

cSQL := cSQL1 + cSQLCond1 + cSQL2 + cSQLCond2 + cSQL3 

cSQL := ChangeQuery(cSQL)  
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"TRB998",.T.,.F.)    

TRB998->(DbGotop())        
Aadd(aQtd,TRB998->QTD)//QT_PFPPLOC
TRB998->( dbClosearea() )   

//��������������������������������������������������������������������������Ŀ
//� QT_BEN_PJ_CO_LOC - N�mero de Benefici�rios ativos Pessoa Jur�dica com    �
//� contrato em Custo Operacional n�o repassado                              �
//����������������������������������������������������������������������������
cSQLCond1 := " AND BA3_TIPOUS = '2' "  
cSQLCond2 := " AND BI3_MODPAG <> '1' "  
  
cSQL := cSQL1 + cSQLCond1 + cSQL2 + cSQLCond2 + cSQL3

cSQL := ChangeQuery(cSQL)  
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"TRB998",.T.,.F.)    

TRB998->(DbGotop())
Aadd(aQtd,TRB998->QTD) //QT_PJCOLOC
TRB998->( dbClosearea() )

//��������������������������������������������������������������������������Ŀ
//� QT_BEN_PJ_PP_LOC - N�mero de Benefici�rios ativos Pessoa Jur�dica com    �
//� contrato em Pr� Pagamento n�o repassado 		                         �
//����������������������������������������������������������������������������
cSQLCond1 := " AND BA3_TIPOUS = '2' "  
cSQLCond2 := " AND BI3_MODPAG = '1' "  
  
cSQL := cSQL1 + cSQLCond1 + cSQL2 + cSQLCond2 + cSQL3

cSQL := ChangeQuery(cSQL)  
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"TRB998",.T.,.F.)    

TRB998->(DbGotop())
Aadd(aQtd,TRB998->QTD) //QT_PJPPLOC
TRB998->( dbClosearea() )   
   
//��������������������������������������������������������������������������Ŀ
//� Monta cSQL3 para usuarios repassados para outra Operadora                �
//����������������������������������������������������������������������������                                      
cSQL3 := " AND BI3.D_E_L_E_T_ = ' ' "
cSQL3 += " WHERE "
cSQL3 += " BA1_FILIAL = '"+xFilial("BA1")+"' "  
cSQL3 += " AND BA1.D_E_L_E_T_ = ' ' "     
cSQL3 += " AND BA1_MOTBLO = ' ' "   
cSQL3 += " AND BA1_DATREP <= '"+Dtoc(dData)+"' "    
cSQl3 += " AND BA1_DATINC <= '"+Dtoc(dData)+"' "       
cSQL3 += " AND BA1_OPEORI = '"+PlsIntPad()+"' "
cSQL3 += " AND BA1_OPEDES <> '"+PlsIntPad()+"' "    
//cSQL3 += " AND BA1_OPERES <> '"+PlsIntPad()+"' "   

//��������������������������������������������������������������������������Ŀ
//� QT_BEN_PF_REP_CO - N�mero de Benefici�rios ativos Pessoa F�sica          �
//� repassados para outra Unimed em Custo Operacional                        �
//����������������������������������������������������������������������������
cSQLCond1 := " AND BA3_TIPOUS = '1' "  
cSQLCond2 := " AND BI3_MODPAG <> '1' "  

cSQL := cSQL1 + cSQLCond1 + cSQL2 + cSQLCond2 + cSQL3 

cSQL := ChangeQuery(cSQL)  
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"TRB998",.T.,.F.)    

TRB998->(DbGotop())
Aadd(aQtd,TRB998->QTD) //QT_PFREPPP
TRB998->( dbClosearea() )     

//��������������������������������������������������������������������������Ŀ
//� QT_BEN_PF_REP_PP - N�mero de Benefici�rios ativos Pessoa F�sica          �
//� repassados para outra Unimed em Pr� Pagamento                            �
//����������������������������������������������������������������������������
cSQLCond1 := " AND BA3_TIPOUS = '1' "  
cSQLCond2 := " AND BI3_MODPAG = '1' "  

cSQL := cSQL1 + cSQLCond1 + cSQL2 + cSQLCond2 + cSQL3 

cSQL := ChangeQuery(cSQL)  
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"TRB998",.T.,.F.)    

TRB998->(DbGotop())
Aadd(aQtd,TRB998->QTD)  //QT_PJREPCO
TRB998->( dbClosearea() )          

//��������������������������������������������������������������������������Ŀ
//� QT_BEN_PJ_REP_CO - N�mero de Benefici�rios ativos Pessoa Jur�dica        �
//� repassados para outra Unimed em Custo Operacional                        �
//����������������������������������������������������������������������������
cSQLCond1 := " AND BA3_TIPOUS = '2' "  
cSQLCond2 := " AND BI3_MODPAG <> '1' "  

cSQL := cSQL1 + cSQLCond1 + cSQL2 + cSQLCond2 + cSQL3 

cSQL := ChangeQuery(cSQL)  
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"TRB998",.T.,.F.)    

TRB998->(DbGotop())
Aadd(aQtd,TRB998->QTD) //QT_PJREPCO
TRB998->( dbClosearea() ) 

//��������������������������������������������������������������������������Ŀ
//� QT_BEN_PJ_REP_PP - N�mero de Benefici�rios ativos Pessoa Jur�dica        �
//� repassados para outra Unimed em Pr� Pagamento	                         �
//����������������������������������������������������������������������������
cSQLCond1 := " AND BA3_TIPOUS = '2' "  
cSQLCond2 := " AND BI3_MODPAG = '1' "  
  
cSQL := cSQL1 + cSQLCond1 + cSQL2 + cSQLCond2 + cSQL3

cSQL := ChangeQuery(cSQL)  
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"TRB998",.T.,.F.)    

TRB998->(DbGotop())
Aadd(aQtd,TRB998->QTD) //QT_PJPPLOC
TRB998->( dbClosearea() )              

//��������������������������������������������������������������������������Ŀ
//� Monta cSQL3 para usuarios repassados por outra Operadora                 �
//����������������������������������������������������������������������������                                      
cSQL3 := " AND BI3.D_E_L_E_T_ = ' ' "
cSQL3 += " WHERE "
cSQL3 += " BA1_FILIAL = '"+xFilial("BA1")+"' "  
cSQL3 += " AND BA1.D_E_L_E_T_ = ' ' "     
cSQL3 += " AND BA1_MOTBLO = ' ' "   
cSQL3 += " AND BA1_DATREP <= '"+Dtoc(dData)+"' "    
cSQl3 += " AND BA1_DATINC <= '"+Dtoc(dData)+"' "       
cSQL3 += " AND BA1_OPEORI <> '"+PlsIntPad()+"' "
cSQL3 += " AND BA1_OPEDES = '"+PlsIntPad()+"' "    
//cSQL3 += " AND BA1_OPERES = '"+PlsIntPad()+"' "     

//��������������������������������������������������������������������������Ŀ
//� QT_BEN_PF_REC_CO - N�mero de Benefici�rios ativos Pessoa F�sica          �
//� recebidos de outra Unimed em Custo Operacional                           �
//����������������������������������������������������������������������������
cSQLCond1 := " AND BA3_TIPOUS = '1' "  
cSQLCond2 := " AND BI3_MODPAG <> '1' "  

cSQL := cSQL1 + cSQLCond1 + cSQL2 + cSQLCond2 + cSQL3 

cSQL := ChangeQuery(cSQL)  
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"TRB998",.T.,.F.)    

TRB998->(DbGotop())
Aadd(aQtd,TRB998->QTD)  //QT_PFRECCO
TRB998->( dbClosearea() )     

//��������������������������������������������������������������������������Ŀ
//� QT_BEN_PF_REC_PP - N�mero de Benefici�rios ativos Pessoa F�sica          �
//� recebidos de outra Unimed em Pr� Pagamento                               �
//����������������������������������������������������������������������������
cSQLCond1 := " AND BA3_TIPOUS = '1' "  
cSQLCond2 := " AND BI3_MODPAG = '1' "  

cSQL := cSQL1 + cSQLCond1 + cSQL2 + cSQLCond2 + cSQL3 

cSQL := ChangeQuery(cSQL)  
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"TRB998",.T.,.F.)    

TRB998->(DbGotop())
Aadd(aQtd,TRB998->QTD)  //QT_PFRECPP
TRB998->( dbClosearea() )          

//��������������������������������������������������������������������������Ŀ
//� QT_BEN_PJ_REC_CO - N�mero de Benefici�rios ativos Pessoa Jur�dica        �
//� recebidos de outra Unimed em Custo Operacional                           �
//����������������������������������������������������������������������������
cSQLCond1 := " AND BA3_TIPOUS = '2' "  
cSQLCond2 := " AND BI3_MODPAG <> '1' "  
  
cSQL := cSQL1 + cSQLCond1 + cSQL2 + cSQLCond2 + cSQL3

cSQL := ChangeQuery(cSQL)  
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"TRB998",.T.,.F.)    

TRB998->(DbGotop())
Aadd(aQtd,TRB998->QTD)  //QT_PJRECCO
TRB998->( dbClosearea() )

//��������������������������������������������������������������������������Ŀ
//� QT_BEN_PJ_REC_PP - N�mero de Benefici�rios ativos Pessoa Jur�dica        �
//� recebidos de outra Unimed em Pr� Pagamento		                         �
//����������������������������������������������������������������������������
cSQLCond1 := " AND BA3_TIPOUS = '2' "  
cSQLCond2 := " AND BI3_MODPAG = '1' "  
  
cSQL := cSQL1 + cSQLCond1 + cSQL2 + cSQLCond2 + cSQL3

cSQL := ChangeQuery(cSQL)  
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"TRB998",.T.,.F.)    

TRB998->(DbGotop())
Aadd(aQtd,TRB998->QTD) //QT_PJRECPP
TRB998->( dbClosearea() ) 

//��������������������������������������������������������������������������Ŀ
//� Gera registro com a Contagem - B0Z                                       �
//����������������������������������������������������������������������������
B0Z->( RecLock("B0Z",.T.) )
B0Z->B0Z_FILIAL := xFilial("B0Z")
B0Z->B0Z_ANO    := cAno
B0Z->B0Z_MES    := cMes
B0Z->B0Z_PFCOLO := aQtd[1]
B0Z->B0Z_PFPPLO := aQtd[2]
B0Z->B0Z_PJCOLO := aQtd[3]
B0Z->B0Z_PJPPLO := aQtd[4]
B0Z->B0Z_PFRPCO := aQtd[5]
B0Z->B0Z_PFRPPP := aQtd[6]
B0Z->B0Z_PJRPCO := aQtd[7]
B0Z->B0Z_PJRPPP := aQtd[8]
B0Z->B0Z_PFRCCO := aQtd[9]
B0Z->B0Z_PFRCPP := aQtd[10]
B0Z->B0Z_PJRCCO := aQtd[11]
B0Z->B0Z_PJRCPP := aQtd[12]
B0Z->( MsUnLock() )
if !lAuto
	MsgInfo(STR0009) //"Contagem de beneficiarios processada com sucesso"
endIf

Return    

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �AjustaSX1 �Autor  � Microsiga			  � Data �  27/04/12   ���
��������������������������������������������������������������������������͹��
���Desc.     �Cria o pergunte padrao                                       ���
��������������������������������������������������������������������������͹��
���Uso       � AP                                                          ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Static Function AjustaSX1()

Local aRegs	:=	{}

aadd(aRegs,{"PLS998","01","Ano","","","mv_ch1","C", 4,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","","","","9999"})
aadd(aRegs,{"PLS998","02","Mes","","","mv_ch2","C", 2,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","","","","99"})
  
PlsVldPerg( aRegs )

Return
