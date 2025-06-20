#INCLUDE "plsa365bax.ch"

#include "PROTHEUS.CH"
#include "PLSMGER.CH"

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� As funcoes abaixo sao utilizadas no browse de U.S no cadastro de Especialidade  |
//� Sao chamadas na validacao e exclusao de uma linha do Browse oGet07              |
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�


/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑uncao    � PLSBAXVLD  � Autor � Michele Tatagiba    � Data � 20.08.02 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escricao � Valida uma acao no browse de Local de Atendimento          낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
Function PLSBAXVld()
LOCAL lRet  	 := .T.
LOCAL aSubEspAlt := {}
LOCAL nScan 	 := 0
LOCAL lAlterar 	 := .T.
LOCAL i	 		 := 0
/*
LOCAL nBaxPosInd	:=PLRETPOS("BAX_CODINT",oGet03:aHeader)
LOCAL nBaxPosEsp	:=PLRETPOS("BAX_CODESP",oGet03:aHeader) 
LOCAL nBc0PosInd	:=PLRETPOS("BC0_CODINT",oGet06:aHeader)  
LOCAL nBc0PosEsp	:=PLRETPOS("BC0_CODESP",oGet06:aHeader)
LOCAL nBc0PosSub	:=PLRETPOS("BC0_CODSUB",oGet06:aHeader)

If !Empty(M->BAX_CODSUB) // Verifica se foi digitado a sub-especialidades
	For i:=1 to Len(oGet06:ACOLS)
	    If oGet06:ACOLS[i,nBc0PosInd]+oGet06:ACOLS[i,nBc0PosEsp]==oGet03:ACOLS[oGet03:OBROWSE:NAT,nBaxPosInd]+oGet03:ACOLS[oGet03:OBROWSE:NAT,nBaxPosEsp]
		    oGet06:ACOLS[i,nBc0PosSub]:=M->BAX_CODSUB
	    Endif
	Next i
	cCodSub:=M->BAX_CODSUB               
	oGet06:ForceRefresh()
Endif
*/
// retorna o array aSubEspAlt (PLSA365)
aSubEspAlt := PLSGetSubE()
M->BAX_CODIGO := ccodigo
BAX->(dbSetOrder(1))
BAX->(dbSeek(xFilial("BAX")+BAU->BAU_CODIGO+M->BAX_CODINT+M->BAX_CODLOC+M->BAX_CODESP)) // BAX_FILIAL+BAX_CODIGO+BAX_CODINT+BAX_CODLOC+BAX_CODESP
// verifica se a BAX atual j� foi inserida no array
nScan := aScan(aSubEspAlt, { |X| X[2] == BAX->BAX_CODIGO+BAX->BAX_CODINT+BAX->BAX_CODLOC+M->BAX_CODESP})
// se a subespecialidade setada � igual a do banco de dados, n�o � necessario alteracao
if(BAX->BAX_CODSUB == M->BAX_CODSUB)
	lAlterar := .F.
else
	lAlterar := .T.
endif

// se a BAX j� foi inserida, apenas alteramos os valores no array, caso contrario, adicionamos um novo indice para a nova BAX
if (nScan > 0)
	aSubEspAlt[nScan][1] := M->BAX_CODSUB
	aSubEspAlt[nScan][3] := lAlterar
else
	aadd(aSubEspAlt, {M->BAX_CODSUB, BAX->BAX_CODIGO+BAX->BAX_CODINT+BAX->BAX_CODLOC+M->BAX_CODESP, lAlterar})
endif

// seta os novos valores no array aSubEspAlt
PLSSetSubE(aSubEspAlt)

lRet := PLSVLDCOL({"BAX_CODESP","BAX_CODSUB"}) 

Return(lRet)

/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑uncao    � PLSBAXDel  � Autor � Michele Tatagiba    � Data � 22.08.02 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escricao � Valida a exclusao de uma linha no browse de Especialidade  낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
Function PLSBAXDel()                                   

LOCAL nPosScan
LOCAL nTamCols := 1

nPosScan := aScan(aVetBNO,{|x| x[1] == cCodigo .And. x[2] == cCodInt .And.;
            x[3] == oGet07:aCols[oGet07:Linha(),oGet07:PlRetPos("BAX_CODLOC")] .And.;
            x[4] == oGet07:aCols[oGet07:Linha(),oGet07:PlRetPos("BAX_LOCAL")]})
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Se for exclusao da linha, tiro o dado do vetor                    |
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�      
If oGet07:aCols[oGet07:Linha(),Len(oGet07:aHeader)+1]
   If nPosScan <> 0
      aadd(aVetDelBNO,aVetBNO[nPosScan])
      nTamCols   := Len(aVetBNO)
      aDel(aVetBNO,nPosScan)
      aSize(aVetBNO,nTamCols-1)
   Endif
Else
   //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
   //� Se for retirar a exclusao, tenho que verificar se os dados daquele linha estavam no vetor   |
   //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
   nPosScan := aScan(aVetDelBNO,{|x| x[1] == cCodigo .And. x[2] == cCodInt .And.;
                x[3] == oGet07:aCols[oGet07:Linha(),oGet07:PlRetPos("BAX_CODLOC")] .And.;
                x[4] == oGet07:aCols[oGet07:Linha(),oGet07:PlRetPos("BAX_LOCAL")]})
   If nPosScan <> 0
      aadd(aVetBNO,{cCodigo,cCodInt,oGet07:aCols[oGet07:Linha(),oGet07:PlRetPos("BAX_CODLOC")],;
                     oGet07:aCols[oGet07:Linha(),oGet07:PlRetPos("BAX_LOCAL")],;
                     oGet07:aCols[oGet07:Linha(),oGet07:PlRetPos("BAX_VALCH")],;
                     oGet07:aCols[oGet07:Linha(),oGet07:PlRetPos("BAX_FORMUL")],;
                     oGet07:aCols[oGet07:Linha(),oGet07:PlRetPos("BAX_EXPRES")],;
                     "",;
                     oGet07:aCols[oGet07:Linha(),oGet07:PlRetPos("BAX_VIGDE")],;
                     ctod("")})
                                                    
      nTamCols   := Len(aVetDelBNO)
      aDel(aVetDelBNO,nPosScan)
      aSize(aVetDelBNO,nTamCols-1)
   Endif
Endif


Return(.T.)

/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑uncao    � PLSBAXWhen � Autor � Michele Tatagiba    � Data � 22.08.02 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escricao � Valida o X3_WHEN para os campos do BAX.                    낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
Function PLSBAXWhen(cTipo)

LOCAL lRet    := .T.
DEFAULT cTipo := ""
/*
If M->BAX_FLAG == "1" .And. Empty(cTipo)
   lRet := .F.
Endif
*/
If lRet .And. cTipo == "1" .And. M->BAX_FORMUL == "2"
   M->BAX_VALCH  := 0
   lRet := .F.
Endif

If lRet .And. cTipo == "2" .And. M->BAX_FORMUL == "1"
   M->BAX_EXPRES := ""
   lRet := .F.
Endif

If lRet .And. cTipo == "N" .And. (!Empty(M->BAX_VALCH) .Or. !Empty(M->BAX_EXPRES))
   lRet := .F.
Endif

Return(lRet)


Function PLSPOSBNO()

LOCAL lRet := .T.

BNO->(DBSetOrder(2))
BNO->(DBSeek(xFilial("BNO")+cCodigo+cCodInt+M->BAX_CODLOC+M->BAX_CODESP+M->BAX_CODSUB))
If M->BAX_VIGDE < BNO->BNO_DATDE
   MsgInfo(STR0001+dtoc(BNO->BNO_DATDE)+STR0002) //"A data de vigencia da US e menor que a data inicial("###") da vigencia anterior."
   lRet := .F.
Endif


Return(lRet)
