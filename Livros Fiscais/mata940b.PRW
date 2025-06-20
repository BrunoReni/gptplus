#include "protheus.ch" 
#include "Rwmake.ch" 
#include "matr940b.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MATA940B 	� Autor � Juliana Taveira    � Data �  16/06/10   ���
�������������������������������������������������������������������������͹��
���Descricao � Relatorio demonstrativo de estoque para empresas sujeitas  ���
���          � ao regime de substituicao tributaria.					  ���
���          � Baseado no mata940 - Sintegra 							  ���
�������������������������������������������������������������������������͹��
���Uso       �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������                          
/*/
Function MATA940B()
Local cDesc1        := STR0001
Local cDesc2        := STR0002
Local cDesc3        := STR0003
Local cPict         := ""
Local titulo       	:= STR0004
Local nLin          := 80
Local Cabec1		:= STR0007
Local Cabec2       	:= ""
Local imprime      	:= .T.
Local aOrd        	:= {}
Private lEnd       	:= .F.
Private lAbortPrint	:= .F.
Private CbTxt      	:= ""
Private limite     	:= 80
Private tamanho    	:= "G"
Private nomeprog   	:= "MATR940B" 
Private nTipo      	:= 18
Private aReturn   	:= { STR0005, 1, STR0006, 2, 2, 1, "", 1}
Private nLastKey   	:= 0
Private cbcont     	:= 00
Private CONTFL     	:= 01
Private m_pag      	:= 01
Private wnrel      	:= nomeprog 
Private cPerg      	:= "MTR94B"
Private cString    	:= "SFT"

//�����������������������������Ŀ
//�Ajusta perguntas do relatorio�
//�������������������������������
pergunte(cPerg,.F.)

wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,"",.F.,Tamanho,,.F.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
   Return
Endif

nTipo := If(aReturn[4]==1,15,18)

RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return()

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Fun��o    �RUNREPORT � Autor � Juliana Taveira    � Data �  16/06/10   ���
�������������������������������������������������������������������������͹��
���Descri��o � Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS ���
���          � monta a janela com a regua de processamento.               ���
�������������������������������������������������������������������������͹��
���Uso       �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)
Local cFilDe := MV_PAR03
Local cFilAte:= MV_PAR04
Local cKey   := ""
Local lProd  := .F.

Local nPrdE1  	:= 0
Local nPrdE2  	:= 0
Local nPrdE3	:= 0
Local nPrdE4 	:= 0
Local nPrdE5   	:= 0
Local nPrdE6	:= 0
Local nPrdE7	:= 0
Local nPrdE8	:= 0

Local nPrdS1  	:= 0
Local nPrdS2  	:= 0
Local nPrdS3	:= 0
Local nPrdS4 	:= 0
Local nPrdS5   	:= 0
Local nPrdS6	:= 0
Local nPrdS7	:= 0
Local nPrdS8	:= 0

Local nTotE1 	:= 0
Local nTotE2 	:= 0
Local nTotE3 	:= 0
Local nTotE4 	:= 0
Local nTotE5 	:= 0
Local nTotE6 	:= 0
Local nTotE7 	:= 0
Local nTotE8 	:= 0

Local nTotS1 	:= 0
Local nTotS2 	:= 0
Local nTotS3 	:= 0
Local nTotS4 	:= 0
Local nTotS5 	:= 0
Local nTotS6 	:= 0
Local nTotS7 	:= 0
Local nTotS8 	:= 0         

Local cSdInt  	:= 	""
Local cSdPer  	:= 	""
Local cCfoNEnt  :=  ""

DbSelectArea("SX6")
SX6->(DbSetOrder(1))
//������������������������������������������������������Ŀ
//�Verifica todas as ocorrencias do parametro MV_N88INT  �
//��������������������������������������������������������
SX6->(DbSeek(xFilial("SX6")+"MV_N88INT"))
Do While !SX6->(Eof()) .And. xFilial("SX6") == SX6->X6_FIL .And. "MV_N88INT" $ SX6->X6_VAR
	cSdInt +=	AllTrim(SX6->X6_CONTEUD)
	SX6->(dbSkip())
EndDo
//����������������������������������������������������Ŀ
//�Verifica todas as ocorrencias do parametro MV_88PERD�
//������������������������������������������������������
SX6->(DbSeek(xFilial("SX6")+"MV_88PERD"))
Do While !SX6->(Eof()) .And. xFilial("SX6") == SX6->X6_FIL .And. "MV_88PERD" $ SX6->X6_VAR
	cSdPer +=	AllTrim(SX6->X6_CONTEUD)
	SX6->(dbSkip())
EndDo
//�����������������������������������������������������Ŀ
//�Verifica todas as ocorrencias do parametro MV_CFDEMST�
//�������������������������������������������������������
SX6->(DbSeek(xFilial("SX6")+"MV_CFDEMST"))
Do While !SX6->(Eof()) .And. xFilial("SX6") == SX6->X6_FIL .And. "MV_CFDEMST" $ SX6->X6_VAR
	cCfoNEnt +=	AllTrim(SX6->X6_CONTEUD)
	SX6->(dbSkip())
EndDo

//������������������������Ŀ
//�Monta arquivo temporario�
//��������������������������
MontTrab()                       

//�������������������������������������������Ŀ
//�Verifica como as filiais serao processadas:�
//�- apenas a filial                          �
//�- filial de/ate                            �
//���������������������������������������������
If (Empty(MV_PAR03) .And. Empty(MV_PAR04))
	cFilDe	:=	cFilAte	:=	cFilAnt
EndIf
//�������������������Ŀ
//�Processo as Filiais�
//���������������������
DbSelectArea ("SM0")
SM0->(DbSeek (cEmpAnt+cFilDe,.T.))

Do While !SM0->(Eof ()) .And. (SM0->M0_CODIGO==cEmpAnt) .And. (SM0->M0_CODFIL<=cFilAte)
	cFilAnt	:= SM0->M0_CODFIL
	//������������������������������Ŀ
	//�Busca notas fiscais de entrada�
	//��������������������������������
	BscEntr(cCfoNEnt)

	//����������������������������Ŀ
	//�Busca notas fiscais de saida�
	//������������������������������
	BscSda(cSdInt,cSdPer)
	SM0->(DbSkip())
EndDo

//���������������������������Ŀ
//�Seleciona tabela temporaria�
//�����������������������������
TRB2->(DbSelectArea("TRB2"))
TRB2->(dbGoTop())
ProcRegua(TRB2->(RecCount()))
TRB2->(DbGotop())
If TRB2->(EOF())
	MsgBox(STR0010) 
	TRB2->(DbCloseArea())
	Return()
EndIf

cKey := TRB2->PRODUTO
TRB2->(DbGotop())
While !TRB2->(Eof())
	
	IncProc()
	If lAbortPrint
		@nLin,00 PSAY STR0011
		Exit
	Endif
	
	If nLin > 60 // Salto de P�gina. Neste caso o formulario tem 55 linhas...
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 8
	Endif
	
	If !lProd
		nLin ++
		@nLin, 000 PSay "PRODUTO: " + TRB2->PRODUTO + " - " + TRB2->DESCRICAO
		nLin ++
		nLin ++
		lProd := .T.
	EndIf
	
	@ nLin, 000 Psay TRB2->CLIFOR
	@ nLin, PCOL() + 1 PSay TRB2->UF
	@ nLin, PCOL() + 1 PSay TRB2->EMISSAO
	@ nLin, PCOL() + 1 PSay TRB2->NUMERO+"-"+TRB2->SERIE
	@ nLin, PCOL() + 1 PSay Transform(TRB2->QTD, "@E 99999999.99")
	@ nLin, PCOL() + 1 PSay Transform(TRB2->VLRUNIT, "@E 999,999,999.99")
	@ nLin, PCOL() + 1 PSay Transform(TRB2->BSICM, "@E 999,999,999.99")
	@ nLin, PCOL() + 1 PSay Transform(TRB2->ICMSUN, "@E 999,999,999.99")
	@ nLin, PCOL() + 1 PSay Transform(TRB2->BSICMST, "@E 999,999,999.99")
	@ nLin, PCOL() + 1 PSay Transform(TRB2->ICMSTUN, "@E 999,999,999.99")
	@ nLin, PCOL() + 1 PSay Transform(TRB2->ICMSTO, "@E 999,999,999.99")
	@ nLin, PCOL() + 1 PSay Transform(TRB2->ICMSTTO, "@E 999,999,999.99")
	@ nLin, PCOL() + 6 PSay TRB2->TIPO
	@ nLin, PCOL() + 2 PSay TRB2->MOTIVO
	nLin ++
	If TRB2->TIPO == "E"
		//����������������������������������Ŀ
		//�Totalizador por produto - entradas�
		//������������������������������������
		nPrdE1 		:= nPrdE1 + TRB2->QTD
		nPrdE2 		:= nPrdE2 + TRB2->VLRUNIT
		nPrdE3 		:= nPrdE3 + TRB2->BSICM
		nPrdE4 		:= nPrdE4 + TRB2->ICMSUN
		nPrdE5 		:= nPrdE5 + TRB2->BSICMST
		nPrdE6  	:= nPrdE6 + TRB2->ICMSTUN
		nPrdE7     	:= nPrdE7 + TRB2->ICMSTO
		nPrdE8   	:= nPrdE8 + TRB2->ICMSTTO
		
		//����������������������������Ŀ
		//�Totalizador geral - entradas�
		//������������������������������
		nTotE1 		:= nTotE1 + TRB2->QTD
		nTotE2 		:= nTotE2 + TRB2->VLRUNIT
		nTotE3 		:= nTotE3 + TRB2->BSICM	
		nTotE4 		:= nTotE4 + TRB2->ICMSUN
		nTotE5 		:= nTotE5 + TRB2->BSICMST		
		nTotE6   	:= nTotE6 + TRB2->ICMSTUN
		nTotE7     	:= nTotE7 + TRB2->ICMSTO
		nTotE8   	:= nTotE8 + TRB2->ICMSTTO
	Else
		//����������������������������������Ŀ
		//�Totalizador por produto - Saidas  �
		//������������������������������������
		nPrdS1 		:= nPrdS1 + TRB2->QTD
		nPrdS2 		:= nPrdS2 + TRB2->VLRUNIT
		nPrdS3 		:= nPrdS3 + TRB2->BSICM
		nPrdS4 		:= nPrdS4 + TRB2->ICMSUN
		nPrdS5 		:= nPrdS5 + TRB2->BSICMST
		nPrdS6  	:= nPrdS6 + TRB2->ICMSTUN
		nPrdS7     	:= nPrdS7 + TRB2->ICMSTO
		nPrdS8   	:= nPrdS8 + TRB2->ICMSTTO
		
		//��������������������������Ŀ
		//�Totalizador geral - Saidas�
		//����������������������������
		nTotS1 		:= nTotS1 + TRB2->QTD
		nTotS2 		:= nTotS2 + TRB2->VLRUNIT
		nTotS3 		:= nTotS3 + TRB2->BSICM	
		nTotS4 		:= nTotS4 + TRB2->ICMSUN
		nTotS5 		:= nTotS5 + TRB2->BSICMST		
		nTotS6   	:= nTotS6 + TRB2->ICMSTUN
		nTotS7     	:= nTotS7 + TRB2->ICMSTO
		nTotS8   	:= nTotS8 + TRB2->ICMSTTO
	EndIf
	TRB2->(DbSkip())
	
	//�������������������������������Ŀ
	//�Imprime totalizador por produto�
	//���������������������������������
	If TRB2->PRODUTO <> cKey .or. TRB2->(Eof())
		nLin ++
		nLin ++
		@ nLin, 000 Psay STR0008 + Transform(nPrdE1,"@E 99999999.99")+' '+Transform(nPrdE2,"@E 999,999,999.99")+' '+Transform(nPrdE3,"@E 999,999,999.99")+' '+Transform(nPrdE4,"@E 999,999,999.99")+' '+Transform(nPrdE5,"@E 999,999,999.99")+' '+Transform(nPrdE6,"@e 999,999,999.99")+' '+Transform(nPrdE7,"@E 999,999,999.99")+' '+Transform(nPrdE8,"@e 999,999,999.99")
		nLin ++
		@ nLin, 000 Psay STR0009 + Transform(nPrdS1,"@E 99999999.99")+' '+Transform(nPrdS2,"@E 999,999,999.99")+' '+Transform(nPrdS3,"@E 999,999,999.99")+' '+Transform(nPrdS4,"@E 999,999,999.99")+' '+Transform(nPrdS5,"@E 999,999,999.99")+' '+Transform(nPrdS6,"@e 999,999,999.99")+' '+Transform(nPrdS7,"@E 999,999,999.99")+' '+Transform(nPrdS8,"@e 999,999,999.99")
		nLin ++
		@ nLin, 000 Psay STR0014
		nLin ++
		nLin ++             
		
		lProd       := .F.
		
		nPrdE1 		:= 0
		nPrdE2 		:= 0
		nPrdE3 		:= 0
		nPrdE4 		:= 0
		nPrdE5 		:= 0
		nPrdE6  	:= 0
		nPrdE7     	:= 0
		nPrdE8   	:= 0
		
		nPrdS1 		:= 0
		nPrdS2 		:= 0
		nPrdS3 		:= 0
		nPrdS4 		:= 0
		nPrdS5 		:= 0
		nPrdS6  	:= 0
		nPrdS7     	:= 0
		nPrdS8   	:= 0
		
		cKey := TRB2->PRODUTO
	EndIf
EndDo

nLin ++
nLin ++
@ nLin, 000 PSay STR0012+ Transform(nTotE1,"@E 99999999.99")+' '+Transform(nTotE2,"@E 999,999,999.99")+' '+Transform(nTotE3,"@E 999,999,999.99")+' '+Transform(nTotE4,"@E 999,999,999.99")+' '+Transform(nTotE5,"@E 999,999,999.99")+' '+Transform(nTotE6,"@e 999,999,999.99")+' '+Transform(nTotE7,"@e 999,999,999.99")+' '+Transform(nTotE8,"@e 999,999,999.99")
nLin ++
@ nLin, 000 PSay STR0013+ Transform(nTotS1,"@E 99999999.99")+' '+Transform(nTotS2,"@E 999,999,999.99")+' '+Transform(nTotS3,"@E 999,999,999.99")+' '+Transform(nTotS4,"@E 999,999,999.99")+' '+Transform(nTotS5,"@E 999,999,999.99")+' '+Transform(nTotS6,"@e 999,999,999.99")+' '+Transform(nTotS7,"@e 999,999,999.99")+' '+Transform(nTotS8,"@e 999,999,999.99")

SET DEVICE TO SCREEN

If aReturn[5]==1
   dbCommitAll()
   SET PRINTER TO
   OurSpool(wnrel)
Endif

MS_FLUSH()

TRB2->(DbSelectArea("TRB2"))
TRB2->(DbCloseArea())
Return()

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MontTrab  �Autor  �Juliana Taveira     � Data �  16/06/10   ���
�������������������������������������������������������������������������͹��
���Desc.     � Monta tabela temporaria 							          ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function MontTrab()
Local aDbf := {}
Local nTamPrd := TamSx3("B1_COD")[1]                                              

//�������������������������
//�Monta tabela temporaria�
//�������������������������
aAdd( aDbf, { "PRODUTO"   ,"C"  ,nTamPrd,0 } )
aAdd( aDbf, { "DESCRICAO" ,"C"  ,30,0 } )
aAdd( aDbf, { "EMISSAO"   ,"C"  ,10,0 } )
aAdd( aDbf, { "CLIFOR"    ,"C"  ,30,0 } )
aAdd( aDbf, { "UF"        ,"C"  ,02,0 } )
aAdd( aDbf, { "NUMERO"    ,"C"  ,09,0 } )
aAdd( aDbf, { "SERIE"     ,"C"  ,03,0 } )
aAdd( aDbf, { "QTD"       ,"N"  ,11,2 } )    
aAdd( aDbf, { "VLRUNIT"   ,"N"  ,14,2 } )     
aAdd( aDbf, { "BSICM"     ,"N"  ,14,2 } )     
aAdd( aDbf, { "ICMSUN"    ,"N"  ,14,2 } )     
aAdd( aDbf, { "BSICMST"   ,"N"  ,14,2 } )     
aAdd( aDbf, { "ICMSTUN"   ,"N"  ,14,2 } )    
aAdd( aDbf, { "ICMSTO"    ,"N"  ,14,2 } )    
aAdd( aDbf, { "ICMSTTO"   ,"N"  ,14,2 } )     
aAdd( aDbf, { "TIPO"      ,"C"  ,01,0 } ) 
AAdd( aDbf, { "MOTIVO"    ,"C"  ,25,0 } ) 

TRB2 := CriaTrab( aDbf, .t. )
dbUseArea(.T.,,TRB2,"TRB2",.F.,.F.)
dbSelectArea('TRB2')
cKey   := "PRODUTO + TIPO"
cCond  := ""
cIndex := CriaTrab(NIL,.F.)
IndRegua( "TRB2" ,cIndex ,cKey ,,cCond ,"Indexando Arq.Temporario")
Return()                                                       

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �BscEntr   �Autor  �Juliana Taveira     � Data �  16/06/10   ���
�������������������������������������������������������������������������͹��
���Desc.     � Busca notas fiscais de entrada                             ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function BscEntr(cCfoNEnt)
Local cDesc 	:=	""
Local cCliFor   :=	""                     
Local cUf       := 	""
Local cAliasSD1 :=	"SD1"
Local cFiltro	:=	""
Local cIndex    :=	""
Local nIndex 	:=	0

DbSelectArea("SD1") 
SD1->(DbSetOrder(1)) 

#IFDEF TOP
If (TcSrvType ()<>"AS/400")
 	cAliasSD1	:=	GetNextAlias()	
 	
 	cFiltro := "%"
	If !Empty(MV_PAR05) .and. !Empty(MV_PAR06)
		cFiltro += " SD1.D1_COD >= '" +%Exp:(MV_PAR05)% +"' AND SD1.D1_COD <= '" +%Exp:(MV_PAR06)% +"' AND "
	EndIf                    
	cFiltro += "%"
	
   	BeginSql Alias cAliasSD1    	
		SELECT *
		FROM %Table:SD1% SD1 
		JOIN %table:SF1% SF1 ON SF1.F1_FILIAL = %xFilial:SF1%
			AND SF1.F1_DOC = SD1.D1_DOC
			AND SF1.F1_SERIE = SD1.D1_SERIE
			AND SF1.F1_FORNECE = SD1.D1_FORNECE 
			AND SF1.F1_LOJA = SD1.D1_LOJA
			AND SF1.F1_TIPO = SD1.D1_TIPO								
			AND SF1.%NotDel%       		  
		WHERE 
			SD1.D1_FILIAL = %xFilial:SD1% AND 
			SD1.D1_DTDIGIT >= %Exp:DToS (MV_PAR01)% AND
			SD1.D1_DTDIGIT <= %Exp:DToS (MV_PAR02)% AND
			(SD1.D1_CF NOT LIKE '000%' AND SD1.D1_CF NOT LIKE '999%') AND
		    SD1.D1_TIPO NOT IN ('I','P','C') AND SD1.D1_BRICMS > 0 AND
		    %Exp:cFiltro%
			SD1.%NotDel%  
		ORDER BY SD1.D1_COD, SD1.D1_DTDIGIT 					             
	EndSql 
Else
	#ENDIF
	cIndex	:= CriaTrab(NIL,.F.)
	cFiltro	:= 'D1_FILIAL=="'+xFilial("SD1")+" .AND. '  
	cFiltro	+= 'DTOS(D1_DTDIGIT) >= "'+Dtos(MV_PAR01)+" .AND. ' 
	cFiltro	+= 'DTOS(D1_DTDIGIT) <= "'+Dtos(MV_PAR02)+" .AND. ' 
	cFiltro += '!Substr(D1_CF,1,3)$"999/000" .AND. '
	cFiltro += '!D1_TIPO $ "IPC" .AND. D1_BRICMS > 0 .AND. '
	If !Empty(MV_PAR05) .and. !Empty(MV_PAR06)
		cFiltro += 'D1_COD >= "'+MV_PAR05+'" AND D1_COD <= "'+MV_PAR06+'" .AND. '
	EndIf                    
	
	IndRegua (cAliasSD1, cIndex, SD1->(IndexKey ()),, cFiltro)
	nIndex := RetIndex(cAliasSD1)
	#IFNDEF TOP
		DbSetIndex (cIndex+OrdBagExt ())
	#ENDIF			
	DbSelectArea (cAliasSD1)
	DbSetOrder (nIndex)
	#IFDEF TOP
Endif
#ENDIF
	
DbSelectArea (cAliasSD1)
(cAliasSD1)->(DbGoTop())
ProcRegua ((cAliasSD1)->(RecCount ()))
While !(cAliasSD1)->(Eof ())
	cDesc 	:= ""	
	cCliFor := ""
	//Busca dados do produto
	DbSelectArea("SB1")
	SB1->(DbSetOrder(1))
	If SB1->(DbSeek(xFilial("SB1")+avKey((cAliasSD1)->D1_COD,"B1_COD")))
		cDesc := Alltrim(SB1->B1_DESC)
	EndIf
	
	//Busca dados do cliente/fornecedor
	If !(cAliasSD1)->D1_TIPO$"BD"
		DbSelectArea("SA2")
		SA2->(DbSetOrder(1))
		If SA2->(DbSeek(xFilial("SA2")+avKey((cAliasSD1)->D1_FORNECE,"A2_COD")+avKey((cAliasSD1)->D1_LOJA,"A2_LOJA")))
			cCliFor := Alltrim(SA2->A2_CGC)+"-"+Substr(SA2->A2_NREDUZ,1,16)
			cUf     := Alltrim(SA2->A2_EST)
		EndIf
	else
		DbSelectArea("SA1")
		SA1->(DbSetOrder(1))
		If SA1->(DbSeek(xFilial("SA1")+avKey((cAliasSD1)->D1_FORNECE,"A1_COD")+avKey((cAliasSD1)->D1_LOJA,"A1_LOJA")))
			cCliFor := Alltrim(SA1->A1_CGC)+"-"+Substr(SA1->A1_NREDUZ,1,16)
			cUf     := Alltrim(SA1->A1_EST)
		EndIf
	EndIf
	
	//���������������������������������������������������������������
	//�Incluir na tabela temporaria as notas fiscais de entrada que �
	//�possui icms st e que a cfop nao esta no parametro            �
	//�MV_CFDEMST, que indica as cfops que nao devem ser            �
	//�consideradas no demonstrativo.                               �
	//���������������������������������������������������������������
	If!Alltrim((cAliasSD1)->D1_CF)$ cCfoNEnt
		DbSelectArea("TRB2")
		Reclock("TRB2",.T.)
		TRB2->PRODUTO 	:= (cAliasSD1)->D1_COD
		TRB2->DESCRICAO	:= Alltrim(cDesc)
		TRB2->EMISSAO  	:= Substr((cAliasSD1)->D1_EMISSAO,7,2)+"/"+Substr((cAliasSD1)->D1_EMISSAO,5,2)+"/"+Substr((cAliasSD1)->D1_EMISSAO,1,4)
		TRB2->CLIFOR   	:= Alltrim(cCliFor)
		TRB2->UF        := Alltrim(cUf)
		TRB2->NUMERO    := (cAliasSD1)->D1_DOC
		TRB2->SERIE     := (cAliasSD1)->D1_SERIE
		TRB2->QTD       := (cAliasSD1)->D1_QUANT
		TRB2->VLRUNIT   := (cAliasSD1)->D1_VUNIT
		TRB2->BSICM     := (cAliasSD1)->D1_BASEICM
		TRB2->ICMSUN    := (cAliasSD1)->D1_VALICM
		TRB2->BSICMST   := (cAliasSD1)->D1_BRICMS
		TRB2->ICMSTUN   := (cAliasSD1)->D1_ICMSRET
		TRB2->ICMSTO    := (cAliasSD1)->F1_VALICM
		TRB2->ICMSTTO   := (cAliasSD1)->F1_ICMSRET
		TRB2->TIPO      := "E"           
		TRB2->(MsUnLock())
	EndIf
	(cAliasSD1)->(DbSkip())
EndDo
Return()

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �BscSda  	�Autor  �Juliana Taveira     � Data �  16/06/10   ���
�������������������������������������������������������������������������͹��
���Desc.     � Busca notas fiscais de saida                               ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function BscSda(cSdInt,cSdPer)
Local cDesc 	:=	""
Local cCliFor   :=	""
Local cUf       := 	""                     
Local cAliasSD2 :=	"SD2"
Local cFiltro	:=	""
Local cIndex    :=	""
Local nIndex 	:=	0
Local lNContr   := .F. 
Local lPermite  := .F.
Local lUsaSFT	:= AliasIndic("SFT")

If lUsaSFT
	SFT->(DbSelectArea("SFT")) 
	SFT->(dbSetOrder(1))
Endif

DbSelectArea("SD2")     
SD1->(DbSetOrder(1)) 

#IFDEF TOP
If (TcSrvType ()<>"AS/400")
 	cAliasSD2	:=	GetNextAlias()	
 	
 	cFiltro := "%"
	If !Empty(MV_PAR05) .and. !Empty(MV_PAR06)
		cFiltro += " SD2.D2_COD >= '" +%Exp:(MV_PAR05)% +"' AND SD2.D2_COD <= '" +%Exp:(MV_PAR06)% +"' AND "
	EndIf                    
	cFiltro += "%"

   	BeginSql Alias cAliasSD2    	
		SELECT *
		FROM %Table:SD2% SD2 
		JOIN %table:SF2% SF2 ON SF2.F2_FILIAL = %xFilial:SF2%
					AND SF2.F2_DOC = SD2.D2_DOC
					AND SF2.F2_SERIE = SD2.D2_SERIE
					AND SF2.F2_CLIENTE = SD2.D2_CLIENTE 
					AND SF2.F2_LOJA = SD2.D2_LOJA							
					AND SF2.%NotDel%       		  																				
		WHERE 
			SD2.D2_FILIAL = %xFilial:SD2% AND 
			SD2.D2_EMISSAO >= %Exp:DToS (MV_PAR01)% AND
			SD2.D2_EMISSAO <= %Exp:DToS (MV_PAR02)% AND
			(SD2.D2_CF NOT LIKE '000%' AND SD2.D2_CF NOT LIKE '999%') AND
		    SD2.D2_TIPO NOT IN ('I','P','C') AND //SD2.D2_BRICMS > 0 AND
		    %Exp:cFiltro%
			SD2.%NotDel%
		ORDER BY SD2.D2_COD, SD2.D2_EMISSAO					               
	EndSql 
Else
	#ENDIF
	cIndex	:= CriaTrab(NIL,.F.)
	cFiltro	:= 'D2_FILIAL=="'+xFilial("SD2")+" .AND. '  
	cFiltro	+= 'DTOS(D2_EMISSAO) >= "'+Dtos(MV_PAR01)+" .AND. ' 
	cFiltro	+= 'DTOS(D2_EMISSAO) <= "'+Dtos(MV_PAR02)+" .AND. ' 
	cFiltro += '!Substr(D2_CF,1,3)$"999/000" .AND. '
	cFiltro += '!D2_TIPO $ "IPC" .AND. '//D2_BRICMS > 0 .AND. '
	If !Empty(MV_PAR05) .and. !Empty(MV_PAR06)
		cFiltro += 'D2_COD >= "' +MV_PAR05+'" AND D2_COD <= "'+MV_PAR06+'" AND '
	EndIf                    
	
	IndRegua (cAliasSD2, cIndex, SD2->(IndexKey ()),, cFiltro)
	nIndex := RetIndex(cAliasSD2)
	#IFNDEF TOP
		DbSetIndex (cIndex+OrdBagExt ())
	#ENDIF			
	DbSelectArea (cAliasSD2)
	DbSetOrder (nIndex)
	#IFDEF TOP
Endif
#ENDIF
	
DbSelectArea (cAliasSD2)
(cAliasSD2)->(DbGoTop())
ProcRegua ((cAliasSD2)->(RecCount ()))
While !(cAliasSD2)->(Eof ())
	cDesc 	:= ""
	cCliFor := ""
	//Busca dados do produto
	DbSelectArea("SB1")
	SB1->(DbSetOrder(1))
	If SB1->(DbSeek(xFilial("SB1")+avKey((cAliasSD2)->D2_COD,"B1_COD")))
		cDesc := Alltrim(SB1->B1_DESC)
	EndIf
	//Busca dados do cliente/fornecedor
	If (cAliasSD2)->D2_TIPO$"BD"
		DbSelectArea("SA2")
		SA2->(DbSetOrder(1))
		If SA2->(DbSeek(xFilial("SA2")+avKey((cAliasSD2)->D2_CLIENTE,"A2_COD")+avKey((cAliasSD2)->D2_LOJA,"A2_LOJA")))
			cCliFor := Alltrim(SA2->A2_CGC)+"-"+Substr(SA2->A2_NREDUZ,1,16)
			cUf     := Alltrim(SA2->A2_EST)
			// Nao contribuinte do ICMS
			lNContr := IIf(Empty(SM0->M0_INSC).OR."ISENT"$SM0->M0_INSC,.T.,.F.)
		EndIf
	else
		DbSelectArea("SA1")
		SA1->(DbSetOrder(1))
		If SA1->(DbSeek(xFilial("SA1")+avKey((cAliasSD2)->D2_CLIENTE,"A1_COD")+avKey((cAliasSD2)->D2_LOJA,"A1_LOJA")))
			cCliFor := Alltrim(SA1->A1_CGC)+"-"+Substr(SA1->A1_NREDUZ,1,16)
			cUf     := Alltrim(SA1->A1_EST)
			// Nao contribuinte do ICMS
			lNContr := IIf(Empty(SA1->A1_INSCR).Or."ISENT"$SA1->A1_INSCR.Or."RG"$SA1->A1_INSCR,.T.,.F.)
		EndIf
	EndIf    
	               
	lPermite := .F.
	cMot := ""
	//�������������������������������������������������������������������������Ŀ
	//�CONDICAO 1 PARA DIREITO AO RESSARCIMENTO                                 �
	//�Saidas interestaduais                                                    �
	//�Apenas para contribuintes                                                �
	//�CFOP nao contido no parametro MV_N88INT  (que indica os CFOPs que nao dao�
	//�direito ao credito nas operacoes interestaduais)                         �
	//���������������������������������������������������������������������������
	If SubStr((cAliasSD2)->D2_CF,1,1) == "6" .And. !lNContr .And. !(Alltrim((cAliasSD2)->D2_CF) $ cSdInt)
	    cMot := "interestadual"
		lPermite := .T.
		//�����������������������������������������������������������������Ŀ
		//�CONDICAO 2 PARA DIREITO AO RESSARCIMENTO                         �
		//�Saidas por perda, roubo, perecimento e etc devem ser consideradas�
		//�������������������������������������������������������������������
	ElseIf Alltrim((cAliasSD2)->D2_CF) $ cSdPer
		cMot := "perda/roubo/parecimento"
		lPermite := .T.
		//�������������������������������������������������������������������Ŀ
		//�CONDICAO 3 PARA DIREITO AO RESSARCIMENTO                           �
		//�Saidas isentas ou com nao incidencia de ICMS devem ser consideradas�
		//�Somente quando o item for 100% isento                              �
		//���������������������������������������������������������������������
	ElseIf !(Alltrim((cAliasSD2)->D2_CF) $ cSdInt) .And. ;
		lUsaSFT .And. ;
		SFT->(dbSeek(xFilial("SFT")+"S"+(cAliasSD2)->D2_SERIE+(cAliasSD2)->D2_DOC+(cAliasSD2)->D2_CLIENTE+(cAliasSD2)->D2_LOJA+(cAliasSD2)->D2_ITEM+(cAliasSD2)->D2_COD)) .And. ;
		SFT->FT_ISENICM > 0 .And. SFT->FT_BASEICM == 0 .And. SFT->FT_OUTRICM == 0
		cMot := "isencao/nao-incidencia"
		lPermite := .T.
	Endif
	
	If lPermite
		DbSelectArea("TRB2")
		If TRB2->(DbSeek((cAliasSD2)->D2_COD+"E"))
			Reclock("TRB2",.T.)
			TRB2->PRODUTO 	:= (cAliasSD2)->D2_COD
			TRB2->DESCRICAO	:= Alltrim(cDesc)
			TRB2->EMISSAO  	:= Substr((cAliasSD2)->D2_EMISSAO,7,2)+"/"+Substr((cAliasSD2)->D2_EMISSAO,5,2)+"/"+Substr((cAliasSD2)->D2_EMISSAO,1,4)
			TRB2->CLIFOR   	:= Alltrim(cCliFor)
			TRB2->UF        := Alltrim(cUf)
			TRB2->NUMERO    := (cAliasSD2)->D2_DOC
			TRB2->SERIE     := (cAliasSD2)->D2_SERIE
			TRB2->QTD       := (cAliasSD2)->D2_QUANT
			TRB2->VLRUNIT   := (cAliasSD2)->D2_PRCVEN
			TRB2->BSICM	    := (cAliasSD2)->D2_BASEICM			
			TRB2->ICMSUN    := (cAliasSD2)->D2_VALICM
			TRB2->BSICMST   := (cAliasSD2)->D2_BRICMS
			TRB2->ICMSTUN   := (cAliasSD2)->D2_ICMSRET
			TRB2->ICMSTO    := (cAliasSD2)->F2_VALICM
			TRB2->ICMSTTO   := (cAliasSD2)->F2_ICMSRET
			TRB2->TIPO      := "S"
			TRB2->MOTIVO    := Alltrim(cMot)	
			TRB2->(MsUnLock())
		EndIf
	EndIf
	(cAliasSD2)->(DbSkip())
EndDo
Return()
