#INCLUDE "SFVN103.ch"
/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � ACCrgOco            �Autor - Paulo Lima   � Data �         ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Carrega array das ocorrencias				 			  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� aOco: Array das ocorrencias								  ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Analista    � Data   �Motivo da Alteracao                              ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
*/
Function ACCrgOco(aOco)
dbSelectArea("HX5")
dbSetOrder(1)
dbSeek("OC")            

While !eof() .and. HX5->X5_TABELA = "OC"
	AADD(aOco,Alltrim(HX5->X5_CHAVE) + "-" + AllTrim(HX5->X5_DESCRI))
	dbSkip()
Enddo
AADD(aOco,"")

Return Nil

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � ACEscOco            �Autor - Paulo Lima   � Data �         ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Atualiza text com ocorrencia escolhida		 			  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� aOco, nOco: Array e posicao da ocorrencias				  ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Analista    � Data   �Motivo da Alteracao                              ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
*/
Function ACEscOco(cOco, oTxtOco, aOco, nOco)
cOco:= Substr(aOco[nOco],1,at("-",aOco[nOco])-1)
SetText(oTxtOco, cOco)
Return Nil

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � ACPsqOco            �Autor - Paulo Lima   � Data �         ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Pesquisa ocorrencia escolhida		 			          ���
�������������������������������������������������������������������������Ĵ��
���Parametros� aOco, nOco: Array e posicao da ocorrencias				  ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Analista    � Data   �Motivo da Alteracao                              ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
*/
Function ACPsqOco(cOco, aOco, cCodRot)
Local nContador :=0

if !Empty(cCodRot)
	cOco:=HD7->AD7_OCO
Else
	cOco:=HA1->A1_OCO
Endif

For nContador:=1 To len(aOco)
	If cOco = Substr(aOco[nContador],1,at("-",aOco[nContador])-1) 
		break
	Endif
Next
if nContador > Len(aOco)
	nContador :=1
EndIf
Return nContador

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � ACGrvOco            �Autor - Paulo Lima   � Data �         ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Grava a ocorrencia					 			          ���
�������������������������������������������������������������������������Ĵ��
���Parametros� aOco, nOco: Array e posicao da ocorrencias				  ���
���          � cCodCli: Codigo do Cliente, cLojaCli: Loja do Cliente	  ���
���          � aClientes, nCliente: Array e posicao da Cliente			  ���
���			 � nQtdePed: numero de pedidos existentes					  ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Analista    � Data   �Motivo da Alteracao                              ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
*/
Function ACGrvOco(cCodPer, cCodRot,cIteRot,cCodCli,cLojaCli,cOco,oTxtOco,aOco,nQtdePed,aClientes,nCliente)
Local cSeek:="", cAlias :="", cOcoCad:="", cResp:=""
Local dData := Date()
//Se houver Pedido Cadastrado
If nQtdePed > 0 
	MsgStop(STR0001,STR0002) //"Existe(m) Pedido(s) gravado para esse cliente, portanto n�o ser� poss�vel gravar essa Ocorr�ncia"###"Ocorr�ncias"
	Return Nil
Endif

If !ACVrfOco(cOco,aOco)
	Return Nil
EndIf

If !Empty(cCodRot)
	cAlias		:="HD7"
	cOcoCad		:=HD7->AD7_OCO
	cSeek		:= cCodPer + cCodRot + cIteRot
Else
	cAlias		:="HA1"
	cOcoCad		:=HA1->A1_OCO
	cSeek		:= cCodCli + cLojaCli
Endif

dbSelectArea(cAlias)
dbSetOrder(1)
If !dbSeek(cSeek)
	MsgStop(STR0003 + cSeek + STR0004 + cAlias,STR0002) //"Erro: "###" n�o encontrada no "###"Ocorr�ncias"
	Return Nil
Endif	
// <--------------------------------------------------------------------------------->
//  							Se for Alteracao de Ocorrencia
// <--------------------------------------------------------------------------------->
If !Empty(cOcoCad)
	If Empty(cOco)
		//cResp:=if(,"Sim","N�o")
		If MsgYesOrNo(STR0005,STR0006) //"Voc� deseja Excluir a Ocorr�ncia?"###"Cancelar"
			ACGrvTabOco(cCodPer,cCodRot,cIteRot,"0",cOco,)
			GrvAtend(4, , cOco, HA1->A1_COD, HA1->A1_LOJA,)
			aClientes[nCliente,1]:="NVIS"
			// Exclui a ocorrencia
			dbSelectArea("HD5")
			dbSetOrder(1)
			If dbSeek(HA1->A1_COD + HA1->A1_LOJA + DtoS(dData))
				dbDelete()
			EndIf
		Else
			Return Nil
		endif  			
	Else
		ACGrvTabOco(cCodPer,cCodRot,cIteRot,"2",cOco,)
		GrvAtend(3,, cOco, HA1->A1_COD, HA1->A1_LOJA,)
		aClientes[nCliente,1]:="NPOS"
	Endif
// <--------------------------------------------------------------------------------->
//  							Se for Inclusao de Ocorrencia
// <--------------------------------------------------------------------------------->
Else
	If Empty(cOco)
		If MsgYesOrNo(STR0005,STR0006) //"Voc� deseja Excluir a Ocorr�ncia?"###"Cancelar"
			ACGrvTabOco(cCodPer,cCodRot,cIteRot,"0",cOco,)
			GrvAtend(4, , cOco, HA1->A1_COD, HA1->A1_LOJA,)
			aClientes[nCliente,1]:="NVIS"
		Else
			Return Nil
		EndIf  			
	Else
		ACGrvTabOco(cCodPer,cCodRot,cIteRot,"2",cOco,)
		GrvAtend(3, , cOco, HA1->A1_COD, HA1->A1_LOJA,)
		aClientes[nCliente,1]:="NPOS" 
	Endif
Endif
Return Nil

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � ACGrvTabOco         �Autor - Paulo Lima   � Data �         ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Atualiza status do cliente na tabela roteiro				  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� cCodRot: Codigo do Roteiro 								  ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Analista    � Data   �Motivo da Alteracao                              ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
*/
Function ACGrvTabOco(cCodPer,cCodRot, cIteRot, cNpos, cOco, lMsg)
Local dData := Date()
Local lUpdRot := .T.
// Tratamento da Mensagem quando nao for necessario que ela nao apareca
If lMsg = Nil
	lMsg := .T.
EndIf

If Empty(cCodRot)
	dbSelectArea("HD7")
	dbSetOrder(3)
	If !dbSeek(DtoS(dData)+HA1->A1_COD + HA1->A1_LOJA )
		lUpdRot := .F.
	EndIf
Else
	dbSelectArea("HD7")
	dbSetOrder(1)
	If !dbSeek(cCodPer+cCodRot+cIteRot)
		lUpdRot := .F.
	EndIf
Endif					

// Atualiza Ocorrencia do Roteiro
If lUpdRot
	HD7->AD7_FLGVIS	:=cNpos
	HD7->AD7_OCO    :=cOco
	dbCommit()
EndIf

// Atualiza Ocorrencia no Cliente
HA1->A1_FLGVIS	:=cNpos
HA1->A1_OCO		:=cOco		 		

// Preenche o array com os campos do arquivo de Nao Positivacao
dbSelectArea("HD5")
dbSetOrder(1)
If !dbSeek(HA1->A1_COD + HA1->A1_LOJA + DtoS(dData))
	dbAppend()
EndIf
HD5->AD5_ROTER := cCodRot
HD5->AD5_CODNPO := cOco
HD5->AD5_DTHR := DtoS(dData) + Time()
HD5->AD5_CODCLI := HA1->A1_COD
HD5->AD5_LOJA :=  HA1->A1_LOJA
dbCommit()

If lMsg
	MsgAlert(STR0007) //"Ocorrencia Gravada com sucesso!"
EndIf

Return Nil

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � ACVrfOco            �Autor - Paulo Lima   � Data �         ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � validacao Ocorrencia				  					      ���
�������������������������������������������������������������������������Ĵ��
���Parametros� aOco, nOco: Array e posicao da ocorrencias				  ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Analista    � Data   �Motivo da Alteracao                              ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
*/
Function ACVrfOco(cOco,aOco)     
Local nI:=0

For nI:=1 to Len(aOco)
	If cOco = Substr(aOco[nI],1,at("-",aOco[nI])-1)
		Return .T.
	Endif
Next

MsgStop(STR0008,STR0009) //"Escolha uma ocorr�ncia v�lida!"###"Verifica Ocorr�ncia"

Return .F.  
