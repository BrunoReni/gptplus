
#include "PROTHEUS.CH"
#include "PLSMGER.CH"


//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� As funcoes abaixo sao utilizadas no browse de Diaria para uma Especialidade.  |
//� Sao chamadas na validacao e exclusao de uma linha do Browse oGet41            |
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�


/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑uncao    � PLSBPPVld  � Autor � Michele Tatagiba    � Data � 14.10.02 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escricao � Valida a inclusao de uma linha no browse de Diarias da     낢�
굇�          � Especialidade.                                             낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
Function PLSBPPVld()

LOCAL lRet       := .T.
LOCAL lRetBPP    := .T.
LOCAL nPosScan   := 0                      

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Se foi informado uma valor, e obrigatorio o codigo da Unidade de Medida |
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
If M->BPP_VLRDIA <> 0 .And. Empty(M->BPP_CODDOC)
   MsgInfo("Informe uma Unidade de Medida de Valor para essa Diaria.")
   Return(.F.)
Endif

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Verifico se o nivel zero e valido                                       |
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
If M->BPP_VLRDIA == 0 .And. M->BPP_PERDIA == 0 .And. Empty(M->BPP_NIVVAL)
   MsgInfo("Informe se o nivel zero e valido.")
   Return(.F.)
Endif
          
BNP->(DBSetOrder(1))
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Verifico se existe alguma data de vigencia anterior a essa.             |
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
If BNP->(DBSeek(xFilial("BNP")+cCodigo+M->BPP_CODINT+M->BPP_CODLOC+M->BPP_CODESP+M->BPP_CODSUB+M->BPP_CODDIA))
   If M->BPP_VIGDE < BNP->BNP_DATDE
      MsgInfo("A data de vigencia da Diaria e menor que a ultima data de vigencia "+dtoc(BNP->BNP_DATDE))
      Return(.F.)
   Else
      //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
      //� Caso a data de vigencia seja igual a data de, entao verifico o valor da diaria|
      //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
      If M->BPP_VIGDE == BNP->BNP_DATDE
         //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
         //� Se o valor da diaria for diferente, nao consigo colocar a data final|
         //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
         If M->BPP_VLRDIA <> BNP->BNP_VLRDIA
       	    MsgInfo("A data de vigencia da diaria e igual a data da vigencia anterior.")
       	    Return(.F.)
         Else           
            //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
            //� Se o percentual da taxa for diferente, nao consigo colocar a data final |
            //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�         
            If M->BPP_PERDIA <> BNP->BNP_PERDIA
         	   MsgInfo("A data de vigencia da diaria e igual a data da vigencia anterior.")
        	   Return(.F.)
            Else            
        	   lRet := .T.
        	Endif
         Endif
      Else
         //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
         //� Crio uma nova vigencia de taxa                                    |
         //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
         nPosScan := aScan(aVetBNP,{|x| x[2] == M->BPP_CODINT .And. x[3] == M->BPP_CODLOC .And.;
                            x[4] == M->BPP_CODESP .And. x[5] == M->BPP_CODSUB .And. x[6] == M->BPP_CODDIA })
         If nPosScan == 0
            aadd(aVetBNP,{cCodigo,M->BPP_CODINT,M->BPP_CODLOC,M->BPP_CODESP,M->BPP_CODSUB,M->BPP_CODDIA,M->BPP_SEQDIA,M->BPP_VIGDIA,M->BPP_VLRDIA,M->BPP_PERDIA,M->BPP_NIVVAL,M->BPP_CODDOC,M->BPP_VIGDE,ctod("")})
         Else
            aVetBNP[nPosScan,7]  := M->BPP_SEQDIA
            aVetBNP[nPosScan,8]  := M->BPP_VIGDIA
            aVetBNP[nPosScan,9]  := M->BPP_VLRDIA
            aVetBNP[nPosScan,10] := M->BPP_PERDIA
            aVetBNP[nPosScan,11] := M->BPP_NIVVAL
            aVetBNP[nPosScan,12] := M->BPP_CODDOC
            aVetBNP[nPosScan,13] := M->BPP_VIGDE
         Endif
                     
         lRet := .T.
      Endif
   Endif
Else
   //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
   //� Crio uma nova vigencia de taxa                                    |
   //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
   nPosScan := aScan(aVetBNP,{|x| x[2] == M->BPP_CODINT .And. x[3] == M->BPP_CODLOC .And.;
                      x[4] == M->BPP_CODESP .And. x[5] == M->BPP_CODSUB .And. x[6] == M->BPP_CODDIA })
   If nPosScan == 0
      aadd(aVetBNP,{cCodigo,M->BPP_CODINT,M->BPP_CODLOC,M->BPP_CODESP,M->BPP_CODSUB,M->BPP_CODDIA,M->BPP_SEQDIA,M->BPP_VIGDIA,M->BPP_VLRDIA,M->BPP_PERDIA,M->BPP_NIVVAL,M->BPP_CODDOC,M->BPP_VIGDE,ctod("")})
   Else
      aVetBNP[nPosScan,7]  := M->BPP_SEQDIA
      aVetBNP[nPosScan,8]  := M->BPP_VIGDIA
      aVetBNP[nPosScan,9]  := M->BPP_VLRDIA
      aVetBNP[nPosScan,10] := M->BPP_PERDIA
      aVetBNP[nPosScan,11] := M->BPP_NIVVAL
      aVetBNP[nPosScan,12] := M->BPP_CODDOC
      aVetBNP[nPosScan,13] := M->BPP_VIGDE
   Endif
            
   lRet := .T. 
Endif

Return(lRet)


/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑uncao    � PLSBPPDel  � Autor � Michele Tatagiba    � Data � 22.08.02 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escricao � Valida a exclusao de uma linha no browse de Diarias da     낢�
굇�          � Operadora                                                  낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
Function PLSBPPDel()

LOCAL nPosScan
LOCAL nTamCols := 1
/*
If M->BPP_FLAG == "1"
   lRet := .F.
Endif
*/
nPosScan := aScan(aVetBNP,{|x| x[1] == cCodigo .And. x[2] == cCodInt .And. x[3] == cCodLoc .And.;
            x[4] == cCodEsp .And. x[5] == cCodSub .And.;
            x[6] == oGet41:aCols[oGet41:Linha(),oGet41:PlRetPos("BPP_CODDIA")]})
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Se for exclusao da linha, tiro o dado do vetor                    |
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�      
If oGet41:aCols[oGet41:Linha(),Len(oGet41:aHeader)+1]
   If nPosScan <> 0
      aadd(aVetDelBNP,aVetBNP[nPosScan])
      nTamCols   := Len(aVetBNP)
      aDel(aVetBNP,nPosScan)
      aSize(aVetBNP,nTamCols-1)
   Endif
Else
   //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
   //� Se for retirar a exclusao, tenho que verificar se os dados daquele linha estavam no vetor   |
   //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
   nPosScan := aScan(aVetBNP,{|x| x[1] == cCodigo .And. x[2] == cCodInt .And. x[3] == cCodLoc .And.;
                x[4] == cCodEsp .And. x[5] == cCodSub .And.;
                x[6] == oGet41:aCols[oGet41:Linha(),oGet41:PlRetPos("BPP_CODDIA")]})
                
   If nPosScan <> 0
      aadd(aVetBNP,{cCodigo,cCodInt,cCodLoc,cCodEsp,cCodSub,;
                     oGet41:aCols[oGet41:Linha(),oGet41:PlRetPos("BPP_CODDIA")],;
                     oGet41:aCols[oGet41:Linha(),oGet41:PlRetPos("BPP_SEQDIA")],;
                     oGet41:aCols[oGet41:Linha(),oGet41:PlRetPos("BPP_VIGDIA")],;
                     oGet41:aCols[oGet41:Linha(),oGet41:PlRetPos("BPP_VLRDIA")],;
                     oGet41:aCols[oGet41:Linha(),oGet41:PlRetPos("BPP_PERDIA")],;
                     oGet41:aCols[oGet41:Linha(),oGet41:PlRetPos("BPP_NIVVAL")],;
                     oGet41:aCols[oGet41:Linha(),oGet41:PlRetPos("BPP_CODDOC")],;
                     oGet41:aCols[oGet41:Linha(),oGet41:PlRetPos("BPP_VIGDE")],;
                     ctod("")})
                                                    
      nTamCols   := Len(aVetDelBNP)
      aDel(aVetDelBNP,nPosScan)
      aSize(aVetDelBNP,nTamCols-1)
   Endif
Endif

Return(.T.)


/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑uncao    � PLSBPPWhen � Autor � Michele Tatagiba    � Data � 22.08.02 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escricao � Valida o X3_WHEN para os campos do BPP.                    낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
Function PLSBPPWhen(cTipo)

LOCAL lRet    := .T.
DEFAULT cTipo := ""
/*
If M->BPP_FLAG == "1" .And. Empty(cTipo)
   lRet := .F.
Endif
*/
If lRet .And. cTipo == "V" .And. !Empty(M->BPP_PERDIA)
   lRet := .F.
Endif

If lRet .And. cTipo == "P" .And. !Empty(M->BPP_VLRDIA)
   lRet := .F.
Endif

If lRet .And. cTipo == "N" .And. (!Empty(M->BPP_PERDIA) .Or. !Empty(M->BPP_VLRDIA))
   lRet := .F.
Endif

Return(lRet)             


/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑uncao    � PLSBPPRet  � Autor � Michele Tatagiba    � Data � 02.10.02 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escricao � Retorna a data da vigencia em aberto da Diaria             낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿛arametros� cCampo - Campo que vai ser retornado                       낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
Function PLSBPPRet(cCampo)
    
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
      
BP9->(DBSetOrder(1))
If BP9->(DBSeek(xFilial("BP9")+M->BPP_CODINT+M->BPP_CODDIA))
   While !BP9->(EOF()) .And. xFilial("BP9")+M->BPP_CODINT+M->BPP_CODDIA == BP9->(BP9_FILIAL+BP9_CODINT+BP9_CODIGO) .And.;
         !lRet
         If Empty(BP9->BP9_VIGATE)
            cConteu := &(cCampo)
            lRet    := .T.
         Endif
   BP9->(DBSkip())
   Enddo
Endif

Return(cConteu)


/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑uncao    � PLSPOSBNP  � Autor � Michele Tatagiba    � Data � 02.10.02 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escricao � Verifica se ja existe vigencia para esse registro e se     낢�
굇�          � essa esta e menor que a que esta sendo digitada            낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
Function PLSPOSBNP()

LOCAL lRet := .T.

BNP->(DBSetOrder(2))
BNP->(DBSeek(xFilial("BNP")+cCodigo+cCodInt+cCodLoc+cCodEsp+cCodSub+M->BPP_CODDIA))
If M->BPP_VIGDE < BNP->BNP_DATDE 
   MsgInfo("A data de vigencia da Diaria e menor que a data inicial("+dtoc(BNP->BNP_DATDE)+") da vigencia anterior.")
   lRet := .F.
Endif


Return(lRet)
