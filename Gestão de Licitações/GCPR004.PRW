#INCLUDE "Protheus.ch"
#INCLUDE "MsOle.ch"
#INCLUDE "GCPR004.ch"

/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������ͻ��
���Programa  � GCPR004 �Autor  � Totvs              � Data �  01/04/10   ���
����������������������������������������������������������������������������͹��
���Desc.     � Geracao do Termo de Homologacao                               ���
����������������������������������������������������������������������������͹��
���Uso       � GCP - Gest�o de Compras Publicas                             ���
����������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
*/

Function GCPR004()

//����������������������������������������������������������������������������������Ŀ
//� Define variaveis locais                                                          �
//������������������������������������������������������������������������������������

Local aAliasAnt  := GetArea()
Local aItemEdt	:= {}
Local lRet       := .F.
Local cArquivo   := AllTrim(GETMV("MV_GCPTERM",,"GCP_TERHOM"))
Local cArqDest   := ""
Local cPartic    := ""
Local cLoja      := ""
Local cCodpro    := ""
Local nQuant     := ""
Local nVlUnit    := ""
Local aDadosWord := {}
Local aDados     := {}
Local aRet       := {}
Local aParam     := {}
Local nX         := 1
Local nY		 := 1
Local cAlias     := ""
Local cTitulo     := STR0001 //"Termo de Homologa��o"

//����������������������������������������������������������������������������������Ŀ
//� Define variaveis que devem sair no documento                                     �
//������������������������������������������������������������������������������������

Local cFolhas     := Space(10)
Local cDescPro    := ""
Local cCI         := Space(120)
Local dDataCI     := CtoD("")
Local cNome1      := Space(120)
Local cCargo1     := Space(120)
Local cNome2      := Space(120)
Local cCargo2     := Space(120)
Local cDescFornec := ""
Local cDescProd	  := ""	
Local nValor      := 0
Local nDia        := StrZero(Day(dDataBase),2)
Local cMes        := GCPRetMes(Month(dDataBase))
Local nAno        := StrZero( Year(dDataBase),4)
Local lGrava	  := .T.
Local cAval       := ""
Local aLote       := {}	
Local cLote       := ""
Local cDscModal   := ""
Local aSldItem    := {}
Private cPerg     := "GCR004"
Private cCodEdt   := ""
Private cNumPro   := ""

//Caso a chamada seja feita pelo EDITAL
If FunName() == "GCPA002"
	cCodEdt   := CO1->CO1_CODEDT
	cNumPro   := CO1->CO1_NUMPRO
Else
	If Pergunte(cPerg,.T.)
		cCodEdt   := MV_PAR01
		cNumPro   := MV_PAR02
	
		DbSelectArea("CO1")
		DbSetOrder(1)
		If !DbSeek(xFilial("CO1")+cCodEdt+cNumPro)
	   		Help(" ",1,"GCPR04EDT")//"Edital n�o encontrado"
			Return(.F.)
		EndIf
		If CO1->CO1_ETAPA $ 'PE/PR'
			HELP("   ",1,"GCPRELREV",,STR0006 ,1)//"Edital Revogado/Cancelado, n�o � poss�vel emitir o relat�rio"
			Return(.F.)
		EndIf
	Else
		RestArea(aAliasAnt)
		Return(.T.)
	EndIf
EndIf
	
cAlias := If(CO1->CO1_MODALI == "LL","SA1","SA2")
cAval  := CO1->CO1_AVAL
cDscModal:=AllTrim(Posicione("SX5",1,xFilial("SX5")+"LF"+CO1->CO1_MODALID,"X5DESCRI()"))

//����������������������������������������������������������������������������������Ŀ
//� Configura perguntas - Funcao Parambox                                            �
//������������������������������������������������������������������������������������

//-- array com o retorno do parambox
AAdd(aRet,cFolhas) 	// numero das folhas
AAdd(aRet,cCI)     	// CI
AAdd(aRet,dDataCi) 	// data CI
AAdd(aRet,cNome1)  	// primeiro nome


//-- array com a configuracao do parambox
AAdd(aParam,{1,"Fls." 			,aRet[1],"9999/9999","","","",50,.T.})
AAdd(aParam,{1,STR0002      	,aRet[2],"","","","",110,.F.})//"N� da CI"
AAdd(aParam,{1,STR0003       	,aRet[3],"@D","","","",50,.F.})//"Data CI"
AAdd(aParam,{1,STR0004 	,aRet[4],"","","","",110,.F.})//"Respons�vel"


//-- chamada da funcao parambox()
lRet := ParamBox(aParam,cTitulo,@aRet,,,.T.,80,3)

If ! lRet
	Help(" ",1,"GCPR04CAN")//"A opera��o foi cancelada."
	Return(lRet)
Endif

cFolhas := aRet[1]
cCI     := aRet[2]
dDataCI := aRet[3]
cNome1  := aRet[4]

MsgRun(STR0005,,{|| aDados := GCPA009()})//"Verificando ganhadores..."

If Len(aDados) == 0
	RestArea(aAliasAnt)
	Return(.T.)
Endif	

For nX := 1 To Len(aDados)
	cPartic := aDados[nX,1]
	cLoja   := aDados[nX,2]
	cCodpro := aDados[nX,3]
	nQuant  := aDados[nX,4]
	nVlUnit := aDados[nX,5]
	
	aSldItem := {cCodEdt,cNumPro,cCodPro}
	GCPSldItem("3",aSldItem)
	//-- Se nao efetuou a entrega total, abate a quantidade ja entregue (CO2_QUANT - C7_QUJE)
	//-- Se efetuou a entrega total devera permanecer com a quantidade original CO2_QUANT
	If	aSldItem[1]<nQuant
		nQuant -= aSldItem[1]
	EndIf		

	SB1->(DbSetOrder(1))
	SB1->(DbSeek(xFilial("SB1")+cCodPro))

	DbSelectArea(cAlias)
	DbSetOrder(1)
	DbSeek(xFilial(cAlias)+cPartic+cLoja)
	cCampo := SubStr(cAlias,2,2)+"_NOME"
	cNomFornec := &(cCampo)

	If	cAval=="2"
		CO3->(DbSetOrder(1))
		CO3->(DbSeek(xFilial("CO3")+cCodEdt+cNumPro+cCodPro+"2"+cPartic+cLoja))
		nItem := AScan(aItemEdt,{|x|x[1]+x[2]+x[8]==cPartic+cLoja+CO3->CO3_LOTE})
	Else
		nItem := AScan(aItemEdt,{|x|x[1]+x[2]==cPartic+cLoja})
	EndIf

	AAdd(aItemEdt,{cPartic,cLoja,cNomFornec,cCodPro,"",0,0,Iif(cAval=="2",CO3->CO3_LOTE,Space(TamSX3("CO3_LOTE")[1]))})
	nItem := Len(aItemEdt)
	
	If	!(AllTrim(SB1->B1_DESC) $ aItemEdt[nItem,5])
		aItemEdt[nItem,5] += AllTrim(SB1->B1_DESC)+", "
	EndIf
	aItemEdt[nItem,6] += nQuant
	aItemEdt[nItem,7] += (nQuant * nVlUnit)
Next


For nX := 1 To Len(aItemEdt)

	AAdd(aDadosWord , {"cFolhas"    , cFolhas    })
	AAdd(aDadosWord , {"cCodEdt"    , cCodEdt    })
	AAdd(aDadosWord , {"cNumPro"    , cNumPro    })
	AAdd(aDadosWord , {"cDscModal"  , cDscModal  })
	AAdd(aDadosWord , {"cDescProd"  , Stuff( aItemEdt[nX,5], Rat(", ",aItemEdt[nX,5]), 2, "")  })
	AAdd(aDadosWord , {"cCI"        , cCI        })
	AAdd(aDadosWord , {"dDataCI"    , dDataCI    })
	AAdd(aDadosWord , {"cNomFornec" , aItemEdt[nX,3] })
	AAdd(aDadosWord , {"nValor"     , Transform(aItemEdt[nX,7], "@E 9,999,999,999.99")})
	AAdd(aDadosWord , {"nDia"       , nDia       })
	AAdd(aDadosWord , {"cMes"       , cMes       })
	AAdd(aDadosWord , {"nAno"       , nAno       })
	AAdd(aDadosWord , {"cResp"     , cNome1     })
	AAdd(aDadosWord , {"cNomeEmp"    , SM0->M0_NOMECOM})
	AAdd(aDadosWord , {"cLote"		, Iif(cAval=="2",STR0007+aItemEdt[nX,8],"") })	//"Lote "
	
	cArqDest  := cArquivo+Alltrim(cCodEdt)+AllTrim(StrZero(nX,3))
	
	cAnexo := GCPGeraArq(cArquivo,cArqDest,aDadosWord)
	
	If !Empty(cAnexo)
		lRet := .T.
	EndIf

Next

RestArea(aAliasAnt)

Return(lRet)
