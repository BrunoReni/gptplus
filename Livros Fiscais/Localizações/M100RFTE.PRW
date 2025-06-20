#include "SIGAWIN.CH"        // incluido pelo assistente de conversao do AP5 IDE em 09/09/99
#include "PROTHEUS.CH" 
#INCLUDE "TOPCONN.CH"   
#DEFINE _DEBUG   .F.   // Flag para Debuggear el codigo
#DEFINE _NOMIMPOST 01
#DEFINE _ALIQUOTA  02
#DEFINE _BASECALC  03
#DEFINE _IMPUESTO  04
#DEFINE _VLRTOTAL  3
#DEFINE _FLETE     4
#DEFINE _GASTOS    5
//Posicoes  do terceiro array recebido nos impostos a traves da matxfis...
#DEFINE X_IMPOSTO    01 //Nome do imposto
#DEFINE X_NUMIMP     02 //Sufixo do imposto 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � M100RFTE � Autor � Laura Medina Prado  � Data � 02.07.2013 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Calculo do RFTE - Entrada                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� cPar01 - Solicitacao da MATXFIS, pondendo ser A (aliquota),���
���          �          B (base), V (valor).                              ���
���          � nPar02 - Item do documento fiscal.                         ���
���          � aPar03 - Array com as informacoes do imposto.              ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � xRet - Retorna o valor solicitado pelo paremetro cPar01    ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
��� Uso      � MATXFIS                                                    ���
�������������������������������������������������������������������������Ĵ��
��� Programador � Fecha  � Comentario                                     ���
�������������������������������������������������������������������������Ĵ��
���Laura Medina �22/11/13� Se modifico para que tome el %Base de Cal por  ���
���             �        � proveedor y con opci�n a cambiar desde la NF.  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function M100RFTE(cCalculo,nItem,aInfo) 

Local aRet
Local cFunct   := ""
Local aCountry := {}
Local lXFis    := .T.
Local aArea    := GetArea()

/*
���������������������������������������������������������������Ŀ
� Observacao :                                                  �
�                                                               �
� a variavel ParamIxb tem como conteudo um Array[2], contendo : �
� [1,1] > Quantidade Vendida                                    �
� [1,2] > Preco Unitario                                        �
� [1,3] > Valor Total do Item, com Descontos etc...             �
� [1,4] > Valor do Frete Rateado para Este Item ...             �
� [1,5] > Array Contendo os Impostos j� calculados, no caso de  �
�         incid�ncia de outros impostos.                        �
� [2,1] > Array aImposto, Contendo as Informa��es do Imposto que�
�         ser� calculado.                                       �
�����������������������������������������������������������������
*/
	
lXFis    := ( MafisFound() .And. ProcName(1)!="EXECBLOCK" )
aCountry := GetCountryList()
cFunct   := "M100RFT" + aCountry[aScan( aCountry, { |x| x[1] == cPaisLoc } )][3] //Monta el nombre de la funcion
aRet     := &(cFunct)(cCalculo,nItem,aInfo,lXFis) //Ejecuta la funcion del pais

RestArea(aArea)

Return aRet    



/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Programa  � M100RFTCO � Autor � Laura Medina        � Data � 03.07.2013 ���
��������������������������������������������������������������������������Ĵ��
���Descricao � Calculo do IRF - Entrada                                    ���
��������������������������������������������������������������������������Ĵ��
���Parametros� cPar01 - Solicitacao da MATXFIS, pondendo ser A (aliquota), ���
���          �          B (base), V (valor).                               ���
���          � nPar02 - Item do documento fiscal.                          ���
���          � aPar03 - Array com as informacoes do imposto.               ���
���          � lPar04 - Define se e rotina automaticao ou nao.             ���
��������������������������������������������������������������������������Ĵ��
���Retorno   � xRet - Retorna o valor solicitado pelo paremetro cPar01     ���
��������������������������������������������������������������������������Ĵ��
��� Uso      � Colombia                                                    ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/


Function M100RFTCO(cCalculo,nItem,aInfo,lXFis)

Local xRet
Local cContrib  := ""
Local cLojaPro  := ""
Local cCodPro   := ""  
Local lFacEnt   := .F.    
Local nBaseRet  := 0 //Base de retencion Fuente
Local nBaseRUVT := 0 //Base de retencion Fuente en UVT
Local nMV_UVT   := SuperGetMv("MV_VALUVT",,26841) //Si no esta creado toma el valor por default
Local nPorcCal  := M->F1_TASARFT  //SuperGetMv("MV_TASARFT")

Private clTipo  := ""

SetPrvt("CALIASROT,CORDEMROT,AITEMINFO,AIMPOSTO,_CPROCNAME,_CZONCLSIGA")
SetPrvt("_LAGENTE,_LEXENTO,AFISCAL,_LCALCULAR,_LESLEGAL,_NALICUOTA,NALIQ")
SetPrvt("_NVALORMIN,_NREDUCIR,CTIPOEMPR,CTIPOCLI,CTIPOFORN,CZONFIS,CCFO,")
SetPrvt("CCLASCLI,CCLASFORN,CMVAGENTE,NPOSFORN,NPOSLOJA,NTOTBASE,LRETCF")

lRet    := .F.
lRetCF  := .T.
cAliasRot  := Alias()
cOrdemRot  := IndexOrd()
cTipo 	:= Iif( Type("cTipo")=="U","N",cTipo)
xRet	:=0  

lXFis:=(MaFisFound() .And. ProcName(1)<>"EXECBLOCK")
	
If !lXFis
	aItemINFO  := ParamIxb[1]
	aImposto   := ParamIxb[2]
	xRet:=aImposto
Else
	xRet:=0
Endif
nBase      := 0
clTipo	   := ""
//�����������������������������������������������������������������������Ŀ
//�Deve-se verificar se cEspecie pertence a NCC/NCE/NDC/NDE para que ocor-�
//�ra busca no SA1, caso contrario deve-se buscar no SA2(Arq.Proveedores) �
//�������������������������������������������������������������������������
If cTipo = "D"   // devolucao de venda 
	cContrib    := SA1->A1_CONTRBE //CONTRIBUINTE    
	cAgRet      := SA1->A1_RETENED
Else
	cTipoCliFor := SA2->A2_TPESSOA
	cAgRet      := SA2->A2_RETENED
	cLojaPro    := SA2->A2_LOJA
	cCodPro     := SA2->A2_COD  
	If  ( Alltrim(cEspecie) == "NF" ) //Solo aplican facturas de entrada   
		lFacEnt := .T. 
	Endif
Endif

/*If  (cAgRet == "S") //Verificar si es agente retenedor                            
	lRetCF := .F.
Else
	lRetCF := .T.           
Endif    */                   
   
//���������������������������������������������������������������������Ŀ
//�             Verifica se Calcula Retencao en la Fuente:              �
//�                        Cliente / Proveedor                          �
//�����������������������������������������������������������������������
If lFacEnt

	nBase    :=0
	nAliq    :=0
	nDesconto:=0
	nVRet    :=0
	aValRet  := {0,0}
	
	//�������������������������������������������������������������������Ŀ
	//�Verifico no SFB existe SFB->ALIQ e nao apresenta tabela SFB->TABELA�
	//���������������������������������������������������������������������
	dbSelectArea("SFB")
	dbSetOrder(1)
	If dbSeek(xFilial("SFB")+aInfo[X_IMPOSTO])
		If  cCalculo$"ABV"  //Aliquota/Base		  
			nVal :=MaFisRet(nItem,"IT_VALMERC")+MaFisRet(nItem,"IT_FRETE")+MaFisRet(nItem,"IT_DESPESA")+MaFisRet(nItem,"IT_SEGURO")
			nAliq:=SFB->FB_ALIQ		
			lRet := .F.
			If  Alltrim(aInfo[X_IMPOSTO])=="RFT"   //Burcar en la tabla el valor que le va a corresponder
				lRet := .T.						
			Else
				lRet:=.F.
			Endif
		Endif
	Endif

	If lRet
		Do Case     
			Case cCalculo=="A"      //Pendiente, sera el valor que le corresponda en la tabla
				nVRet:=nAliq
			Case cCalculo=="B"    
				nBase:= nVal
				nTaxaMoed := 0
				nMoeda := 1
			   	If Type("M->F1_MOEDA")<>"U" 			   	
				    nMoeda    := M->F1_MOEDA
				    nTaxaMoed := M->F1_TXMOEDA			
		        EndIf	        
		        nBaseAtu := xMoeda(nBase,nMoeda,1,Nil,Nil,nTaxaMoed)   
		             						
		        //�������������������������������������������������������Ŀ
		   	   	//�Obtener la facturacion del mes y la retencion RFT      �
		   	   	//���������������������������������������������������������			
				aValRet := RetValFT(cLojaPro,cCodPro)
				//aValRet[01] = base acumulada
				//aValRet[02] = retencao acumulada 				
				aValRet[1] := xMoeda(aValRet[1],1,nMoeda,Nil,Nil,Nil, nTaxaMoed)
				aValRet[2] := xMoeda(aValRet[2],1,nMoeda,Nil,Nil,Nil, nTaxaMoed)  
				
				nBaseRet   := (nBaseAtu + aValRet[1]) * nPorcCal   //Valor Factura actual + Valor TOTAL de compras 		
				nVRet:= nBaseRet                                                                                   
			Case cCalculo$"V"
				nBase:= nVal		
				nTaxaMoed := 0
				nMoeda := 1
			   	If Type("M->F1_MOEDA")<>"U" 			   	
				    nMoeda    := M->F1_MOEDA
				    nTaxaMoed := M->F1_TXMOEDA			
		        EndIf	        
		        nBaseAtu := xMoeda(nBase,nMoeda,1,Nil,Nil,nTaxaMoed)   
		             						
		        //�������������������������������������������������������Ŀ
		   	   	//�Obtener la facturacion del mes y la retencion RFT      �
		   	   	//���������������������������������������������������������			
				aValRet := RetValFT(cLojaPro,cCodPro)
				//aValRet[01] = base acumulada
				//aValRet[02] = retencao acumulada 				
				aValRet[1] := xMoeda(aValRet[1],1,nMoeda,Nil,Nil,Nil, nTaxaMoed)
				aValRet[2] := xMoeda(aValRet[2],1,nMoeda,Nil,Nil,Nil, nTaxaMoed)  
				
				nBaseRet   := (nBaseAtu + aValRet[1]) * nPorcCal   //Valor Factura actual + Valor TOTAL de compras 
				nBaseRUVT  := nBaseRet/ nMV_UVT   //Base de Retencion Fuente / Valor UVT 2013
				
				//�������������������������������������������������������Ŀ
		   	   	//�Obtener el valor valor UVT que le corresponde          �
		   	   	//���������������������������������������������������������		
				
				nVret := ObtUVT(nBaseRUVT,1)
				nVret := (IIf(nVret>0,nVret,0)  ) * nMV_UVT	   
				
				// Obtener el valor de retencion Acumulada (solo si hubo compras anteriores en el mes)	 
				If  aValRet[2]>0   //Hubo acumulado de Retencion
				    nVret := nVret - aValRet[2]
				Endif
					   						
		EndCase
	Endif                    
Endif

dbSelectArea( cAliasRot )
dbSetOrder( cOrdemRot )
Return(nVRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � RETVALFT �Autor  �Laura Medina        � Data �  03/07/13   ���
�������������������������������������������������������������������������͹��
���Desc.     �  Busca el acumulado del impuesto y el valor acumulado de   ���
���          �  retencion RFT.                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Colombia                                                   ���   
���Param  	 � cImp: imposto											  ��� 
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/ 
Static Function RetValFT(cLoja,cProveedor)

Local cQueryNF := ""
Local aArea    := GetArea()
Local aRetNF   := {0,0}         
Local aRet     := {0,0}      
Local nTamEsp  := TAMSX3("F1_ESPECIE")[1]  
Local cSF1Esp  := Padr("NF",nTamEsp)
   			
	//����������������������������������������������������������������Ŀ
	//�Seleciona el acumulado de retenciones del mes para las notas NF �
	//������������������������������������������������������������������			
	cQueryNF := " SELECT SUM(F1_VALMERC) SUMBASE, SUM(F1_VALIMP"+aInfo[X_NUMIMP]+") SUMRETENC
	cQueryNF += " FROM "+RetSqlName("SF1")+" SF1 "
	cQueryNF += " WHERE SF1.D_E_L_E_T_='' "
	cQueryNF += " AND SF1.F1_FILIAL  = '"+XFILIAL("SF1")+"' "		                                   		
	cQueryNF += " AND SF1.F1_EMISSAO LIKE '"+SubStr(Dtos(DDATABASE),1,6)+"%'"
	cQueryNF += " AND SF1.F1_ESPECIE = '"+cSF1Esp+"' "		
	cQueryNF += " AND SF1.F1_FORNECE = '"+cProveedor+"' "	
	cQueryNF += " AND SF1.F1_LOJA = '"+cLoja+"' "
	   
	cQueryNF:=ChangeQuery(cQueryNF)
	TcQuery cQueryNF New Alias "VALRTE"    

	DbSelectArea("VALRTE")
	If VALRTE->(!Eof())		
		aRetNF[1] := IIf(!Empty(VALRTE->SUMBASE),VALRTE->SUMBASE,0)
		aRetNF[2] := IIf(!Empty(VALRTE->SUMRETENC),VALRTE->SUMRETENC,0)				
		DbCloseArea()
    EndIf  
            
    aRet[1] := aRetNF[1] //base acumulada 
    aRet[2] := aRetNF[2] //valor de retencao acumulado 
        
RestArea(aArea)
Return aRet
                            

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Programa  � ObtUVT    � Autor � Laura Medina        � Data � 04.07.2013 ���
��������������������������������������������������������������������������Ĵ��
���Descricao � Obtener la Retenci�n en UVT del Pago mensualizado.          ���
��������������������������������������������������������������������������Ĵ��
���Parametros� cPar01 - Pago mensualizado en UVT                           ���
���          �                                                             ���
��������������������������������������������������������������������������Ĵ��
���Retorno   � xRet - Retorna el valor 'retencion' que le corresponde.     ���
��������������������������������������������������������������������������Ĵ��
��� Uso      � Colombia                                                    ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Static Function ObtUVT(nBaseUVT,nOpc)   
Local cQueryUVT:= ""
Local aArea    := GetArea()         
Local nValUVT  := 0 //Retencion en UVT 
Local cImpVar  := "RFT"    
Local nValExc  := 0
    
If  nOpc==1 .And. ObtRangos(nBaseUVT,@nValExc)  //Significa que est� al inicio o final del rango de la tabla y se aplica otra regla
	nValUVT := nValExc
	//Validar si es mayor de 1136.92

Else  
	//����������������������������������������������������������������Ŀ
	//�Seleciona la retencion UVT del pago mensualizado                �
	//������������������������������������������������������������������			
	cQueryUVT := " SELECT  FF_ALIQ, MAX(FF_IMPORTE) 
	cQueryUVT += " FROM "+RetSqlName("SFF")+" SFF "
	cQueryUVT += " WHERE SFF.D_E_L_E_T_='' " 
	cQueryUVT += " AND SFF.FF_FILIAL  = '"+XFILIAL("SFF")+"' "			                                   		
	cQueryUVT += " AND SFF.FF_IMPORTE < "+ str(nBaseUVT)+" "	
	cQueryUVT += " AND SFF.FF_IMPOSTO = '"+ cImpVar+"' "
	cQueryUVT += " GROUP BY FF_ALIQ, FF_IMPORTE"
	cQueryUVT += " ORDER BY FF_IMPORTE DESC"
		   
	cQueryUVT:=ChangeQuery(cQueryUVT)
	TcQuery cQueryUVT New Alias "VALRTE"    
	
	DbSelectArea("VALRTE")
	If VALRTE->(!Eof())		
		nValUVT:= IIf(!Empty(VALRTE->FF_ALIQ),VALRTE->FF_ALIQ,0)			
		VALRTE->(DbCloseArea())
    EndIf  

Endif    

	
	

RestArea(aArea)
Return nValUVT
                   

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Programa  � ObtRangos � Autor � Laura Medina        � Data � 10/07/2013 ���
��������������������������������������������������������������������������Ĵ��
���Descricao � Obtener el valor maximo y minimo de la tabla de Retencion   ���
���          � UVT.                                                        ���
��������������������������������������������������������������������������Ĵ��
���Parametros� cPar01 - Pago mensualizado en UVT                           ���
���          �                                                             ���
��������������������������������������������������������������������������Ĵ��
���Retorno   � xRet - Retorna el valor maximo y minimo                     ���
��������������������������������������������������������������������������Ĵ��
��� Uso      � Colombia                                                    ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Static Function ObtRangos(nBaseUVT,nValExc)   
Local cQueryUVT:= ""
Local aArea    := GetArea()         
Local cImpVar  := "RFT" 
Local lEsExcep := .F.  
Local cAliasTmp   := CriaTrab(Nil,.F.)   
  
	//����������������������������������������������������������������Ŀ
	//�Seleciona la retencion UVT del pago mensualizado                �
	//������������������������������������������������������������������			
	cQueryUVT := " SELECT  MAX(FF_IMPORTE) MAXUVT, MIN(FF_IMPORTE) MINUVT "
	cQueryUVT += " FROM "+RetSqlName("SFF")+" SFF "
	cQueryUVT += " WHERE SFF.D_E_L_E_T_='' " 
	cQueryUVT += " AND SFF.FF_FILIAL  = '"+XFILIAL("SFF")+"' "			                                   		
	cQueryUVT += " AND SFF.FF_IMPOSTO = '"+ cImpVar+"' "
		   
	cQueryUVT:=ChangeQuery(cQueryUVT)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueryUVT),cAliasTmp, .T., .T.) 
	
	DbSelectArea(cAliastmp)
	If  (cAliasTmp)->(!Eof())           
		If  nBaseUVT<MINUVT   //Validar si es menor de 128.96
			lEsExcep := .T.	 
			nValExc  := 0
		Elseif nBaseUVT>MAXUVT //Validar si es mayor de 1136.92
		    lEsExcep := .T.	
		    nValExc  := (0.27 * nBaseUVT )- ObtUVT(nBaseUVT,2)  
		Endif	
		(cAliasTmp)->(DbCloseArea())
    EndIf  
    


RestArea(aArea)
Return lEsExcep
