#INCLUDE "PROTHEUS.CH"
#INCLUDE "FATP010.CH"

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �FATP010   � Autor � Marco Bianchi         � Data � 18/01/2007 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Monta array para Painel de Gestao Tipo 4: Meta de Venda       ���
���          �                                                              ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �FATP010()                                                     ���
���������������������������������������������������������������������������Ĵ��
���Retorno   � Array = {cText1,nPosIni,nPosFim,{cValor,cLegenda,nColorValor,���
���          � cClick,nPos},{cValor,cLegenda,nColorValor,cClick,nPos}}      ���
���          � cText1      = Texto da Barra                         		���
���          � nPosIni     = Valor Inicial                      		    ���
���          � nPosFim     = Valor Final                                    ���
���          � cValor      = Valor a ser exibido                            ���
���          � cLegenda    = Nome da Legenda                                ���
���          � nColorValor = Cor do Valor no formato RGB (opcional)         ���
���          � cClick      = Funcao executada no click do valor (opcional)  ���
���          � nPos        = Valor da Barra                                 ���
���������������������������������������������������������������������������Ĵ��
���Uso       � SIGAMDI                                                      ���
���������������������������������������������������������������������������Ĵ��
��� Atualizacoes sofridas desde a Construcao Inicial.                       ���
���������������������������������������������������������������������������Ĵ��
��� Programador  � Data   � BOPS �  Motivo da Alteracao                     ���
���������������������������������������������������������������������������Ĵ��
���              �        �      �                                          ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/


Function FATP010()

Local aRet       := {} 
Local nMeta      := 0							// Meta ate final do mes
Local nMetaHj    := 0							// Meta ate Data Base
Local nVendas    := 0			 				// Vendas realizadas no mes
Local nDevol     := 0   						// Devolucoes realizadas no mes
Local nTpMeta    := 1							// 1 = por Valor, 2 = por Quantidade
Local cMes       := StrZero(Month(dDataBase),2)
Local cAno       := Substr(DTOC(dDataBase),7,2)
Local dDataIni   := CTOD("01/"+cMes+"/"+cAno)
Local dDataFim   := CTOD(StrZero(F_ULTDIA(dDataBase),2)+"/"+cMes+"/"+cAno)
Local nPercMt	 := 0
Local nPercReal  := 0
Local cMensagem1 := ""
Local cMensagem2 := ""
          

//��������������������������������������������������������������Ŀ
//�Parametros                                                    �
//����������������������������������������������������������������
Pergunte("FATP010",.F.)
nTpMeta  := mv_par01

//��������������������������������������������������������������Ŀ
//�Chama a funcao de calculo das Metas                           �
//�Parametros�ExpN1: Tipo de Meta  :( 1-Valor    )               �
//�          �                      ( 2-Quantidade )             �
//�          �ExpC2: cCodigo do Vendedor/Supervisor/Gerente      �
//�          �ExpD3: Data de Inicio                              �
//�          �ExpD4: Data de Termino                             �
//�          �ExpC5: Regiao de Vendas                            �
//�          �ExpC6: Tipo de Produto                             �
//�          �ExpC7: Grupo de Produto                            �
//�          �ExpC8: Codigo do Produto                           �
//����������������������������������������������������������������
nMetaHj := FtMetaVenda(nTpMeta,,dDataIni,dDataBase)		// Meta ate DataBase
nMeta   := FtMetaVenda(nTpMeta,,dDataIni,dDataFim)		// Meta do Mes

//��������������������������������������������������������������Ŀ
//�Chama a funcao de calculo das vendas                          �
//�Parametros:                                                   �
//�    ExpN1: Tipo Meta :(1-Numerico-Valor liquido - desconto )  �
//�                      (2-Numerico-Quantidade )                �
//�                      (3-Numerico-Valor bruto + desconto )    �
//�                      (4-Array-contendo todos os valores acima�
//�                      (5-Array-contendo todos os valores acima�
//�                       por produto                            �
//�    ExpC2: cCodigo                                            �
//�    ExpD3: Data de Inicio                                     �
//�    ExpD4: Data de Termino                                    �
//�    ExpC5: Regiao de Vendas.                                  �
//�    ExpC6: Tipo de Produto                                    �
//�    ExpC7: Grupo de Produto                                   �
//�    ExpC8: Codigo do Produto                                  �
//�    ExpN9: Moeda para conversao                               �
//�    ExpCA: Cliente                                            �
//�    ExpCB: Loja                                               �
//�    ExpCC: Expressao a ser adicionada na Query ou Filtro para �
//�           SGBD ISAM                                          �
//�    ExpCD: Determina se devem ser consideradas N.fiscais (1)  �
//�           REMITOS (2) ou ambos tipos de documento (3)        �
//����������������������������������������������������������������
nVendas := FtNfVendas(1,,dDataIni,dDataFim,,,,,1)

//��������������������������������������������������������������Ŀ
//�Chama a funcao de calculo das devolucoes de venda             �
//�Parametros:                                                   �
//� ExpN1: Tipo de Meta :(1-Numerico-Valor liquido - desconto )  �
//�                      (2-Numerico-Quantidade )                �
//�                      (3-Numerico-Valor bruto + desconto )    �
//�                      (4-Array-contendo todos os valores acima�
//�                      (5-Array-contendo todos os valores acima�
//�                       por produto                            �
//� ExpC2: cCodigo                                               �
//� ExpD3: Data de Inicio                                        �
//� ExpD4: Data de Termino                                       �
//� ExpC5: Regiao de Vendas.                                     �
//� ExpC6: Tipo de Produto                                       �
//� ExpC7: Grupo de Produto                                      �
//� ExpC8: Codigo do Produto                                     �
//� ExpN9: Moeda para conversao                                  �
//� ExpCA: Cliente                                               �
//� ExpCB: Loja                                                  �
//� ExpCC: Determina se devem ser consideradas Notas fiscais (1) �
//�        REMITOS (2) ou ambos tipos de documento (3)           �
//����������������������������������������������������������������
nDevol   := FtNfDevol(1,,dDataIni,dDataFim,,,,,1)

//������������������������������������������������������������������������Ŀ
//�Calcula percentuais                                                     �
//��������������������������������������������������������������������������
nPercMt	  := Round( ((nMetaHj * 100) / nMeta),0)
nPercReal := Round( (((nVendas-nDevol) * 100) / nMeta),0)

//������������������������������������������������������������������������Ŀ
//�Monta mensagens apresentadas ao clicar no percentual                    �
//��������������������������������������������������������������������������
If nTpMeta == 1
	cMensagem1 := "'"+STR0004 + "'+chr(13)+chr(10)+" 										 	        // "Calculos por Valor"
	cMensagem1 += "'"+"-----------------------" + "'+chr(13)+chr(10)+" 
	cMensagem1 += "'"+PadR(STR0005,35) + Transform(nMeta,"@E 999,999,999.99") + "'+chr(13)+chr(10)+"   // "Meta do Mes"
	cMensagem1 += "'"+PadR(STR0006,35) + Transform(nMetaHj,"@E 999,999,999.99")+"'"					// "Meta alcancada ate hoje"
	cMensagem2 := "'"+PadR(STR0007,35) + Transform(nVendas-nDevol,"@E 999,999,999.99")+"'" 		    // "Valor realizado ate hoje"
Else
	cMensagem1 := "'"+STR0008 + "'+chr(13)+chr(10)+"										            // "Calculos por Quantidade"
	cMensagem1 += "'"+"------------------------------" + "'+chr(13)+chr(10)+" 	
	cMensagem1 += "'"+PadR(STR0009,35) + Transform(nMeta,"@E 999,999,999.99") + "'+chr(13)+chr(10)+"  // "Meta do Mes"
	cMensagem1 += "'"+PadR(STR0010,35) + Transform(nMetaHj,"@E 999,999,999.99")+"'"					// "Meta alcancada ate hoje"
	cMensagem2 := "'"+PadR(STR0011,35) + Transform(nVendas-nDevol,"@E 999,999,999.99")+"'"			    // "Quantidade realizada ate hoje"
EndIf

//������������������������������������������������������������������������Ŀ
//�Preenche array do Painel de Gestao                                      �
//��������������������������������������������������������������������������
aRet :=	{ STR0001,0,100,;	// "Meta x Realizado"
			{{AllTrim(Str(nPercMt))+" %" ,STR0002 ,CLR_RED ,"{ || MsgInfo("+cMensagem1+") }",nPercMt},;	// "% Meta ate Hoje"
			{AllTrim(Str(nPercReal))+" %",STR0003 ,CLR_BLUE,"{ || MsgInfo("+cMensagem2+") }",nPercReal}}}	// "% Realizado"

Return aRet
                   