#INCLUDE "Protheus.ch"
#INCLUDE "MsOle.ch"
#INCLUDE "GCPR006.ch"

/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������ͻ��
���Programa  � GCPR006 �Autor  � Totvs              � Data �  01/04/10   ���
����������������������������������������������������������������������������͹��
���Desc.     � Geracao da Homologacao p/ Proposta de Resolucao de Diretoria  ���
����������������������������������������������������������������������������͹��
���Uso       � GCP - Gest�o de Compras Publicas                             ���
����������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
*/

Function GCPR006()

//����������������������������������������������������������������������������������Ŀ
//� Define variaveis locais                                                          �
//������������������������������������������������������������������������������������

Local aAliasAnt  := GetArea()

Local lRet       := .F.
Local cArquivo   := AllTrim(GETMV("MV_GCPPRD",,"GCP_RESDIR"))
Local cArqDest   := ""
Local aDadosWord := {}
Local aDados     := {}
Local aRet       := {}
Local aParam     := {}
Local nX         := 1
Local cAlias     := ""  
Local cArea		 := ""

//����������������������������������������������������������������������������������Ŀ
//� Define variaveis que devem sair no documento                                     �
//������������������������������������������������������������������������������������

Private cPerg     := "GCR006"
Private cCodEdt   := ""
Private cNumPro   := ""
Private cAnexo	  := ""

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
			Help(" ",1,"GCPR06EDT")//"Edital n�o encontrado"
			Return(.F.)
		EndIf     
		
		If CO1->CO1_ETAPA $ 'PE/PR'
			HELP("   ",1,"GCPRELREV",,STR0002 ,1)//"Edital Revogado/Cancelado, n�o � poss�vel emitir o relat�rio"
			Return(.F.)
		EndIf
	Else
		RestArea(aAliasAnt)
		Return(.T.)
	EndIf
EndIf

cArea	:= GetAdvFVal("CO4","CO4_DESCR",xFilial("CO4")+CO1->CO1_CC ,1) 	

AAdd(aDadosWord , {"cCodEdt"    , cCodEdt    })
AAdd(aDadosWord , {"cNumPro"    , cNumPro    })
AAdd(aDadosWord , {"cDia"    	, dToc(dDatabase) })
AAdd(aDadosWord , {"cArea"    	, cArea })

cArqDest  := cArquivo+Alltrim(cCodEdt)

MsgRun(STR0001,,{|| cAnexo := GCPGeraArq(cArquivo,cArqDest,aDadosWord) }) //"Verificando ganhadores..."

If !Empty(cAnexo)
	lRet := .T.
EndIf

RestArea(aAliasAnt)

Return(lRet)