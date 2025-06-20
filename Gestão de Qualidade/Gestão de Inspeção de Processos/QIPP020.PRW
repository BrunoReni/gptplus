#include "PROTHEUS.CH" 
#include "MSGRAPHI.CH"
#include "QIPP020.CH"

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    � QIPP020  � Autor � Cicero Odilio Cruz    � Data � 26.03.07  ���
��������������������������������������������������������������������������Ĵ��
���Descri��o � Painel de Gestao - N�mero de N�o-Conformidades x Produtos   ���
��������������������������������������������������������������������������Ĵ��
���Parametros�                 											   ���
��������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAQIE                                                     ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Function QIPP020()

Local aRetPanel := {} //Array com os dados que ser�o exibidos no painel
Local aDados    := {} 
Local nCnt

Private aDados1   := {}
Private nTot 	  := 0
Private cAtu      := ''

dbSelectArea("QEE")  
dbSelectArea("SB1")

/*
�������������������������������������������Ŀ
� Estrutura do Array aDados:         		�
� aDados[1] - Fornecedor					�	
� aDados[2] - Loja		          			�
� aDados[3] - Produto          				�
� aDados[4] - Data Entrada     				�
� aDados[5] - Lote	          				�
� aDados[6] - Classe da N�o-Conformidade	�
� aDados[7] - Numero de N�o-Conformidades	�
���������������������������������������������

�������������������������������������������Ŀ
� Estrutura do Array aDados:         		�
� aDados[1] - Produto		    			�	
� aDados[2] - Data Producao       			�
� aDados[3] - Lote	          				�
� aDados[4] - Classe da N�o-Conformidade	�
� aDados[5] - Numero de N�o-Conformidades	�
���������������������������������������������
*/
aDados := aClone(QIPGerQry())

// Dimens�o Classe de N�o-Conformidade
aDados := aSort(aDados,,,{|x,y|x[4]<y[4]})
Aeval(aDados,;
	{|x| Iif(cAtu <> x[4],;
		     Iif(Empty(AllTrim(cAtu)),;
			     {nTot+=x[5],cAtu:=x[4]},;
			     {Aadd(aDados1,{cAtu,nTot}),nTot:=0,nTot+=x[5],cAtu:=x[4]}),;
			 {nTot+=x[5],cAtu:=x[4]})})
If Len(aDados) >= 1
	Aadd(aDados1,{cAtu,nTot})
EndIf

If Len(aDados1) > 0
	aAdd(aRetPanel,{STR0001,{}}) // "Classe N�o-Conformidade"
	For nCnt := 1 To Len(aDados1)
		aAdd(aRetPanel[1][2],{Posicione("QEE",1,xFilial('QEE')+aDados1[nCnt][1],"QEE_DESCPO"),Transform(aDados1[nCnt][2],"@E 99999"),CLR_GREEN,Nil})	
	Next nCnt           
Else	
	aAdd(aRetPanel,{STR0001,{}}) // "Classe N�o-Conformidade"
	aAdd(aRetPanel[1][2],{STR0003,Transform("0","@E 99999"),CLR_GREEN,Nil}) //"Nao h� dados na dimens�o"  
EndIf

// Dimens�o por Produto
aDados1   := {}
nTot 	  := 0
cAtu      := ''
aDados := aSort(aDados,,,{|x,y|x[1]<y[1]})
Aeval(aDados,;
	{|x| Iif(cAtu <> x[1],;
		     Iif(Empty(AllTrim(cAtu)),;
			     {nTot+=x[5],cAtu:=x[1]},;
			     {Aadd(aDados1,{cAtu,nTot}),nTot:=0,nTot+=x[5],cAtu:=x[1]}),;
			 {nTot+=x[5],cAtu:=x[1]})})
If Len(aDados) >= 1
	Aadd(aDados1,{cAtu,nTot})
EndIf

If Len(aDados1) > 0
	aAdd(aRetPanel,{STR0002,{}}) // "Produto"
	For nCnt := 1 To Len(aDados1)
		aAdd(aRetPanel[2][2],{Posicione("SB1",1,xFilial('SB1')+aDados1[nCnt][1],"B1_DESC"),Transform(aDados1[nCnt][2],"@E 99999"),CLR_GREEN,Nil})	
	Next nCnt           
Else	
	aAdd(aRetPanel,{STR0002,{}}) // "Produto"
	aAdd(aRetPanel[2][2],{STR0003,Transform("0","@E 99999"),CLR_GREEN,Nil}) //"Nao h� dados na dimens�o"  
EndIf


Return aRetPanel

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �QIEGerQry � Autor � Cicero Odilio Cruz    � Data �06.03.07  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Gera a Query que sera exibida pelo Painel de Gestao        ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                 											  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAQIP                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function QIPGerQry()
Local cAliasQry := GetNextAlias()
Local cStatus   := ""
Local cPerg 	:= "QIP020"
Local cWhere    := ""
Local aDados 	:= {}
 
Pergunte(cPerg,.F.)   

cWhere    :='% '

If !Empty(AllTrim(MV_PAR01)) .AND. Iif(At(";",MV_PAR01)>0,.T.,Iif(At("-",MV_PAR01)>0,.T.,.F.))
	cWhereAux := QA_Range(MV_PAR01, "QPK_CLIENT", "QPK")
	cWhere    += " ("+ cWhereAux + ") AND "
ElseIf !Empty(AllTrim(MV_PAR01)) //se comporta sem range
	cWhere    += " QPK_CLIENT = '"+ PadL(AllTrim(MV_PAR01),GetSx3Cache("QPK_CLIENT","X3_TAMANHO")) + "' AND "
EndIf   

If !Empty(AllTrim(MV_PAR02)) .AND. Iif(At(";",MV_PAR02)>0,.T.,Iif(At("-",MV_PAR02)>0,.T.,.F.))
	cWhereAux := QA_Range(MV_PAR02, "QPR_PRODUT", "QPR")
	cWhere    += " ("+ cWhereAux + ") AND "
ElseIf !Empty(AllTrim(MV_PAR02)) //se comporta sem range
	cWhere    += " QPR_PRODUT = '"+ PadL(AllTrim(MV_PAR02),GetSx3Cache("QPR_PRODUT","X3_TAMANHO")) + "' AND "
EndIf   

cWhere    +=' %'

//Selecionando as tabelas para garantir
//que elas existam antes da execucao da query
dbSelectArea("QPU")
dbSelectArea("QPR")
dbSelectArea("QPK")

BeginSql Alias cAliasQry
 
	SELECT QPK.QPK_PRODUT, QPK.QPK_DTPROD, QPK.QPK_LOTE, QPU.QPU_CLASSE, SUM(QPU_NUMNC)	NONNC					
	FROM   %table:QPK% QPK, %table:QPR% QPR, %table:QPU% QPU
	WHERE  QPK.QPK_FILIAL = %xFilial:QPK%   AND 
		   QPR.QPR_FILIAL = %xFilial:QPR%   AND 
		   QPU.QPU_FILIAL = %xFilial:QPU%   AND 
		   QPU.QPU_CODMED = QPR.QPR_CHAVE   AND 
		   QPR.QPR_PRODUT = QPK.QPK_PRODUT	AND 
		   QPR.QPR_REVI   = QPK.QPK_REVI	AND 
		   QPR.QPR_LOTE   = QPK.QPK_LOTE	AND 
		   %Exp:cWhere%
		   QPK.QPK_DTPROD BETWEEN %exp:Dtos(mv_par03)% and %exp:Dtos(mv_par04)% AND
		   QPK.%notDel% AND
		   QPR.%notDel% AND
		   QPU.%notDel%
	GROUP BY QPK.QPK_PRODUT, QPK.QPK_DTPROD, QPK.QPK_LOTE, QPU.QPU_CLASSE	

EndSql

dbSelectArea(cAliasQry)
If !(cAliasQry)->(Eof())
	While !(cAliasQry)->(Eof())
		aAdd(aDados,{&(cAliasQry+"->QPK_PRODUT"),&(cAliasQry+"->QPK_DTPROD"),&(cAliasQry+"->QPK_LOTE"),&(cAliasQry+"->QPU_CLASSE"),&(cAliasQry+"->NONNC")})
		(cAliasQry)->(DbSkip())
	EndDo
EndIf

(cAliasQry)->(DbCloseArea())

Return aDados
