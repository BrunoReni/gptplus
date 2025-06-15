#INCLUDE "SFCL102.ch"
/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � DesceCli()          �Autor: Paulo Amaral  � Data �         ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Funcao que controle o LIst de CLientes 					  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� aCliente, nCliente - Array e Posicao do Cliente selecionado���
��� 		 � nCargMax - Numero maximo de clientes por pagina			  ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
*/
Function DesceCli(aCliente, nCliente, oBrw, nTop,nCargMax,nCampo)

Local nRec := HA1->(Recno())
nCliente:=1

HA1->(dbGoTo(nTop))
HA1->(dbSkip(nCargMax))
If !Eof()
   nTop := HA1->(Recno())
   ListaCli(@nTop, aCliente, nCliente, oBrw,nCargMax,nCampo)
Else
   HA1->(dbGoTo(nRec))
EndIf

Return nil

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � ListaCli()          �Autor: Paulo Amaral  � Data �         ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Funcao que atualiza o LIst de CLientes 					  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� aCliente, nCliente - Array e Posicao do Cliente selecionado���
��� 		 � nCargMax - Numero maximo de clientes por pagina			  ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
*/
Function ListaCli(nTop, aCliente, nCliente, oBrw,nCargMax,nCampo)

Local i := 0

dbSelectArea("HA1")
dbSetOrder(nCampo)

if Len(aCliente) > 0 
   dbGoTo(nTop)
else
   dbGoTop()
endif                       

aSize(aCliente,0)
For i := 1 to nCargMax
    aAdd(aCliente, {HA1->A1_COD,HA1->A1_LOJA,AllTrim(HA1->A1_NOME),HA1->A1_CGC})
	dbSkip()
	If Eof()
	   break
	EndIf
Next

If (oBrw != nil)
	SetArray(oBrw, aCliente)
EndIf

Return nil

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � CrgProxCli()        �Autor: Paulo Amaral  � Data �         ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Busca o proximo codigo para inclusao de Cliente			  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� cCodCli - Codigo do Cliente                                ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
*/
Function CrgProxCli(cCodCli)
Local nCodCli		:=0
Local lEncontrou	:= .F.

dbSelectArea("HA3")
dbGoTop()

if Val(HA3->A3_PROXCLI) > Val(HA3->A3_CLIFIM)
	MsgAlert(STR0001) //"A Faixa de C�digo Cliente excedeu. Solicite a Retaguarda para encaminhar uma nova Faixa de C�digo de Cliente"
	Return .F.
Endif

cCodCli	:=	AllTrim(HA3->A3_PROXCLI)

// -------------------------------------------------------------------------
// --> Faca ateh encontrar um Codigo Valido (Codigo nao existente na Tabeba) 
//     ou ter excedido a Faixa de Codigos.
// -------------------------------------------------------------------------
While lEncontrou == .F.
	dbSelectArea("HA1")
	dbSetOrder(1)
	dbSeek(cCodCli)      
	if Found()
		nCodCli := Val(cCodCli)+1
		cCodCli	:= StrZero(nCodCli,6)	
		//Estorou a Faixa, sai da Funcao, sem permissao de Cadastrar o Cliente
		if nCodCli > Val(HA3->A3_CLIFIM)
			MsgAlert(STR0001) //"A Faixa de C�digo Cliente excedeu. Solicite a Retaguarda para encaminhar uma nova Faixa de C�digo de Cliente"
			Return .F.
		Endif
	Else
		lEncontrou :=.T.
	Endif
Enddo

Return .T.

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � AtuaProxCli()       �Autor: Paulo Amaral  � Data �         ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Atualiza o proximo codigo para inclusao de Cliente		  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� cCodCli - Codigo do Cliente                                ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
*/
Function AtuaProxCli(cCodCli)
//Atualiza o Prox. Cliente no HA3
Local nCodCli:=0
dbSelectArea("HA3")
dbGoTop()
nCodCli:=Val(cCodCli) + 1
cCodCli:=StrZero(nCodCli,6)
HA3->A3_PROXCLI :=cCodCli
dbCommit()

Return Nil

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � GrvCliente()        �Autor: Paulo Amaral  � Data �         ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Grava dados do CLiente 									  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� nOpCli - Operacao (1 - Inclusao, 2 Alteracao)			  ���
���			 � cCodCli - Codigo do Cliente, cLojaCLi - Loja do CLiente    ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
*/
Function GrvCliente(nOpCli,cCodCli,cLojaCli,cTipo,cRazao,cFantasia,cEndereco,cBairro,cCep,cCidade,cUF,cTel,cCGC,cIE,cEmail,nTop,aCliente,nCliente,oBrw,nCargMax,nCampo)
Local nLc :=0.00
Local cRisco := "B"

If !VrfCliente(cCodCli,cLojaCli,cTipo,cRazao,cFantasia,cEndereco,cBairro,cCep,cCidade,cUF,cTel,cCGC,cIE,cEmail)
	Return Nil
Endif

if nOpCli ==1 
	dbSelectArea("HCF")
  	dbSetOrder(1)
	If dbSeek("MV_SFAPLC")
		If !Empty(HCF->CF_VALOR)
			nLc		:=Val(HCF->CF_VALOR)
		else
			nLc		:=0.00  
		Endif
	else
		nLc		:=0.00
	Endif
	
	dbSelectArea("HCF")
  	dbSetOrder(1)
	If dbSeek("MV_SFAPRIS")
		If !Empty(HCF->CF_VALOR)
			cRisco := HCF->CF_VALOR
		EndIf
	Endif	
	
Endif
dbSelectArea("HA1")
dbSetOrder(1)

If nOpCli == 1
	dbAppend()
	HA1->A1_COD		:=	cCodCli 		
	HA1->A1_LOJA	:=	cLojaCli 		
	HA1->A1_LC		:= 	nLc
	HA1->A1_RISCO	:=	cRisco
	HA1->A1_STATUS	:=	"N"
Else
	dbSeek(cCodCli + Space(6 - Len(cCodCli)) + cLojaCli)
	If HA1->A1_STATUS <>"N"
		HA1->A1_STATUS	:="A"
	Endif
Endif
HA1->A1_TIPO	:=  cTipo
HA1->A1_NOME	:=	cRazao 		
HA1->A1_NREDUZ	:=	cFantasia 	
HA1->A1_END		:=	cEndereco 	
HA1->A1_BAIRRO	:=	cBairro		
HA1->A1_CEP		:= 	cCep 		
HA1->A1_MUN		:=	cCidade 	
HA1->A1_EST		:=	cUF 		
HA1->A1_TEL		:=	cTel 		
HA1->A1_CGC		:=	cCGC 		
HA1->A1_INSCR	:=	cIE 		
HA1->A1_EMAIL 	:=	cEmail		
dbCommit()

//Ponto de Entrada: Complementa a gravacao do cliente
#IFDEF PECL0002                
	//Objetivo: 
	//Retorno: 
	uRet := PECL0002()
#ENDIF

MsgAlert(STR0002 + cCodCli + STR0003) //"Cliente "###" gravado com sucesso"
CloseDialog()

//Atualiza o ListBox do Cliente
if nOpCli == 1
	dbSelectArea("HA1")
	dbSetOrder(2)
	dbGoTop()
	nTop := HA1->(Recno())    
	
	AtuaProxCli(cCodCli)
Endif

ListaCli(@nTop, aCliente, nCliente, oBrw,nCargMax,nCampo)

Return Nil
