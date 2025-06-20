
#include "PROTHEUS.CH"
#include "PLSMGER.CH"


//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� As funcoes abaixo sao utilizadas no browse de Auxiliar da Especialidade.|
//� Sao chamadas na validacao e exclusao de uma linha do Browse oGet43      |
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�


/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑uncao    � PLSBPRVld  � Autor � Michele Tatagiba    � Data � 02.10.02 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escricao � Valida a inclusao de uma linha no browse de Auxiliar da    낢�
굇�          � Especialidade.                                             낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
Function PLSBPRVld()

LOCAL lRet       := .T.
LOCAL lRetBPR    := .T.
LOCAL nPosScan   := 0

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Verifico se o nivel zero e valido                                       |
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
If M->BPR_PERCAX == 0 .And. Empty(M->BPR_NIVVAL)
   MsgInfo("Informe se o nivel zero e valido.")
   Return(.F.)
Endif
          
BNR->(DBSetOrder(2))
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Verifico se existe alguma data de vigencia anterior a essa.             |
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
If BNR->(DBSeek(xFilial("BNR")+cCodigo+M->BPR_CODINT+M->BPR_CODLOC+M->BPR_CODESP+M->BPR_CODSUB+M->BPR_CODTAB+Str(M->BPR_NUMAUX,1)))
   If M->BPR_VIGDE < BNR->BNR_DATDE
      MsgInfo("A data de vigencia do Auxiliar e menor que a ultima data de vigencia "+dtoc(BNR->BNR_DATDE))
      Return(.F.)
   Else
      //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
      //� Caso a data de vigencia seja igual a data de, entao verifico o percentual do auxiliar   |
      //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
      If M->BPR_VIGDE == BNR->BNR_DATDE
         //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
         //� Se o percentual do auxiliar for diferente, nao consigo colocar a data final   |
         //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
         If M->BPR_PERCAX <> BNR->BNR_PERCAX
       	    MsgInfo("A data de vigencia do Auxiliar e igual a data da vigencia anterior.")
       	    Return(.F.)
         Else           
      	    lRet := .T.
         Endif
      Else
         //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
         //� Crio uma nova vigencia de auxiliar                                |
         //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
         nPosScan := aScan(aVetBNR,{|x| x[2] == M->BPR_CODINT .And. x[3] == M->BPR_CODLOC .And.;
                                      x[4] == M->BPR_CODESP .And. x[5] == M->BPR_CODSUB .And.;
                                      x[7] == M->BPR_CODTAB .And. x[8] == M->BPR_NUMAUX })
         If nPosScan == 0
            aadd(aVetBNR,{cCodigo,M->BPR_CODINT,M->BPR_CODLOC,M->BPR_CODESP,M->BPR_CODSUB,M->BPR_CODTAB,M->BPR_NUMAUX,M->BPR_SEQAUX,M->BPR_VIGAUX,M->BPR_PERCAX,M->BPR_NIVVAL,M->BPR_VIGDE,ctod("")})
         Else
            aVetBNR[nPosScan,8]  := M->BPR_SEQAUX
            aVetBNR[nPosScan,9]  := M->BPR_VIGAUX
            aVetBNR[nPosScan,10] := M->BPR_PERCAX
            aVetBNR[nPosScan,11] := M->BPR_NIVVAL
            aVetBNR[nPosScan,12] := M->BPR_VIGDE
         Endif
            
         lRet := .T.
      Endif
   Endif
Else
   //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
   //� Crio uma nova vigencia de auxiliar                                |
   //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
   nPosScan := aScan(aVetBNR,{|x| x[2] == M->BPR_CODINT .And. x[3] == M->BPR_CODLOC .And.;
                                x[4] == M->BPR_CODESP .And. x[5] == M->BPR_CODSUB .And.;
                                x[7] == M->BPR_CODTAB .And. x[8] == M->BPR_NUMAUX })
   If nPosScan == 0
      aadd(aVetBNR,{cCodigo,M->BPR_CODINT,M->BPR_CODLOC,M->BPR_CODESP,M->BPR_CODSUB,M->BPR_CODTAB,M->BPR_NUMAUX,M->BPR_SEQAUX,M->BPR_VIGAUX,M->BPR_PERCAX,M->BPR_NIVVAL,M->BPR_VIGDE,ctod("")})
   Else
      aVetBNR[nPosScan,8]  := M->BPR_SEQAUX
      aVetBNR[nPosScan,9]  := M->BPR_VIGAUX
      aVetBNR[nPosScan,10] := M->BPR_PERCAX
      aVetBNR[nPosScan,11] := M->BPR_NIVVAL
      aVetBNR[nPosScan,12] := M->BPR_VIGDE
   Endif
            
   lRet := .T.
Endif

Return(lRet)


/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑uncao    � PLSBPRDel  � Autor � Michele Tatagiba    � Data � 22.08.02 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escricao � Valida a exclusao de uma linha no browse de Auxliares da   낢�
굇�          � Especialidade.                                             낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
Function PLSBPRDel()

LOCAL nPosScan
LOCAL nTamCols := 1
/*
If M->BPR_FLAG == "1"
   lRet := .F.
Endif
*/
nPosScan := aScan(aVetBNR,{|x| x[1] == cCodigo .And. x[2] == cCodInt .And. x[3] == cCodLoc .And.;
            x[4] == oGet43:aCols[oGet43:Linha(),oGet43:PlRetPos("BPR_CODESP")] .And.;
            x[5] == oGet43:aCols[oGet43:Linha(),oGet43:PlRetPos("BPR_CODSUB")] .And.;
            x[6] == oGet43:aCols[oGet43:Linha(),oGet43:PlRetPos("BPR_CODTAB")] .And.;
            x[7] == oGet43:aCols[oGet43:Linha(),oGet43:PlRetPos("BPR_NUMAUX")]})
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Se for exclusao da linha, tiro o dado do vetor                    |
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�      
If oGet43:aCols[oGet43:Linha(),Len(oGet43:aHeader)+1]
   If nPosScan <> 0
      aadd(aVetDelBNR,aVetBNR[nPosScan])
      nTamCols   := Len(aVetBNR)
      aDel(aVetBNR,nPosScan)
      aSize(aVetBNR,nTamCols-1)
   Endif
Else
   //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
   //� Se for retirar a exclusao, tenho que verificar se os dados daquele linha estavam no vetor   |
   //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
   nPosScan := aScan(aVetBNR,{|x| x[1] == cCodigo .And. x[2] == cCodInt .And. x[3] == cCodLoc .And.;
               x[4] == oGet43:aCols[oGet43:Linha(),oGet43:PlRetPos("BPR_CODESP")] .And.;
               x[5] == oGet43:aCols[oGet43:Linha(),oGet43:PlRetPos("BPR_CODSUB")] .And.;
               x[6] == oGet43:aCols[oGet43:Linha(),oGet43:PlRetPos("BPR_CODTAB")] .And.;
               x[7] == oGet43:aCols[oGet43:Linha(),oGet43:PlRetPos("BPR_NUMAUX")]})
                
   If nPosScan <> 0
      aadd(aVetBNR,{cCodigo,cCodInt,cCodLoc,cCodEsp,cCodSub,;
                     oGet43:aCols[oGet43:Linha(),oGet43:PlRetPos("BPR_CODTAB")],;
                     oGet43:aCols[oGet43:Linha(),oGet43:PlRetPos("BPR_NUMAUX")],;
                     oGet43:aCols[oGet43:Linha(),oGet43:PlRetPos("BPR_SEQAUX")],;
                     oGet43:aCols[oGet43:Linha(),oGet43:PlRetPos("BPR_VIGAUX")],;
                     oGet43:aCols[oGet43:Linha(),oGet43:PlRetPos("BPR_PERCAX")],;
                     oGet43:aCols[oGet43:Linha(),oGet43:PlRetPos("BPR_NIVVAL")],;
                     oGet43:aCols[oGet43:Linha(),oGet43:PlRetPos("BPR_VIGDE")],;
                     ctod("")})
                                                    
      nTamCols   := Len(aVetDelBNR)
      aDel(aVetDelBNR,nPosScan)
      aSize(aVetDelBNR,nTamCols-1)
   Endif
Endif

Return(.T.)


/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑uncao    � PLSBPRWhen � Autor � Michele Tatagiba    � Data � 22.08.02 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escricao � Valida o X3_WHEN para os campos do BPR.                    낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
Function PLSBPRWhen(cTipo)

LOCAL lRet    := .T.    
DEFAULT cTipo := ""
/*
If M->BPR_FLAG == "1"
   lRet := .F.
Endif       
*/
If lRet .And. cTipo == "N" .And. !Empty(M->BPR_NUMAUX)
   lRet := .F.
Endif

Return(lRet)


/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑uncao    � PLSBPRRet  � Autor � Michele Tatagiba    � Data � 02.10.02 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escricao � Retorna a data da vigencia em aberto do Auxiliar           낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿛arametros� cCampo - Campo que vai ser retornado                       낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
Function PLSBPRRet(cCampo)
    
LOCAL cConteu
LOCAL lRet    := .F.

If ValType(&(cCampo)) == "D"
   cConteu := ctod("")
Else
   If ValType(&(cCampo)) == "C"
      cConteu := ""
   Else
      If ValType(&(cCampo)) == "N"
         cConteu := 0
      Endif
   Endif
Endif
      
BP1->(DBSetOrder(1))
If BP1->(DBSeek(xFilial("BP1")+M->BPR_CODINT+M->BPR_CODTAB+Str(M->BPR_NUMAUX,1)))
   While !BP1->(EOF()) .And. xFilial("BP1")+M->BPR_CODINT+M->BPR_CODTAB+Str(M->BPR_NUMAUX,1) == BP1->(BP1_FILIAL+BP1_CODINT+BP1_CODTAB+Str(M->BPR_NUMAUX,1)) .And.;
         !lRet
         If Empty(BP1->BP1_VIGATE)
            cConteu := &(cCampo)
            lRet    := .T.
         Endif
   BP1->(DBSkip())
   Enddo
Endif

Return(cConteu)


/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑uncao    � PLSPOSBNR  � Autor � Michele Tatagiba    � Data � 02.10.02 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escricao � Verifica se ja existe vigencia para esse registro e se     낢�
굇�          � essa esta e menor que a que esta sendo digitada            낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
Function PLSPOSBNR()
                                                                                          	
LOCAL lRet := .T.

BNR->(DBSetOrder(2))
BNR->(DBSeek(xFilial("BNR")+cCodigo+cCodInt+cCodLoc+cCodEsp+cCodSub+M->BPR_CODTAB+Str(M->BPR_NUMAUX,1)))
If M->BPR_VIGDE < BNR->BNR_DATDE
   MsgInfo("A data de vigencia do Auxiliar e menor que a data inicial("+dtoc(BNC->BNC_DATDE)+") da vigencia anterior.")
   lRet := .F.
Endif


Return(lRet)
