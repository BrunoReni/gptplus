#INCLUDE "PROTHEUS.CH" 
#INCLUDE "APWIZARD.CH"
#INCLUDE "FINR220.CH"

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � FINR220  � Autor � Cesar Augusto Bianchi � Data � 18/12/08 ���
�������������������������������������������������������������������������Ĵ��
���Objetivos �           RELATORIO MAPA RESUMO DE CAIXA               	  ���
���          �Realiza a impressao do Mapa Resumo de Caixa a partir dos pa-���
���          �rametros informados, utilizando as impressoras disponiveis  ���
���          �na pasta "Impressoras" do sistema operacional ou atraves dos���
���          �equipamentos ECF configurados na estacao em execucao.  	  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � FINR220()                                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAGE/SIGAFIN - Contas a Receber                          ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���            �        �      �                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/    
Function FINR220(cUser,cLote)
Local cTitulo 	:= STR0001
Local cPerg   	:= 'FIR220'   
Private aReturn := {"Zebrado", 1, "Administracao", 2, 2, 1,"",1}
Private m_pag   := 01   

//���������������������������������������������������������������������Ŀ
//�Caso a funcao seja chamada de dentro da rotina de fechamento de caixa�
//�����������������������������������������������������������������������
if FunName() == "FINA222" .and. valtype(cUser) == "C" .and. !Empty(cUser)
	SetMVValue(cPerg,"MV_PAR01",cUser)
	SetMVValue(cPerg,"MV_PAR02",cLote)
else
	//�����������������������������������������������������������������������������������������������Ŀ
	//�Limpa os ultimos parametros utilizados para evitar a utilizacao de um lote com um outro usuario�
	//�������������������������������������������������������������������������������������������������
	SetMVValue(cPerg,"MV_PAR01","")
	SetMVValue(cPerg,"MV_PAR02","")
endif

//����������������������������������Ŀ
//�Exibe interface do tipo "Pergunte"�
//������������������������������������
Pergunte(cPerg,.F.)
wnrel := SetPrint('FIB','FIR220',cPerg,@cTitulo,"","","",.F.,{},.F.,"P",,.F.,.F.,,,.F.,'COM1')

If nLastKey == 27
	Set Filter To
	Return
EndIf

//���������������������
//�Imprime o relatorio�
//���������������������
SetDefault(aReturn,'FIB')
RptStatus({|lEnd| Fnr220Stp(MV_PAR01,MV_PAR02)},cTitulo)

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FNr220Stp �Autor  �Cesar A. Bianchi    � Data �  29/12/08   ���
�������������������������������������������������������������������������͹��
���          �Realiza a impressao do Mapa Resumo de Caixa a partir dos pa-���
���          �rametros informados, utilizando as impressoras disponiveis  ���
���          �na pasta "Impressoras" do sistema operacional - SETPRINT    ���
�������������������������������������������������������������������������͹��
���Uso       � MP811/912 - Integracao Protheus x Classis .NET             ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function FNr220Stp(cUser,cLote)
Local cCodCxa := Posicione('FID',1,xFilial('FID')+cUser,"FID_NCAIXA")                                                 
Local cEfeDN := alltrim(Transform(FN222Calc(cCodCxa,cLote,'1',.F.) + iif(GetNewPar('MV_FINTRC',.F.),Posicione('FIB',1,xFilial('FIB')+cLote,"FIB_VLRABR"),0),"@E 999,999,999.99"))
Local cEfeCH := alltrim(Transform(FN222Calc(cCodCxa,cLote,'2',.F.),"@E 999,999,999.99"))
Local cEfeCC := alltrim(Transform(FN222Calc(cCodCxa,cLote,'4',.F.),"@E 999,999,999.99"))
Local cEfeCD := alltrim(Transform(FN222Calc(cCodCxa,cLote,'3',.F.),"@E 999,999,999.99"))
Local cEfeNC := alltrim(Transform(FN222Calc(cCodCxa,cLote,'5',.F.),"@E 999,999,999.99"))
Local cEfeTt := alltrim(Transform(FN222Calc(cCodCxa,cLote,'1',.F.) + FN222Calc(cCodCxa,cLote,'2',.F.) + FN222Calc(cCodCxa,cLote,'3',.F.) + FN222Calc(cCodCxa,cLote,'4',.F.)+ FN222Calc(cCodCxa,cLote,'5',.F.) + iif(GetNewPar('MV_FINTRC',.F.),Posicione('FIB',1,xFilial('FIB')+cLote,"FIB_VLRABR"),0),"@E 999,999,999.99"))

Local cReaDN := alltrim(Transform(Posicione('FIB',1,xFilial('FIB')+cLote,"FIB_VLRDN"),"@E 999,999,999.99"))
Local cReaCH := alltrim(Transform(Posicione('FIB',1,xFilial('FIB')+cLote,"FIB_VLRCH"),"@E 999,999,999.99"))
Local cReaCC := alltrim(Transform(Posicione('FIB',1,xFilial('FIB')+cLote,"FIB_VLRCC"),"@E 999,999,999.99"))
Local cReaCD := alltrim(Transform(Posicione('FIB',1,xFilial('FIB')+cLote,"FIB_VLRCD"),"@E 999,999,999.99"))
Local cReaNC := alltrim(Transform(Posicione('FIB',1,xFilial('FIB')+cLote,"FIB_VLRNC"),"@E 999,999,999.99"))
Local cReaTt := alltrim(Transform(Posicione('FIB',1,xFilial('FIB')+cLote,"FIB_VLRDN")+Posicione('FIB',1,xFilial('FIB')+cLote,"FIB_VLRCH")+Posicione('FIB',1,xFilial('FIB')+cLote,"FIB_VLRCC")+Posicione('FIB',1,xFilial('FIB')+cLote,"FIB_VLRCD")+Posicione('FIB',1,xFilial('FIB')+cLote,"FIB_VLRNC"),"@E 999,999,999.99"))

Local cDifDN := alltrim(Transform( -1 * (iif(GetNewPar('MV_FINTRC',.F.),Posicione('FIB',1,xFilial('FIB')+cLote,"FIB_VLRABR"),0) + (FN222Calc(cCodCxa,cLote,'1',.F.) - Posicione('FIB',1,xFilial('FIB')+cLote,"FIB_VLRDN"))) , "@E 999,999,999.99"))
Local cDifCH := alltrim(Transform( -1 * (FN222Calc(cCodCxa,cLote,'2',.F.) - Posicione('FIB',1,xFilial('FIB')+cLote,"FIB_VLRCH")) ,"@E 999,999,999.99"))
Local cDifCC := alltrim(Transform( -1 * (FN222Calc(cCodCxa,cLote,'4',.F.) - Posicione('FIB',1,xFilial('FIB')+cLote,"FIB_VLRCC")) ,"@E 999,999,999.99"))
Local cDifCD := alltrim(Transform( -1 * (FN222Calc(cCodCxa,cLote,'3',.F.) - Posicione('FIB',1,xFilial('FIB')+cLote,"FIB_VLRCD")) ,"@E 999,999,999.99"))
Local cDifNC := alltrim(Transform( -1 * (FN222Calc(cCodCxa,cLote,'5',.F.) - Posicione('FIB',1,xFilial('FIB')+cLote,"FIB_VLRNC")) ,"@E 999,999,999.99"))

Local cDtAbre := DTOC(Posicione('FIB',1,xFilial('FIB')+cLote,"FIB_DTABR"))
Local cHrAbre := Posicione('FIB',1,xFilial('FIB')+cLote,"FIB_HRABR")
Local cDtFech := DTOC(Posicione('FIB',1,xFilial('FIB')+cLote,"FIB_DTFCH"))
Local cHrFech := Posicione('FIB',1,xFilial('FIB')+cLote,"FIB_HRFCH")    

Local cTpAbre := iif(Posicione('FIB',1,xFilial('FIB')+cLote,"FIB_TPABRE") == "S",STR0002,STR0003) 
Local cUsAbre := Posicione('FIB',1,xFilial('FIB')+cLote,"FIB_USABRE")
Local cTpFecha:= iif(Posicione('FIB',1,xFilial('FIB')+cLote,"FIB_TPFECH") == "S",STR0002,STR0003) 
Local cUsFecha:= Posicione('FIB',1,xFilial('FIB')+cLote,"FIB_USFECH") 

Local cVlrIni := alltrim(Transform(Posicione('FIB',1,xFilial('FIB')+cLote,"FIB_VLRABR") ,"@E 999,999,999.99"))
Local cTotCxa := cReaTt

Private Li     := 01  
Private ColA   := 01 
Private ColB   := 26

//�������������������������������������Ŀ
//�Monta o Nome dos usuarios Abre. Caixa�
//���������������������������������������
cUsAbre  := substr( alltrim(cUsAbre)  + " " + alltrim(Posicione('FID',1,xFilial('FID')+cUsAbre,"FID_NOME")),1,22)
cUsFecha := substr( alltrim(cUsFecha) + " " + alltrim(Posicione('FID',1,xFilial('FID')+cUsFecha,"FID_NOME")),1,20)
cCodCxa  := alltrim(cCodCxa)

//���������������������������Ŀ
//�Imprime o Cabecalho Inicial�
//�����������������������������
@ Li++,ColA PSAY Replicate('#',40)
@ Li++,ColA PSAY STR0004 					//MAPA RESUMO DE CAIXA"
@ Li++,ColA PSAY Replicate('#',40)

//�������������������������Ŀ
//�Imprime os dados iniciais�
//���������������������������
FNR220Conv(STR0005,cCodCxa,.F.)	 			//Caixa
FNR220Conv(STR0006,cUser,.F.) 				//Usuario
FNR220Conv(STR0007,cLote,.F.) 				//Lote                          '
FNR220Conv(STR0008,cDtAbre,.F.) 			//Data Abertura
FNR220Conv(STR0009,cHrAbre,.F.) 			//Hora Abertura
FNR220Conv(STR0010,cDtFech,.F.) 			//Data Fechamento
FNR220Conv(STR0011,cHrFech,.F.) 			//Hora Fechamento
FNR220Conv(STR0012,cTotCxa,.F.)			 	//Total em Caixa
FNR220Conv(STR0013,cTpAbre,.F.) 			//Tipo de Abertura
FNR220Conv(STR0014,cUsAbre,.F.) 			//Usuario Abertura
FNR220Conv(STR0015,cTpFecha,.F.)			//Tipo de Fechamento:
FNR220Conv(STR0016,cUsFecha,.F.)			//Usuario Fechamento:
If GetNewPar('MV_FINTRC',.F.)
	FNR220Conv(STR0017,cVlrIni,.F.)				//Valor Inicial:
EndIf
FNR220Conv(STR0018,dtoc(dDatabase),.F.)	//Data Impressao:
FNR220Conv(STR0019,Time(),.F.)        		//Hora Impressao:
                              
//�������������������������������Ŀ
//�Imprime os "Valores Efetivados'�
//���������������������������������
@ Li++ ,ColA PSAY Replicate('_',40)
@ Li++ ,ColA PSAY STR0020					//VALORES EFETIVADOS EM CAIXA
@ Li++ ,ColA PSAY Replicate('_',40) 
FNR220Conv(STR0021,cEfeDN,.F.)           	//Total Dinheiro
FNR220Conv(STR0022,cEfeCH,.F.)             //Total Cheques
FNR220Conv(STR0023,cEfeCC,.F.)             //Total Cartao Credito
FNR220Conv(STR0024,cEfeCD,.F.)             //Total Cartao Debito
FNR220Conv(STR0034,cEfeNC,.F.)             //Total NCC
FNR220Conv(STR0025,cEfeTt,.F.)             //Total Geral Efetivado

//��������������������������Ŀ
//�Imprime os "Valores Reais'�
//����������������������������
@ Li++ ,ColA PSAY Replicate('_',40)
@ Li++ ,ColA PSAY STR0027 					//VALORES REAIS EM CAIXA
@ Li++ ,ColA PSAY Replicate('_',40)
FNR220Conv(STR0021,cReaDN,.F.)				//Total Dinheiro
FNR220Conv(STR0022,cReaCH,.F.)				//Total Cheques
FNR220Conv(STR0023,cReaCC,.F.)				//Total Cartao Credito
FNR220Conv(STR0024,cReaCD,.F.)				//Total Cartao Debito
FNR220Conv(STR0034,cReaNC,.F.)             //Total NCC
FNR220Conv(STR0026,cReaTt,.F.)				//Total Geral Real

//��������������������������Ŀ
//�Imprime as "Diferencas'   �
//����������������������������
@ Li++ ,ColA PSAY Replicate('_',40)
@ Li++ ,ColA PSAY STR0028 					//DIFERENCAS EM CAIXA
@ Li++ ,ColA PSAY Replicate('_',40)
FNR220Conv(STR0029,cDifDN,.F.)				//Dinheiro:
FNR220Conv(STR0030,cDifCH,.F.)				//Cheques:
FNR220Conv(STR0031,cDifCC,.F.)				//Cartao Credito
FNR220Conv(STR0035,cDifNC,.F.)             //NCC:
FNR220Conv(STR0032,cDifCD,.F.)				//Cartao Debito

//������������������
//�Imprime o Rodape�
//������������������
Li++
Li++
@ Li++ ,ColA PSAY Replicate('-',40)
@ Li++ ,ColA PSAY Replicate('#',16) + STR0033 + Replicate('#',17) //Final

//��������������������������������������������������������Ŀ
//�Exibe o relatorio em tela caso a impressao seja em disco�
//����������������������������������������������������������
If aReturn[5] = 1
   	Set Device to Screen
   	Set Printer To 
   	dbCommitAll()
   	OurSpool(wnrel)
Endif

Return 

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FNR220Ecf �Autor  �Cesar A. Bianchi    � Data �  29/12/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Realiza a impressao do Mapa Resumo de Caixa a partir dos pa-���
���          �rametros informados, utilizando os equipamentos perifericos ���
���          �ECF configurados na estacao em execucao.		 	          ���
�������������������������������������������������������������������������͹��
���Observac. �Por motivos de seguranca, a cada 10 linhas impressas atraves���
���          �do equipamento ECF, automaticamente sera impressa uma linha ���
���          �com os dizeres "NAO E DOCUMENTO FISCAL" ou outra frase seme-���
���          �lhante, dependendo da marca do ECF utilizado. Esta acao eh  ���
���          �realizada automaticamente pela ECF, conforme legislacoes em ���
���          �vigor, para nao permitir a impressao de documentos nao-fisca���
���          �is atraves do ECF. Maiores informacoes consultar suporte da ���
���          �celula de automacao comercial. (GDP SIGALOJA)			      ���
�������������������������������������������������������������������������͹��
���Uso       � MP811/912 - Integracao Protheus x Classis .NET             ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function Fnr220Ecf(cUser,cLote)
Local cImprime := "" 
Local cPulaLin := Chr(13) + Chr(10)
Local cCodCxa := Posicione('FID',1,xFilial('FID')+cUser,"FID_NCAIXA")                                                 

Local cEfeDN := alltrim(Transform(FN222Calc(cCodCxa,cLote,'1',.F.) + iif(GetNewPar('MV_FINTRC',.F.),Posicione('FIB',1,xFilial('FIB')+cLote,"FIB_VLRABR"),0),"@E 999,999,999.99"))
Local cEfeCH := alltrim(Transform(FN222Calc(cCodCxa,cLote,'2',.F.),"@E 999,999,999.99"))
Local cEfeCC := alltrim(Transform(FN222Calc(cCodCxa,cLote,'4',.F.),"@E 999,999,999.99"))
Local cEfeCD := alltrim(Transform(FN222Calc(cCodCxa,cLote,'3',.F.),"@E 999,999,999.99"))
Local cEfeNc := alltrim(Transform(FN222Calc(cCodCxa,cLote,'5',.F.),"@E 999,999,999.99"))
Local cEfeTt := alltrim(Transform(FN222Calc(cCodCxa,cLote,'1',.F.) + FN222Calc(cCodCxa,cLote,'2',.F.) + FN222Calc(cCodCxa,cLote,'3',.F.) + FN222Calc(cCodCxa,cLote,'4',.F.) + FN222Calc(cCodCxa,cLote,'5',.F.) + iif(GetNewPar('MV_FINTRC',.F.),Posicione('FIB',1,xFilial('FIB')+cLote,"FIB_VLRABR"),0),"@E 999,999,999.99"))

Local cReaDN := alltrim(Transform(Posicione('FIB',1,xFilial('FIB')+cLote,"FIB_VLRDN"),"@E 999,999,999.99"))
Local cReaCH := alltrim(Transform(Posicione('FIB',1,xFilial('FIB')+cLote,"FIB_VLRCH"),"@E 999,999,999.99"))
Local cReaCC := alltrim(Transform(Posicione('FIB',1,xFilial('FIB')+cLote,"FIB_VLRCC"),"@E 999,999,999.99"))
Local cReaCD := alltrim(Transform(Posicione('FIB',1,xFilial('FIB')+cLote,"FIB_VLRCD"),"@E 999,999,999.99"))
Local cReaNC := alltrim(Transform(Posicione('FIB',1,xFilial('FIB')+cLote,"FIB_VLRNC"),"@E 999,999,999.99"))
Local cReaTt := alltrim(Transform(Posicione('FIB',1,xFilial('FIB')+cLote,"FIB_VLRDN")+Posicione('FIB',1,xFilial('FIB')+cLote,"FIB_VLRCH")+Posicione('FIB',1,xFilial('FIB')+cLote,"FIB_VLRCC")+Posicione('FIB',1,xFilial('FIB')+cLote,"FIB_VLRNC")+Posicione('FIB',1,xFilial('FIB')+cLote,"FIB_VLRCD"),"@E 999,999,999.99"))

Local cDifDN := alltrim(Transform( -1 * ( iif(GetNewPar('MV_FINTRC',.F.),Posicione('FIB',1,xFilial('FIB')+cLote,"FIB_VLRABR"),0) + (FN222Calc(cCodCxa,cLote,'1',.F.) - Posicione('FIB',1,xFilial('FIB')+cLote,"FIB_VLRDN"))) , "@E 999,999,999.99"))
Local cDifCH := alltrim(Transform( -1 * (FN222Calc(cCodCxa,cLote,'2',.F.) - Posicione('FIB',1,xFilial('FIB')+cLote,"FIB_VLRCH")) ,"@E 999,999,999.99"))
Local cDifCC := alltrim(Transform( -1 * (FN222Calc(cCodCxa,cLote,'4',.F.) - Posicione('FIB',1,xFilial('FIB')+cLote,"FIB_VLRCC")) ,"@E 999,999,999.99"))
Local cDifCD := alltrim(Transform( -1 * (FN222Calc(cCodCxa,cLote,'3',.F.) - Posicione('FIB',1,xFilial('FIB')+cLote,"FIB_VLRCD")) ,"@E 999,999,999.99"))
Local cDifNC := alltrim(Transform( -1 * (FN222Calc(cCodCxa,cLote,'5',.F.) - Posicione('FIB',1,xFilial('FIB')+cLote,"FIB_VLRNC")) ,"@E 999,999,999.99"))

Local cDtAbre := DTOC(Posicione('FIB',1,xFilial('FIB')+cLote,"FIB_DTABR"))
Local cHrAbre := Posicione('FIB',1,xFilial('FIB')+cLote,"FIB_HRABR")
Local cDtFech := DTOC(Posicione('FIB',1,xFilial('FIB')+cLote,"FIB_DTFCH"))
Local cHrFech := Posicione('FIB',1,xFilial('FIB')+cLote,"FIB_HRFCH")    

Local cTpAbre := iif(Posicione('FIB',1,xFilial('FIB')+cLote,"FIB_TPABRE") == "S","SUPERVISOR","OPERADOR") 
Local cUsAbre := Posicione('FIB',1,xFilial('FIB')+cLote,"FIB_USABRE") 
Local cTpFecha:= iif(Posicione('FIB',1,xFilial('FIB')+cLote,"FIB_TPFECH") == "S","SUPERVISOR","OPERADOR") 
Local cUsFecha:= Posicione('FIB',1,xFilial('FIB')+cLote,"FIB_USFECH") 

Local cVlrIni := alltrim(Transform(Posicione('FIB',1,xFilial('FIB')+cLote,"FIB_VLRABR") ,"@E 999,999,999.99"))
Local cTotCxa := cReaTt

//�������������������������������������Ŀ
//�Monta o Nome dos usuarios Abre. Caixa�
//���������������������������������������
cUsAbre  := substr( alltrim(cUsAbre)  + " " + alltrim(Posicione('FID',1,xFilial('FID')+cUsAbre,"FID_NOME")),1,22)
cUsFecha := substr( alltrim(cUsFecha) + " " + alltrim(Posicione('FID',1,xFilial('FID')+cUsFecha,"FID_NOME")),1,20)
cCodCxa  := alltrim(cCodCxa)

//���������������������������Ŀ
//�Imprime o Cabecalho Inicial�
//�����������������������������
cImprime := Replicate('#',40) + cPulaLin
cImprime += STR0004  + cPulaLin //MAPA RESUMO DE CAIXA"
cImprime +=  Replicate('#',40) + cPulaLin

//�������������������������Ŀ
//�Imprime os dados iniciais�
//���������������������������
cImprime += FNR220Conv(STR0005,cCodCxa,.T.)	 		//Caixa
cImprime += FNR220Conv(STR0006,cUser,.T.) 				//Usuario
cImprime += FNR220Conv(STR0007,cLote,.T.) 				//Lote
cImprime += FNR220Conv(STR0008,cDtAbre,.T.) 			//Data Abertura
cImprime += FNR220Conv(STR0009,cHrAbre,.T.) 			//Hora Abertura
cImprime += FNR220Conv(STR0010,cDtFech,.T.) 			//Data Fechamento
cImprime += FNR220Conv(STR0011,cHrFech,.T.) 			//Hora Fechamento
cImprime += FNR220Conv(STR0012,cTotCxa,.T.)			//Total em Caixa
cImprime += FNR220Conv(STR0013,cTpAbre,.T.) 			//Tipo de Abertura
cImprime += FNR220Conv(STR0014,cUsAbre,.T.) 			//Usuario Abertura
cImprime += FNR220Conv(STR0015,cTpFecha,.T.)			//Tipo de Fechamento:
cImprime += FNR220Conv(STR0016,cUsFecha,.T.)			//Usuario Fechamento:
cImprime += FNR220Conv(STR0017,cVlrIni,.T.)			//Valor Inicial:
cImprime += FNR220Conv(STR0018,dtoc(dDatabase),.T.)	//Data Impressao:
cImprime += FNR220Conv(STR0019,Time(),.T.)        		//Hora Impressao:
                              
//�������������������������������Ŀ
//�Imprime os "Valores Efetivados'�
//���������������������������������
cImprime += Replicate('_',40) + cPulaLin
cImprime += STR0020 + cPulaLin 							//VALORES EFETIVADOS EM CAIXA
cImprime += Replicate('_',40)  + cPulaLin
cImprime += FNR220Conv(STR0021,cEfeDN,.T.)           	//Total Dinheiro
cImprime += FNR220Conv(STR0022,cEfeCH,.T.)             //Total Cheques
cImprime += FNR220Conv(STR0023,cEfeCC,.T.)             //Total Cartao Credito
cImprime += FNR220Conv(STR0024,cEfeCD,.T.)             //Total Cartao Debito
cImprime += FNR220Conv(STR0034,cEfeNC,.T.)             //Total NCC
cImprime += FNR220Conv(STR0025,cEfeTt,.T.)             //Total Geral Efetivado

//��������������������������Ŀ
//�Imprime os "Valores Reais'�
//����������������������������
cImprime += Replicate('_',40) + cPulaLin
cImprime += STR0027  + cPulaLin							//VALORES REAIS EM CAIXA
cImprime += Replicate('_',40) + cPulaLin
cImprime += FNR220Conv(STR0021,cReaDN,.T.)				//Total Dinheiro
cImprime += FNR220Conv(STR0022,cReaCH,.T.)				//Total Cheques
cImprime += FNR220Conv(STR0023,cReaCC,.T.)				//Total Cartao Credito
cImprime += FNR220Conv(STR0024,cReaCD,.T.)				//Total Cartao Debito
cImprime += FNR220Conv(STR0034,cReaNC,.T.)             //Total NCC
cImprime += FNR220Conv(STR0026,cReaTt,.T.)				//Total Geral Real

//��������������������������Ŀ
//�Imprime as "Diferencas'   �
//����������������������������
cImprime += Replicate('_',40) + cPulaLin
cImprime += STR0028  + cPulaLin							//DIFERENCAS EM CAIXA
cImprime += Replicate('_',40) + cPulaLin
cImprime += FNR220Conv(STR0029,cDifDN,.T.)				//Dinheiro:
cImprime += FNR220Conv(STR0030,cDifCH,.T.)				//Cheques:
cImprime += FNR220Conv(STR0031,cDifCC,.T.)				//Cartao Credito
cImprime += FNR220Conv(STR0032,cDifCD,.T.)				//Cartao Debito
cImprime += FNR220Conv(STR0035,cDifNC,.T.)             //Total Cartao Debito

//������������������
//�Imprime o Rodape�
//������������������
cImprime += Replicate('-',40) + cPulaLin
cImprime += Replicate('#',16) + STR0033 + Replicate('#',17)  + cPulaLin //Final

//����������������������������������������������������������Ŀ
//�Impressao via funcao de Relatorio Nao-Gerencial - SIGALOJA�
//������������������������������������������������������������
IFRelGer( nHdlECF, cImprime ,1)
                                   
Return 

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FNR220Conv�Autor  �Cesar A. Bianchi    � Data �  07/01/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Realiza a conversao e impressao dos textos + dados de uma   ���
���          �linha no relatorio SetPrint. Realiza o controle de alinhamen���
���          �mento a direita.											  ���
�������������������������������������������������������������������������͹��
���Uso       � MP811/912 - Integracao Protheus x Classis .NET             ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function FNR220Conv(cItem,cValor,lRet)

Local cRet := ""

//����������������������������������������������������Ŀ
//�Parametro cValor nao pode ter mais que 15 caracteres�
//������������������������������������������������������
cValor := substr(cValor,1,15)  

if !lRet
	//������������������������������������������������������Ŀ
	//�Caso a funcao seja utilizada para o Relatorio SetPrint�
	//��������������������������������������������������������
	@ Li ,ColA PSAY cItem + Replicate(" ",25-len(cItem))
	@ Li ,ColB PSAY Replicate(" ",15-len(cValor)) + cValor
	Li++
	Return
else
	//�������������������������������������������������Ŀ
	//�Caso a funcao seja utilizada para o Relatorio ECF�
	//���������������������������������������������������
	cRet := cItem + Replicate(" ",25-len(cItem))
	cRet += Replicate(" ",15-len(cValor)) + cValor	
	cRet += Chr(13) + Chr(10)
	Return cRet
endif

Return
