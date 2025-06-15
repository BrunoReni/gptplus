#INCLUDE "FDRC106.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � RCGRV               �Autor-Marcelo Vieira � Data �17/02/04 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Modulo de Recebimento                                      ���
���          � RCGrvRec  -> Grava os recebimentos                         ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SFA PRONTA ENTREGA 7.0                                     ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Analista    � Data   �Motivo da Alteracao                              ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function RCGrvRec(aGets)
Local nChqs:=0    
Local cFilial :="  "
Local cNumero :=HE1->E1_NUM
Local cPrefixo:="NF"
Local cParcela:=HE1->E1_PARCELA
Local cTipo   :=HE1->E1_TIPO
Local cClifor := HA1->A1_COD 

//nChqs:=Len(aCheqsBx)
//alert( nChqs )
Alert( STR0001)                 //"Confirmando baixa do Titulo"

// Chamar a funcao de gravar os cheques 

// Abre o arquivo da baixa para gravar o movimento bancario                                  
dbSelectArea("HE5")
dbSetOrder(1)
//chave Filial+Prefixo+numero+parcela+tipo+clifor  
if HE5->( !dbSeek(cFilial+cPrefixo+cParcela+cTipo+cClifor)  )
   HE5->( dbAppend() )
  
   HE5->E5_FILIAL  := ""
   HE5->E5_DATA    := Date() 
   HE5->E5_TIPO    := "NF"
   HE5->E5_NATUREZ := "000001"                
 //HE5->E5_MOTBX   := aGets[8,1]   
   HE5->E5_BANCO   := aGets[9,1]  
   HE5->E5_AGENCIA := aGets[10,1]
   HE5->E5_CONTA   := aGets[11,1]
   HE5->E5_NUCHEQ  := ""
   HE5->E5_VENCTO  := "" 
   HE5->E5_RECPAG  := "R"
   HE5->E5_BENEF   := ""
   HE5->E5_HISTOR  := STR0002 //"Valor recebido s/ Titulo"
   HE5->E5_TIPODOC := "VL"
   HE5->E5_LA      := "S"
   HE5->E5_PREFIXO := "NF"
   HE5->E5_NUMERO  := HE1->E1_NUM
   HE5->E5_PARCELA := HE1->E1_PARCELA 
   HE5->E5_CLIFOR  := HA1->A1_COD
   HE5->E5_LOJA    := HA1->A1_LOJA 
   HE5->E5_DTDIGT  := DATE()
   HE5->E5_SEQ     := "01"
   HE5->E5_DTDISP  := DATE()
   HE5->E5_DESCO   := aGets[15,1] 
   HE5->E5_VLMULTA := aGets[16,1] 
   HE5->E5_VLJUROS := aGets[17,1] 
   HE5->E5_VALOR   := aGets[18,1] 
   HE5->E5_STATUS  := "N"
   
   HE5->( dbCommit() )  
endif
   
Return
