/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � OMSR011  � Autor � Glauce Casemiro       � Data � 12.04.00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Relatorio para Posicao de Estoque Dia-a-Dia por produto     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Antarctica                                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
FUNCTION OMSR011()
Local cString  := "SB1"
Local wnrel    := "OMSR011"
Local cDesc1   := "Este programa ira emitir o Relatorio da Posicao de Estoque Diariamente."
Local cDesc2   := ""
Local cDesc3   := ""
Private tamanho := "G"
Private titulo  := "RELATORIO DE POSICAO DE ESTOQUE DIARIA "
Private aReturn := { "Zebrado", 1, "Administracao", 1, 2, 1, "", 1 }
Private nomeprog:= "OMSR011"
Private nLastKey:= 0
Private cPerg   := "DSR011"
//�����������������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                                  �
//� mv_par01   		// Produto Inicial                		              �
//� mv_par02        // Produto Final                       	              �
//� mv_par03        // Data Inicial                         	           �
//� mv_par04        // Data Final                               	        �
//�������������������������������������������������������������������������    

//��������������������������������������������������������������Ŀ
//� Verifica as Perguntas selecionadas.                          �
//����������������������������������������������������������������
Pergunte(cPerg,.F.)
//��������������������������������������������������������������Ŀ
//� Envia controle p/ a Funcao SetPrint.                         �
//����������������������������������������������������������������
SetPrint(cString,wnrel,cPerg,titulo,cDesc1,cDesc2,cDesc3,.F.,,,Tamanho)

If nLastKey == 27
	Set Filter To
	Return Nil
EndIf

SetDefault(aReturn, cString)

If nLastKey == 27
	Set Filter To
	Return Nil
EndIf
//������������������������������������������������Ŀ
//� Impressao do Relatorio                         �
//��������������������������������������������������
RptStatus( { |lEnd| R011imp(@lEnd,wnRel)})

MS_FLUSH()

Return Nil
/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � R011Imp  � Autor � Glauce Casemiro       � Data � 12/04/2000 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Impressao do Relatorio                                       ���
���          �                                                              ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � R011Imp                                                      ���
���������������������������������������������������������������������������Ĵ��
��� Atualizacoes sofridas desde a Construcao Inicial.                       ���
���������������������������������������������������������������������������Ĵ��
��� Programador  � Data   � BOPS �  Motivo da Alteracao                     ���
���������������������������������������������������������������������������Ĵ��
���              �        �      �                                          ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
/*/
Function R011Imp(lEnd,wnRel)
Local oTempTable	:= Nil
Local c 			:= 0
Local n 			:= 0
Private cbCont		:= 00
Private Cbtxt		:= Space( 10 )
Private Limite		:= 220
Private Li			:= 80
Private m_pag  		:= 01
//��������������������������������������������������������������Ŀ
//� Cria array para gerar arquivo de trabalho                    �
//����������������������������������������������������������������
aCpoTRB := {}
aTam := TamSX3("B1_COD")
Aadd( aCpoTRB, {"TR_CODPROD", "C", aTam[1], aTam[2] } )
aTam := TamSX3("B1_DESC")
Aadd( aCpoTRB, {"TR_DESPROD" , "C", aTam[1], aTam[2] } )
Aadd( aCpoTRB, {"TR_DTMOVTO", "D", 08, 0 } )
Aadd( aCpoTRB, {"TR_VLSALDO", "N", 14, 2 } )

oTempTable := FWTemporaryTable():New( "TRB" )
oTempTable:SetFields( aCpoTRB )
oTempTable:AddIndex("indice1", {"TR_CODPROD","TR_DTMOVTO"} )
oTempTable:Create()

dbSelectArea("SB1")
dbSetOrder(1)
SetRegua(recCount())
dbSeek(xFilial()+mv_par01,.T.)

aSaldo := {}
nTotSaldo := 0

While !Eof() .and. SB1->B1_FILIAL == xFilial() .AND. SB1->B1_COD <= mv_par02
	If	lEnd
		Exit
	EndIf
	IncRegua()
	dDtInicio := mv_par03
	While dDtInicio <= mv_par04  //Calcula Saldo para todas as Datas do Periodo.
		
		dbSelectArea("SB2")
		dbSetOrder(1)
		dbSeek(xFilial("SB2")+ SB1->B1_COD)
		
		nTotSaldo := 0
		While !Eof() .and. SB2->B2_COD == SB1->B1_COD //Verif. todos os Locais.
			aSaldo := CalcEst(SB1->B1_COD,SB2->B2_LOCAL,dDtInicio+1)
			nTotSaldo := nTotSaldo + aSaldo[1]
			dbSkip()
		Enddo
		
		dbSelectArea("TRB")
		RecLock("TRB",.T.)
		Replace TR_CODPROD With SB1->B1_COD
		Replace TR_DESPROD With SB1->B1_DESC
		Replace TR_DTMOVTO With dDtInicio
		Replace TR_VLSALDO With nTotSaldo
		MsUnLock()
		
		dDtInicio := dDtInicio + 1
	Enddo
	
	dbSelectArea("SB1")
	dbSkip()
Enddo

//��������������������������������������������������������������Ŀ
//� Impressao do Relatorio baseada no TRB.                       �
//����������������������������������������������������������������

//                  1         2         3         4         5         6         7         8         9        10        11        12        13
//        0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
Cabec1:= "Codigo         Produto                          "
//        XXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
Cabec2:=""

dbSelectArea("TRB")
dbSetOrder(1)
SetRegua(recCount())

nDias := mv_par04 - mv_par03
nPgs := Round((nDias/9)+ 0.40,0)
For n:=0 to nPgs - 1
	dDataInic := mv_par03 + (n*9)
	Cabec1:= "Codigo          Produto                          "
	For c:=0 to 9                  //Atualizando Cabecalho.
		dDataCol := dDataInic + c
		If dDataCol <= mv_par04
			Cabec1 := Cabec1 + "   Saldo " + dtoc(dDataCol)
		Endif
	Next
	
	If li > 60
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho)
	Endif
	
	dbGotop()
	While !Eof()
		If lEnd
	      @PROW()+1,001 PSay "CANCELADO PELO OPERADOR"
			Exit
		EndIf
		IncRegua()
		cCodProd := TRB->TR_CODPROD
		dbSeek(cCodProd + dtos(dDataInic))
		@ li,000 PSAY cCodProd
		@ li,016 PSAY TRB->TR_DESPROD
		nCol := 49
		
		Do While !Eof() .and. TRB->TR_CODPROD == cCodProd .and. TRB->TR_DTMOVTO <= mv_par04;
			.and. ncol <= 204
			
			If li > 60
				Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho)
			Endif
			
			@ li,nCol PSAY TRB->TR_VLSALDO Picture "@E 99,999,999,999.99"
			nCol := nCol + 17
			
			dbSelectarea("TRB")
			dbSkip()
		Enddo
		dbSeek(cCodProd + dtos(mv_par04+1),.T.)
		li := li + 1
	Enddo
	LI := 61
Next

///
IF LI <> 80
	RODA(CBCONT,CBTXT,Tamanho)
Endif

//��������������������������������������������������������������Ŀ
//� Deleta Arquivo Temporario e Restaura os Indices Nativos.     �
//����������������������������������������������������������������
oTempTable:Delete()

//��������������������������������������������������������������Ŀ
//� Carrega Spool de Impressao.                                  �
//����������������������������������������������������������������
Set Device To Screen

If aReturn[5] == 1
	Set Printer To
	dbCommitAll()
	OurSpool(wnrel)
EndIf

Return Nil

