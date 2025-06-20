#INCLUDE "PROTHEUS.CH"                           
#DEFINE _DEBUG   .F.   // Flag para Debuggear el codigo
#DEFINE _NOMIMPOST 01
#DEFINE _ALIQUOTA  02
#DEFINE _BASECALC  03
#DEFINE _IMPUESTO  04
#DEFINE _TES_CFO   10
#DEFINE _RATEOFRET 11
#DEFINE _IMPFLETE  12
#DEFINE _RATEODESP 13
#DEFINE _IMPGASTOS 14
#DEFINE _VLRTOTAL  3
#DEFINE _FLETE     4
#DEFINE _GASTOS    5
#DEFINE _ALIQDESG  19

/*�����������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � M100IMPM � Autor � Jose Luis Otermin     � Data � 21.07.99   ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Programa que Calcula   IVA                                   ���
���������������������������������������������������������������������������Ĵ��
���Uso       � MATA100, llamado por un punto de entrada                     ���
���������������������������������������������������������������������������Ĵ��
��� ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                       ���
���������������������������������������������������������������������������Ĵ��
��� PROGRAMADOR  � DATA   � BOPS  �  MOTIVO DA ALTERACAO                    ���
���������������������������������������������������������������������������Ĵ��
��� Dora Vega    �18/04/17�MMI-166�Merge de replica del llamado TVZYP8.     ���
���              �        �       �Calculo de impuesto MCO de cordoba aunque���
���              �        �       �la empresa radique o no en cordoba.(ARG) ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
������������������������������������������������������������������������������*/ 

Function M100PCO(cCalculo,nItem,aInfo,cXFisRap)        // incluido pelo assistente de conversao do AP5 IDE em 09/09/99

//���������������������������������������������������������������������Ŀ
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//�����������������������������������������������������������������������

Local lXFis,xRet,nOrdSFC,nRegSFC,nBase
Local _nMoeda	:= 1

SetPrvt("CALIASROT,CORDEMROT,AITEMINFO,AIMPOSTO,_CPROCNAME,_CZONCLSIGA")
SetPrvt("_LAGENTE,_LEXENTO,AFISCAL,_LCALCULAR,_LESLEGAL,_NALICUOTA,_NALICDESG")
SetPrvt("_NVALORMIN,_NREDUCIR,")

Default cXFisRap := ""

/*����������������������������������������������������������������������
//-----------------------------------------------------
// Nota:
// Debe registrarse al Cliente en la Tabla SFH en caso
// que sea Agente de Percepcion o este Exento en una ZF.
// Se utiliza el parametro MV_AGENTE
// Significado de las posiciones de MV_AGENTE
// SUBSTR(MV_AGENTE,1,1) = Agente Retencion Ganancias? (S/N)
// SUBSTR(MV_AGENTE,2,1) = Agente Retencion IVA?       (S/N)
// SUBSTR(MV_AGENTE,3,1) = Agente Retencion IB?        (S/N)
// SUBSTR(MV_AGENTE,4,1) = Agente Percepcion IVA?      (S/N)
// SUBSTR(MV_AGENTE,5,1) = Agente Percepcion IB?       (S/N)
//-----------------------------------------------------
// Nota:
// Debe utilizarse el parametro MV_EXENTO
// Significado de las posiciones de MV_EXENTO
// SUBSTR(MV_EXENTO,1,1) = Exento Retencion Ganancias? (S/N)
// SUBSTR(MV_EXENTO,2,1) = Exento Retencion IVA?       (S/N)
// SUBSTR(MV_EXENTO,3,1) = Exento Retencion IB?        (S/N)
// SUBSTR(MV_EXENTO,4,1) = Exento Percepcion IVA?      (S/N)
// SUBSTR(MV_EXENTO,5,1) = Exento Percepcion IB?       (S/N)
//-----------------------------------------------------


/*/

// Movido para o inicio do arquivo pelo assistente de conversao do AP5 IDE em 09/09/99 ==> #DEFINE _DEBUG   .F.   // Flag para Debuggear el codigo


// Indices de aImposto
// Movido para o inicio do arquivo pelo assistente de conversao do AP5 IDE em 09/09/99 ==> #DEFINE _NOMIMPOST 01
// Movido para o inicio do arquivo pelo assistente de conversao do AP5 IDE em 09/09/99 ==> #DEFINE _ALIQUOTA  02
// Movido para o inicio do arquivo pelo assistente de conversao do AP5 IDE em 09/09/99 ==> #DEFINE _BASECALC  03
// Movido para o inicio do arquivo pelo assistente de conversao do AP5 IDE em 09/09/99 ==> #DEFINE _IMPUESTO  04
// Movido para o inicio do arquivo pelo assistente de conversao do AP5 IDE em 09/09/99 ==> #DEFINE _TES_CFO   10
// Movido para o inicio do arquivo pelo assistente de conversao do AP5 IDE em 09/09/99 ==> #DEFINE _RATEOFRET 11
// Movido para o inicio do arquivo pelo assistente de conversao do AP5 IDE em 09/09/99 ==> #DEFINE _IMPFLETE  12
// Movido para o inicio do arquivo pelo assistente de conversao do AP5 IDE em 09/09/99 ==> #DEFINE _RATEODESP 13
// Movido para o inicio do arquivo pelo assistente de conversao do AP5 IDE em 09/09/99 ==> #DEFINE _IMPGASTOS 14

// Subindices de aItemINFO
// Movido para o inicio do arquivo pelo assistente de conversao do AP5 IDE em 09/09/99 ==> #DEFINE _VLRTOTAL  3
// Movido para o inicio do arquivo pelo assistente de conversao do AP5 IDE em 09/09/99 ==> #DEFINE _FLETE     4
// Movido para o inicio do arquivo pelo assistente de conversao do AP5 IDE em 09/09/99 ==> #DEFINE _GASTOS    5

cEspecie:=IIF(Type("cEspecie")=="C",cEspecie,"NF")

lXfis:=(MaFisFound()  .And. ProcName(1)<>"EXECBLOCK")
cAliasRot  := Alias()
cOrdemRot  := IndexOrd()

If !lXFis
	aItemINFO  := ParamIxb[1]
	aImposto   := ParamIxb[2]
	xRet:=aImposto
Else
	xRet:=0
Endif

_cProcName := "M100PCO"

_cZonClSIGA:= SM0->M0_ESTCOB // Zona Fiscal del Cliente SIGA
_lAgente   := .T.     // En este impuesto el Proveedor Siempre cobra IVA.
_lExento   := .F.     // Este dato no se lleva en cuenta.

aFiscal    := ExecBlock("IMPGENER",.F.,.F.,{If(lXFis,{cCalculo,nItem,aInfo},ParamIxb), _cProcName, _lAgente,_cZonClSIGA,lXFis},.T.)

lCliente:=.F.

If lXFis
	lCliente  := (MaFisRet(,"NF_CLIFOR" ) == "C")
ElseIf Substr(cModulo,1,3) $ "FAT|OMS|LOJ|FRT|TMK"
	lCliente:=.t.
EndIf	

_lCalcular :=  aFiscal[1]
_lEsLegal  :=  aFiscal[2]
_nAlicuota :=  aFiscal[3]
_nValorMin :=  aFiscal[4]
_nReducir  :=  aFiscal[5]
_nMoeda    :=  aFiscal[7]
_nAlicDesg :=  aFiscal[11]

If lCliente .And. SA1->(FieldPos("A1_COD_MUN"))>0  .And. _lEsLegal
	If _cZonClSIGA == "CO" 
		_lEsLegal := Iif(SA1->A1_COD_MUN=="00004", .T., .F.)
	Else
		_lEsLegal := .F.
	EndIf
ElseIf SA2->(FieldPos("A2_COD_MUN"))>0 .And. _lEsLegal
	_lEsLegal := Iif(SA2->A2_COD_MUN=="00004",.T.,.F.)
EndIf

// NO se tiene en cuenta el valor _lCalcular porque este impuesto SIEMPRE
// Se cobra.

IF _lEsLegal .And. _lCalcular  //Solo considera el campo FH_ISENTO (No debe considerar el agente)
	
	If !lXFis
		aImposto[_RATEOFRET] := aItemINFO[_FLETE]      // Rateio do Frete
		aImposto[_RATEODESP] := aItemINFO[_GASTOS]     // Rateio de Despesas
		aImposto[_ALIQUOTA]  := _nAlicuota // Alicuota de Zona Fiscal del Proveedor
		aImposto[_BASECALC]  := aItemINFO[_VLRTOTAL]+aItemINFO[_FLETE]+aItemINFO[_GASTOS] // Base de C�lculo
		aImposto[_ALIQDESG]  := _nAlicDesg
		
		If Subs(aImposto[5],4,1) == "S"  .And. Len(AIMPOSTO) >= 18 .And. ValType(aImposto[18])=="N"
			aImposto[_BASECALC]	-=	aImposto[18]
		Endif
		
		IF _DEBUG
			msgstop(aImposto[_ALIQUOTA], "aImposto[_ALIQUOTA] - "+_cProcName)
			msgstop(aImposto[_BASECALC], "aImposto[_BASECALC] - "+_cProcName)
		ENDIF
		
		//+---------------------------------------------------------------+
		//� Efectua el C�lculo del Impuesto                               �
		//+---------------------------------------------------------------+
		If aImposto[_BASECALC] > _nValorMin
			If _nAlicDesg > 0 
				aImposto[_IMPUESTO]  := NoRound((aImposto[_BASECALC] * ( aImposto[_ALIQUOTA]/100)) * _nReducir ,MsDecimais(_nMoeda))		
				aImposto[_IMPUESTO]  := aImposto[_IMPUESTO] - ((aImposto[_IMPUESTO] * aImposto[_ALIQDESG]) / 100)
			Else
				aImposto[_IMPUESTO]  := NoRound((aImposto[_BASECALC] * ( aImposto[_ALIQUOTA]/100)) * _nReducir ,MsDecimais(_nMoeda))		
			EndIf
		ELSE
			aImposto[_IMPUESTO]  := 0.00
			aImposto[_IMPFLETE]  := 0.00
			aImposto[_IMPGASTOS] := 0.00
			aImposto[_RATEOFRET] := 0.00
			aImposto[_RATEODESP] := 0.00
		Endif
		xRet:=aImposto
	Else
		If !Empty(cXFisRap)
			nBase:=MaFisRet(nItem,"IT_VALMERC")
			If GetNewPar('MV_DESCSAI','1')=='1'
				nBase	+= MaFisRet(nItem,"IT_DESCONTO")
			Endif
			//Tira os descontos se for pelo liquido
			nOrdSFC:=(SFC->(IndexOrd()))
			nRegSFC:=(SFC->(Recno()))
			SFC->(DbSetOrder(2))
			If (SFC->(DbSeek(xFilial("SFC")+MaFisRet(nItem,"IT_TES")+aInfo[1])))
				If SFC->FC_LIQUIDO=="S"
					nBase -= MaFisRet(nItem,"IT_DESCONTO")
				Endif
			Endif
			xRet := {0,0,0}
			xRet[1] := nBase
			xRet[2] := _nAlicuota
			If "V" $ cXFisRap
				If SFC->FC_CALCULO=="T"
					nBase := MaRetBasT(aInfo[2],nItem,_nAlicuota)
				Endif
			 	If nBase > _nValorMin
			 		If _nAlicDesg > 0
			 	   		xRet[3]	:=	NoRound(nBase *(_nAlicuota /100) * _nReducir,MsDecimais(_nMoeda))
			 	   		xRet[3] := xRet[3] - ((xRet[3] *_nAlicDesg) / 100)
			 		Else
			       		xRet[3]	:=	NoRound(nBase *(_nAlicuota /100) * _nReducir,MsDecimais(_nMoeda))
			   		EndIf
			 	Endif
			Endif
			SFC->(DbSetOrder(nOrdSFC))
			SFC->(DbGoto(nRegSFC))
	Else
			Do Case
				Case cCalculo=="A"
					xRet:=_nAlicuota
				Case cCalculo=="B"
					nBase:=MaFisRet(nItem,"IT_VALMERC")
					If GetNewPar('MV_DESCSAI','1')=='1'
						nBase	+= MaFisRet(nItem,"IT_DESCONTO")
					Endif
					//Tira os descontos se for pelo liquido
					nOrdSFC:=(SFC->(IndexOrd()))
					nRegSFC:=(SFC->(Recno()))
					SFC->(DbSetOrder(2))
					If (SFC->(DbSeek(xFilial("SFC")+MaFisRet(nItem,"IT_TES")+aInfo[1])))
						If SFC->FC_LIQUIDO=="S"
							nBase -= MaFisRet(nItem,"IT_DESCONTO")
						Endif
					Endif
					xRet:=nBase
					MaFisAlt('NF_MINIV'+aInfo[2],_nValorMin,nItem)
					SFC->(DbSetOrder(nOrdSFC))
					SFC->(DbGoto(nRegSFC))
				Case cCalculo=="V"
					nOrdSFC:=(SFC->(IndexOrd()))
					nRegSFC:=(SFC->(Recno()))
					SFC->(DbSetOrder(2))
					SFC->(DbSeek(xFilial("SFC")+MaFisRet(nItem,"IT_TES")+aInfo[1]))
					If SFC->FC_CALCULO=="T"
						nBase := MaRetBasT(aInfo[2],nItem,_nAlicuota)
					Else
						nBase:=MaFisRet(nItem,"IT_VALMERC")
					Endif
					//����������������������������������������������������������
					//�tratamento para clientes responsaveis inscritos, porque �
					//�o calculo dos impostos na ecf sao feitos de maneira     �
					//�diferente para esses clientes.	                       �
					//����������������������������������������������������������
					If cPaisLoc == "ARG" .AND. nModulo == 12 .AND. ALLTRIM(SA1->A1_TIPO) == "I"
						If _nAlicDesg > 0
							xRet:=Round((nBase * (_nAlicuota / 100)),4)
							xRet := xRet - ((xRet *_nAlicDesg) / 100)
						Else
							xRet:=Round((nBase * (_nAlicuota / 100)),4)
						EndIf
					Else
						//If MaFisRet(nItem,'IT_BASEIV'+aInfo[2]) >  _nValorMin
						If nBase > _nValorMin
					 		If _nAlicDesg > 0
					 			xRet:= NoRound((nBase*(_nAlicuota/100)),MsDecimais(_nMoeda))
					 			xRet := xRet - ((xRet *_nAlicDesg) / 100)
					 		Else
					      		xRet:= NoRound((nBase*(_nAlicuota/100)),MsDecimais(_nMoeda))
					   		EndIf
				    	Endif
					Endif
					SFC->(DbSetOrder(nOrdSFC))
					SFC->(DbGoto(nRegSFC))
			Endcase
		Endif
	Endif
ENDIF

dbSelectArea( cAliasRot )
dbSetOrder( cOrdemRot )

Return( xRet )        // incluido pelo assistente de conversao do Siga Advanced Protheus IDE em 30/08/99
