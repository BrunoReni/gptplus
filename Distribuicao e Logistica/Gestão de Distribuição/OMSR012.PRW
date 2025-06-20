#Include "Protheus.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � DFATR27  � Autor � MArcos Eduardo Rocha  � Data � 14/09/99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Mapa das Movimentacoes                                     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Especif. Antarctica (Desenvolvido a Partir do MATR330.PRX) ���
�������������������������������������������������������������������������Ĵ��
��� Obs.     � - Alterada Linha de Saldo Inicial e Final para Coluna      ���
���          � - Retirada Colunas REQUISICOES P/PRODUCAO E P/PROCESSO     ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���Rodrigo Sart�02/02/98�10810A� Inclusao da UM na impressao do relatorio ���
���Rodrigo Sart�13/07/99�22412A� Acerto Pictures conf. MATR910/MATR460    ���
���Fernando J. �04/08/99�23014A�Utilizar o Nr de Casas Decimais do B2_CM1 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function DISR012()
//��������������������������������������������������������������Ŀ
//� Variaveis tipo Local padrao de todos os relatorios           �
//����������������������������������������������������������������
Local Tamanho  := "G"
Local titulo   := "Mapa das Movimentacoes"
Local cDesc1   := "Este programa ira emitir um resumo da relacao de"
Local cDesc2   := "quantidades do estoque. Sera emitido em forma de"
Local cDesc3   := "colunas, com Filial,Local,Codigo e Quantidade."
Local cString  := "SB1"
Local aOrd     := { " Tipo ", " Grupo " }
Local wnrel    := "DISR012"
Local i := 0
Local j := 0

//��������������������������������������������������������������Ŀ
//� Variaveis tipo Private padrao de todos os relatorios         �
//����������������������������������������������������������������
Private aReturn  := {"Zebrado", 1, "Administracao", 1, 2, 1, "",1 }
Private nLastKey := 0 ,cPerg := "DSR012"
Private nDecVal  := 2

//��������������������������������������������������������������Ŀ
//� Verifica as perguntas selecionadas                           �
//����������������������������������������������������������������
//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                         �
//� mv_par01     // Almox. de                                    �
//� mv_par02     // Almox. ate                                   �
//� mv_par03     // Produto de                                   �
//� mv_par04     // Produto ate                                  �
//� mv_par05     // tipo de                                      �
//� mv_par06     // tipo ate                                     �
//� mv_par07     // grupo de                                     �
//� mv_par08     // grupo ate                                    �
//� mv_par09     // data inical                                  �
//� mv_par10     // data final                                   �
//� mv_par11     // moeda selecionada ( 1 a 5 )                  �
//� mv_par12     // Saldo a considerar : Atual / Fechamento      �
//� mv_par13     // Almox. a Desconsid.                          �
//����������������������������������������������������������������
pergunte(cPerg,.F.)

//��������������������������������������������������������������Ŀ
//� Envia controle para a funcao SETPRINT                        �
//����������������������������������������������������������������
wnrel:=SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,Tamanho)

If nLastKey = 27
	Set Filter to
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey = 27
	Set Filter to
	Return
Endif

RptStatus({|lEnd| R012ImpA(@lEnd,wnRel,cString,tamanho,titulo)},titulo)

Return NIL

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � C330IMP  � Autor � Rodrigo de A. Sartorio� Data � 12.12.95 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Chamada do Relatorio                                       ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATR330			                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function R012ImpA(lEnd,WnRel,cString,tamanho,titulo)

//��������������������������������������������������������������Ŀ
//� Variaveis especificas deste relatorio                        �
//����������������������������������������������������������������
Local lPassou := .F. ,lTeveItem := .F. ,cTipant ,cFiliant ,nCusto
Local nTvIniAlm := nTvCompra := nTvDevVen := nTvRetTrc := nTvDE4 := nTvRE4 := nTvSaiBON := nTvSaiTrc := nTvComoda := nTvSaiOut := nTvVendas := nTvFimAlm	:= 0
Local nGvIniAlm := nGvCompra := nGvDevVen := nGvRetTrc := nGvDE4 := nGvRE4 := nGvSaiBON := nGvSaiTrc := nGvComoda := nGvSaiOut := nGvVendas := nGvFimAlm := 0
Local nAqIniAlm := nAqCompra := nAqDevVen := nAqRetTrc := nAqDE4 := nAqRE4 := nAqSaiBON := nAqSaiTrc := nAqComoda := nAqSaiOut := nAqVendas := nAqFimAlm	:= 0
Local nAvIniAlm := nAvCompra := nAvDevVen := nAvRetTrc := nAvDE4 := nAvRE4 := nAvReqSOP := nAvSaiBON := nAvSaiTrc := nAvComoda := nAvSaiOut := nAvVendas := nAvFimAlm := 0
Local bBloco := {|nV,nX| Trim(nV)+Str(nX,1) }
Local cCodAux := "", cLocalAux := "  "

//��������������������������������������������������������������Ŀ
//� Variaveis para determinar as pictures usadas na impressao    �
//����������������������������������������������������������������
Local cPictSD114 := PesqPict("SD1","D1_CUSTO"+If(mv_par11>1,Strzero(mv_par11,1,0),""),14)
Local cPictSD314 := PesqPict("SD3","D3_CUSTO"+Strzero(mv_par11,1,0),14)
Local cPictSD214 := PesqPict("SD2","D2_CUSTO"+Strzero(mv_par11,1,0),14)
Local nVUnit    := 0

//��������������������������������������������������������������Ŀ
//� Variaveis para determinar condicoes,padrao deste relatorio   �
//����������������������������������������������������������������
Private cCondWhile ,cCondIf ,cAnt ,cVar

//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para Impressao do Cabecalho e Rodape    �
//����������������������������������������������������������������
cbtxt  := Space(10)
cbcont := 0
li     := 80
m_pag  := 1
nTipo  := IIf(aReturn[4]==1,15,18)

//��������������������������������������������������������������Ŀ
//� Monta os Cabecalhos                                          �
//����������������������������������������������������������������
dbSelectArea("SB1")

aTam := TamSX3("B2_CM1")
nDecVal := aTam[2]

If aReturn[8] == 1
   dbSetOrder(2)
   dbSeek(cFilial+mv_par05,.T.)
	cCondWhile := "!EOF() .And. B1_TIPO <= mv_par06"
	cCondIf    := "B1_COD < mv_par03 .Or. B1_COD > mv_par04 .Or. B1_GRUPO < mv_par07 .Or. B1_GRUPO > mv_par08"
   Cabec1     := "TIPO PRODUTO          UM                      SALDO        COMPRAS     DEVOLUCOES        RETORNO     DEVOLUCAO/         VENDAS          SAIDA          SAIDA           SAIDA          SAIDA    REQUISICAO/          SALDO"
//                XXXX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  12345678901234 12345678901234 12345678901234 12345678901234 12345678901234 12345678901234 12345678901234 12345678901234  12345678901234 12345678901234 12345678901234 12345678901234
//                01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//                0        10        20        30        40        50        60        70        80        90       100       110       120       130       140       150       160       170       180       190       200       210       220 

Else
   dbSetOrder(4)
   dbSeek(cFilial+mv_par07,.T.)
	cCondWhile := "!EOF() .And. B1_GRUPO <= mv_par08"
   cCondIf    := "B1_COD < mv_par03 .Or. B1_COD > mv_par04 .Or. B1_TIPO < mv_par05 .Or. B1_TIPO > mv_par06" 
   Cabec1     := "GRUP PRODUTO          UM                      SALDO        COMPRAS     DEVOLUCOES        RETORNO     DEVOLUCAO/         VENDAS          SAIDA          SAIDA           SAIDA          SAIDA    REQUISICAO/          SALDO"

EndIf
Cabec2        := "                                            INICIAL                      DE VENDA       DE TROCA  TRANSFERENCIA                   BONIFICACAO         TROCAS        COMODATO         OUTRAS  TRANSFERENCIA          FINAL"

SetRegua(LastRec())

nGvIniAlm := nGvCompra := nGvDevVenStore := 0
nGvSaiBON := nGvSaiTrc := nGvDE4         := nGvRE4    := nGvRetTrcStore := 0
nGvComoda := nGvSaiOut := nGvVendas      := nGvFimAlm := 0

While &cCondWhile .and. B1_FILIAL == cFilial

	IF lEnd
      @PROW()+1,001 PSay "CANCELADO PELO OPERADOR"
		EXIT
	ENDIF
     
	If aReturn[8] == 1
		cAnt := "B1_TIPO"
		cVar := B1_TIPO
	Else
		cAnt := "B1_GRUPO"
		cVar := B1_GRUPO
	EndIf
     
   nTvIniAlm := nTvCompra := nTvDevVen := 0
   nTvSaiBON := nTvSaiTrc := nTvRE4    := nTvDE4    := 0
   nTvComoda := nTvSaiOut := nTvVendas := nTvFimAlm := 0
     
	While !EOF() .And. B1_FILIAL == cFilial .And. &(cAnt) == cVar
          
      nAqIniAlm := nAqCompra := nAqDevVen := nAqRetTrc := 0
      nAqSaiBON := nAqSaiTrc := nAqDE4    := nAqRE4    := nTvRetTrc := 0
      nAqComoda := nAqSaiOut := nAqVendas := nAqFimAlm := 0

      nAvIniAlm := nAvCompra := nAvDevVen := 0
      nAvSaiBON := nAvSaiTrc := nAvDE4    := nAvRE4    := nAvRetTrc := 0
      nAvComoda := nAvSaiOut := nAvVendas := nAvFimAlm := 0
		
		IF lEnd
         @PROW()+1,001 PSay "CANCELADO PELO OPERADOR"
			EXIT
		ENDIF

		IncRegua()
          
		IF &(cCondIf)
         dbSkip()
			Loop
		EndIF

		//��������������������������������������������������������������Ŀ
		//� Pega o saldo final e inicial dos almoxarifados               �
		//����������������������������������������������������������������
      dbSelectArea("SB2")
      dbSeek(cFilial+SB1->B1_COD)
		While !EOF() .And. B2_FILIAL == cFilial .And. B2_COD == SB1->B1_COD

			If B2_LOCAL < mv_par01 .Or. B2_LOCAL > mv_par02 .Or. B2_LOCAL == "99"
            dbSkip()
				Loop
			EndIf

			//��������������������������������������������������������������Ŀ
         //� Filtro por Locais a desconsiderar.                           �
			//����������������������������������������������������������������
         If B2_LOCAL $ AllTrim(mv_par13)
            dbSkip()
				Loop
			EndIf

			//��������������������������������������������������������������Ŀ
			//� Totaliza o saldo final ou atual de cada almoxarifado         �
			//����������������������������������������������������������������
			If	mv_par12 == 1
				nAqFimAlm +=B2_QATU
			Elseif mv_par12 == 2				
				nAqFimAlm += B2_QFIM
			Else 
				aSaldoFim	:= CalcEst(SB2->B2_COD,SB2->B2_LOCAL,mv_par10+1)
				nAqFimAlm	+= aSaldoFim[1]
			Endif
			
			nVUnit := NoRound(If(mv_par12<3,&(Eval(bBloco,Iif(mv_par12 == 1,'B2_VATU','B2_VFIM'),mv_par11)), aSaldoFim[mv_par11+1])/nAqFimAlm,nDecVal)
			nAvFimAlm += NoRound(nAqFimAlm * nVUnit, nDecVal)

			aSaldoIni := CalcEst(SB2->B2_COD,SB2->B2_LOCAL,mv_par09)
			nAqIniAlm += aSaldoIni[1]
			
			nVUnit := NoRound(aSaldoIni[mv_par11+1]/nAqIniAlm, nDecVal)
			nAvIniAlm += NoRound(nAqIniAlm * nVUnit, nDecVal)
         dbSkip()
		EndDo
		If nAqIniAlm != 0 .Or. nAvIniAlm != 0 .Or. nAqFimAlm != 0 .Or. nAvFimAlm != 0
			lPassou := .T.
		EndIf
          
		//��������������������������������������������������������������Ŀ
		//� Verifica as Entradas                                         �
		//����������������������������������������������������������������
      dbSelectArea("SD1")
      dbSetOrder(2)
      dbSeek(cFilial+SB1->B1_COD)
		While !EOF() .And. D1_FILIAL+D1_COD == cFilial+SB1->B1_COD

			//��������������������������������������������������������������Ŀ
			//� Despreza Notas Fiscais Lancadas Pelo Modulo do Livro Fiscal  �
			//����������������������������������������������������������������
			If D1_ORIGLAN $ "LF"
            dbSkip()
				Loop
			EndIf
               
			If D1_LOCAL < mv_par01 .Or. D1_LOCAL > mv_par02
            dbSkip()
				Loop
			EndIf

			If D1_DTDIGIT < mv_par09 .Or. D1_DTDIGIT > mv_par10
            dbSkip()
				Loop
			EndIF
               
         dbSelectArea("SF4")
         dbSeek(cFilial+SD1->D1_TES)

			If F4_ESTOQUE == "S"

				If mv_par11 > 1
					nCusto := &("SD1->D1_CUSTO"+Strzero(mv_par11,1,0))
				Else
					nCusto := SD1->D1_CUSTO
				EndIf

				If SD1->D1_TIPO == "D"
               If SF4->F4_TPMOV == "6"
		   			nAqRetTrc += SD1->D1_QUANT
			   		nAvRetTrc += nCusto
               Else
            		nAqDevVen += SD1->D1_QUANT
	   				nAvDevVen += nCusto
               EndIf
				Else
					nAqCompra += SD1->D1_QUANT
					nAvCompra += nCusto
				EndIf
				lPassou := .T.
			EndIf

         dbSelectArea("SD1")
         dbSkip()
		EndDo
          
		//��������������������������������������������������������������Ŀ
		//� Verifica as Movimentacoes Internas                           �
		//����������������������������������������������������������������
      dbSelectArea("SD3")
      dbSetOrder(3)
      dbSeek(cFilial+SB1->B1_COD)
		While !EOF() .And. D3_FILIAL+D3_COD == cFilial+SB1->B1_COD
               
			If (D3_LOCAL < mv_par01 .Or. D3_LOCAL > mv_par02) .And. D3_LOCAL != "99"
            dbSkip()
				Loop
			EndIf
               
			If D3_EMISSAO < mv_par09 .Or. D3_EMISSAO > mv_par10
            dbSkip()
				Loop
			EndIf

			//��������������������������������������������������������������Ŀ
         //� Aglutina Todos os Movimentos Internos                        �
			//����������������������������������������������������������������
         If SD3->D3_TM <= "500"
            nAqDE4 += D3_QUANT
            nAvDE4 += &(Eval(bBloco,"D3_CUSTO",mv_par11))
         Else
            nAqRE4 += D3_QUANT
            nAvRE4 += &(Eval(bBloco,"D3_CUSTO",mv_par11))
         EndIf
         lPassou := .T.

         dbSkip()
		EndDo

		//��������������������������������������������������������������Ŀ
		//� Verifica as Saidas                                           �
		//����������������������������������������������������������������
      dbSelectArea("SD2")
      dbSeek(cFilial+SB1->B1_COD)
		While !EOF() .And. D2_FILIAL+D2_COD == cFilial+SB1->B1_COD
               
			//��������������������������������������������������������������Ŀ
			//� Despreza Notas Fiscais Lancadas Pelo Modulo do Livro Fiscal  �
			//����������������������������������������������������������������
			If D2_ORIGLAN == "LF"
            dbSkip()
				Loop
			EndIf

			If D2_EMISSAO < mv_par09 .Or. D2_EMISSAO > mv_par10
            dbSkip()
				Loop
			EndIf

			If D2_LOCAL < mv_par01 .Or. D2_LOCAL > mv_par02
            dbSkip()
				Loop
			EndIf

         dbSelectArea("SF4")
         dbSeek(cFilial+SD2->D2_TES)

         dbSelectArea("SD2")
			If SF4->F4_ESTOQUE == "S"
				//��������������������������������������������������������������Ŀ
				//� Separa as transferencias das vendas                          �
				//����������������������������������������������������������������
				If AllTrim(D2_CF)$"521/522/592/621/622/692"
               nAqSaiOut += D2_QUANT
               nAvSaiOut += &(Eval(bBloco,"D2_CUSTO",mv_par11))
				ElseIf D2_TIPO == "D"
					nAqCompra -= D2_QUANT
					nAvCompra -= &(Eval(bBloco,"D2_CUSTO",mv_par11))
				Else
               If SF4->F4_TPMOV == "1"
                  nAqVendas += D2_QUANT
                  nAvVendas += &(Eval(bBloco,"D2_CUSTO",mv_par11))
               ElseIf SF4->F4_TPMOV == "4"
                  nAqSaiBON += D2_QUANT
                  nAvSaiBON += &(Eval(bBloco,"D2_CUSTO",mv_par11))
               ElseIf SF4->F4_TPMOV == "B"
                  nAqComoda += D2_QUANT
                  nAvComoda += &(Eval(bBloco,"D2_CUSTO",mv_par11))
               ElseIf SF4->F4_TPMOV == "6"
                  nAqSaiTrc += D2_QUANT
                  nAvSaiTrc += &(Eval(bBloco,"D2_CUSTO",mv_par11))
               Else
                  nAqSaiOut += D2_QUANT
                  nAvSaiOut += &(Eval(bBloco,"D2_CUSTO",mv_par11))
               EndIf
				EndIf
				lPassou := .T.
			EndIf

         dbSkip()

		EndDo

		//��������������������������������������������������������������Ŀ
		//� Rotina de Impressao                                          �
		//����������������������������������������������������������������
		If lPassou
         dbSelectArea("SB1")
			If Li > 55
				Cabec(titulo,cabec1,cabec2,wnrel,Tamanho,nTipo)
			Endif
			@ li,000 PSay cVar
			@ LI,005 PSay B1_COD
         @ li,022 PSay B1_TERUM  // B1_UM
         @ li,041 PSay FUniToEmb(nAqIniAlm,SB1->B1_COD,"@K 999999/999")
         @ li,056 PSay FUniToEmb(nAqCompra,SB1->B1_COD,"@K 999999/999")
         @ li,071 PSay FUniToEmb(nAqDevVen,SB1->B1_COD,"@K 999999/999")
         @ li,086 PSay FUniToEmb(nAqRetTrc,SB1->B1_COD,"@K 999999/999")
         @ li,101 PSay FUniToEmb(nAqDE4   ,SB1->B1_COD,"@K 999999/999")
         @ li,116 PSay FUniToEmb(nAqVendas,SB1->B1_COD,"@K 999999/999")
         @ li,131 PSay FUniToEmb(nAqSaiBON,SB1->B1_COD,"@K 999999/999")
         @ li,146 PSay FUniToEmb(nAqSaiTrc,SB1->B1_COD,"@K 999999/999")
         @ li,162 PSay FUniToEmb(nAqComoda,SB1->B1_COD,"@K 999999/999")
         @ li,177 PSay FUniToEmb(nAqSaiOut,SB1->B1_COD,"@K 999999/999")
         @ li,192 PSay FUniToEmb(nAqRE4   ,SB1->B1_COD,"@K 999999/999")
         @ li,207 PSay FUniToEmb(nAqFimAlm,SB1->B1_COD,"@K 999999/999")
			li++
         @ li,000 PSay Left(B1_DESC,30)
         @ li,039 PSay nAvIniAlm Picture PesqPictQt("B2_QATU",14)
         @ li,052 PSay nAvCompra Picture cPictSD114
         @ li,067 PSay nAvDevVen Picture cPictSD114
         @ li,082 PSay nAvRetTrc Picture cPictSD114
         @ li,097 PSay nAvDE4    Picture cPictSD314
         @ li,112 PSay nAvVendas Picture cPictSD214
         @ li,127 PSay nAvSaiBON Picture cPictSD214
         @ li,142 PSay nAvSaiTrc Picture cPictSD214
         @ li,158 PSay nAvComoda Picture cPictSD214
         @ li,173 PSay nAvSaiOut Picture cPictSD214
         @ li,188 PSay nAvRE4    Picture cPictSD314
         @ li,205 PSay nAvFimAlm Picture PesqPictQt("B2_QATU",14)
			li++;li++

			nTvIniAlm += nAvIniAlm
			nTvCompra += nAvCompra
			nTvDevVen += nAvDevVen
         nTvRetTrc += nAvRetTrc
         nTvSaiBON += nAvSaiBON
         nTvSaiTrc += nAvSaiTrc
         nTvDE4    += nAvDE4
         nTvRE4    += nAvRE4
         nTvComoda += nAvComoda
         nTvSaiOut += nAvSaiOut
			nTvVendas += nAvVendas
			nTvFimAlm += nAvFimAlm
			lTeveItem := .T.
			lPassou   := .F.
		EndIf
      dbSelectArea("SB1")
      dbSkip()
	EndDo
     
	If Li > 55
		Cabec(titulo,cabec1,cabec2,wnrel,Tamanho,nTipo)
	Endif
     
	If lTeveItem
		If aReturn[8] == 1
			@ li,000 PSay "Total Tipo : " + cVar
		Else
         @ li,000 PSay "Total Grupo: " + cVar
		EndIf
      @ li,039 PSay nTvIniAlm Picture PesqPictQt("B2_QATU",14)
      @ li,052 PSay nTvCompra Picture cPictSD114
      @ li,067 PSay nTvDevVen Picture cPictSD114
      @ li,082 PSay nTvRetTrc Picture cPictSD114
      @ li,097 PSay nTvDE4    Picture cPictSD314
      @ li,112 PSay nTvVendas Picture cPictSD214
      @ li,127 PSay nTvSaiBON Picture cPictSD214
      @ li,142 PSay nTvSaiTrc Picture cPictSD214
      @ li,158 PSay nTvComoda Picture cPictSD214
      @ li,173 PSay nTvSaiOut Picture cPictSD214
      @ li,188 PSay nTvRE4    Picture cPictSD314
      @ li,205 PSay nTvFimAlm Picture PesqPictQt("B2_QATU",14)
		li := li + 2
		nGvIniAlm += nTvIniAlm
		nGvCompra += nTvCompra
		nGvDevVen += nTvDevVen
      nGvRetTrc += nTvRetTrc
      nGvSaiBON += nTvSaiBON
      nGvSaiTrc += nTvSaiTrc
      nGvDE4    += nTvDE4
      nGvRE4    += nTvRE4
      nGvComoda += nTvComoda
      nGvSaiOut += nTvSaiOut
		nGvVendas += nTvVendas
		nGvFimAlm += nTvFimAlm
		lTeveItem  := .F.
	EndIf
   dbSelectArea("SB1")
EndDo

If li != 80
	Li++
	@ li,000 PSay "TOTAL GERAL : "
   @ li,039 PSay nGvIniAlm Picture PesqPictQt("B2_QATU",14)
   @ li,052 PSay nGvCompra Picture cPictSD114
   @ li,067 PSay nGvDevVen Picture cPictSD114
   @ li,082 PSay nGvRetTrc Picture cPictSD114
   @ li,097 PSay nGvDE4    Picture cPictSD314
   @ li,112 PSay nGvVendas Picture cPictSD214
   @ li,127 PSay nGvSaiBON Picture cPictSD214
   @ li,142 PSay nGvSaiTrc Picture cPictSD214
   @ li,158 PSay nGvComoda Picture cPictSD214
   @ li,173 PSay nGvSaiOut Picture cPictSD214
   @ li,188 PSay nGvRE4    Picture cPictSD314
   @ li,205 PSay nGvFimAlm Picture PesqPictQt("B2_QATU",14)
	Roda(cbcont,cbtxt,Tamanho)
EndIf

dbSelectArea("SB1")
Set Filter To
dbSetOrder(1)

dbSelectArea("SD1")
dbSetOrder(1)

dbSelectArea("SD2")
dbSetOrder(1)

dbSelectArea("SD3")
dbSetOrder(1)

Set device to Screen

If aReturn[5] = 1
	Set Printer TO 
	Commit
	OurSpool(wnrel)
Endif

MS_FLUSH()

Return Nil