
#include "PROTHEUS.CH"
#include "PLSMGER.CH"


//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� As funcoes abaixo sao utilizadas no browse de Filme para uma Especialidade.   |
//� Sao chamadas na validacao e exclusao de uma linha do Browse oGet42            |
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�


/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑uncao    � PLSBPQVld  � Autor � Michele Tatagiba    � Data � 22.08.02 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escricao � Valida a inclusao de uma linha no browse de Filme da       낢�
굇�          � Especialidade.                                             낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
Function PLSBPQVld()

LOCAL lRet       := .T.

/*
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Se foi informado uma valor, e obrigatorio o codigo da Unidade de Medida |
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
If M->BPQ_VLRFIL <> 0 .And. Empty(M->BPQ_CODDOC)
   MsgInfo("Informe uma Unidade de Medida de Valor para o Filme.")
   Return(.F.)
Endif

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Verifico se o nivel zero e valido                                       |
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
If M->BPQ_VLRFIL == 0 .And. M->BPQ_PERFIL == 0 .And. Empty(M->BPQ_NIVVAL)
   MsgInfo("Informe se o nivel zero e valido.")
   Return(.F.)
Endif
          
BNQ->(DBSetOrder(1))
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Verifico se existe alguma data de vigencia anterior a essa.             |
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
If BNQ->(DBSeek(xFilial("BNQ")+cCodigo+M->BPQ_CODINT+M->BPQ_CODLOC+M->BPQ_CODESP+M->BPQ_CODSUB+M->BPQ_CODFIL))
   If M->BPQ_VIGDE < BNQ->BNQ_DATDE
      MsgInfo("A data de vigencia do Filme e menor que a ultima data de vigencia "+dtoc(BNQ->BNQ_DATDE))
      Return(.F.)
   Else
      //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
      //� Caso a data de vigencia seja igual a data de, entao verifico o valor da diaria|
      //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
      If M->BPQ_VIGDE == BNQ->BNQ_DATDE
         //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
         //� Se o valor do filme for diferente, nao consigo colocar a data final |
         //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
         If M->BPQ_VLRFIL <> BNQ->BNQ_VLRFIL
       	    MsgInfo("A data de vigencia do Filme e igual a data da vigencia anterior.")
       	    Return(.F.)
         Else
            //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
            //� Se o percentual da taxa for diferente, nao consigo colocar a data final |
            //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�         
            If M->BPQ_PERFIL <> BNQ->BNQ_PERFIL
         	   MsgInfo("A data de vigencia do filme e igual a data da vigencia anterior.")
        	   Return(.F.)
            Else
        	   lRet := .T.
        	Endif
         Endif
      Else
         //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
         //� Crio uma nova vigencia de filme                                   |
         //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
         nPosScan := aScan(aVetBNQ,{|x| x[2] == M->BPQ_CODINT .And. x[3] == M->BPQ_CODLOC .And.;
                           x[4] == M->BPQ_CODESP .And. x[5] == M->BPQ_CODSUB .And. x[6] == M->BPQ_CODFIL})
         If nPosScan == 0
            aadd(aVetBNQ,{cCodigo,M->BPQ_CODINT,M->BPQ_CODLOC,M->BPQ_CODESP,M->BPQ_CODSUB,M->BPQ_CODFIL,M->BPQ_SEQFIL,M->BPQ_VIGFIL,M->BPQ_VLRFIL,M->BPQ_PERFIL,M->BPQ_NIVVAL,M->BPQ_CODDOC,M->BPQ_VIGDE,ctod("")})
         Else
            aVetBNQ[nPosScan,7]  := M->BPQ_SEQFIL
            aVetBNQ[nPosScan,8]  := M->BPQ_VIGFIL
            aVetBNQ[nPosScan,9]  := M->BPQ_VLRFIL
            aVetBNQ[nPosScan,10] := M->BPQ_PERFIL
            aVetBNQ[nPosScan,11] := M->BPQ_NIVVAL
            aVetBNQ[nPosScan,12] := M->BPQ_CODDOC
            aVetBNQ[nPosScan,13] := M->BPQ_VIGDE
         Endif
            
         lRet := .T.
      Endif
   Endif
Else
   //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
   //� Crio uma nova vigencia do filme                                   |
   //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
   nPosScan := aScan(aVetBNQ,{|x| x[2] == M->BPQ_CODINT .And. x[3] == M->BPQ_CODLOC .And.;
                      x[4] == M->BPQ_CODESP .And. x[5] == M->BPQ_CODSUB .And. x[6] == M->BPQ_CODFIL})
   If nPosScan == 0
      aadd(aVetBNQ,{cCodigo,M->BPQ_CODINT,M->BPQ_CODLOC,M->BPQ_CODESP,M->BPQ_CODSUB,M->BPQ_CODFIL,M->BPQ_SEQFIL,M->BPQ_VIGFIL,M->BPQ_VLRFIL,M->BPQ_PERFIL,M->BPQ_NIVVAL,M->BPQ_CODDOC,M->BPQ_VIGDE,ctod("")})
   Else
      aVetBNQ[nPosScan,7]  := M->BPQ_SEQFIL
      aVetBNQ[nPosScan,8]  := M->BPQ_VIGFIL
      aVetBNQ[nPosScan,9]  := M->BPQ_VLRFIL
      aVetBNQ[nPosScan,10] := M->BPQ_PERFIL
      aVetBNQ[nPosScan,11] := M->BPQ_NIVVAL
      aVetBNQ[nPosScan,12] := M->BPQ_CODDOC
      aVetBNQ[nPosScan,13] := M->BPQ_VIGDE
   Endif

   lRet := .T.
Endif
*/
Return(lRet)


/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑uncao    � PLSBPQDel  � Autor � Michele Tatagiba    � Data � 22.08.02 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escricao � Valida a exclusao de uma linha no browse de Filme do       낢�
굇�          � Local de Atendimento                                       낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
Function PLSBPQDel()

LOCAL nPosScan
LOCAL nTamCols := 1
/*
If M->BPQ_FLAG == "1"
   lRet := .F.
Endif
*/
nPosScan := aScan(aVetBNQ,{|x| x[1] == cCodigo .And. x[2] == cCodInt .And. x[3] == cCodLoc .And.;
            x[4] == cCodEsp .And. x[5] == cCodSub .And.;
            x[6] == oGet42:aCols[oGet42:Linha(),oGet42:PlRetPos("BPQ_CODFIL")]})
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Se for exclusao da linha, tiro o dado do vetor                    |
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�      
If oGet42:aCols[oGet42:Linha(),Len(oGet42:aHeader)+1]
   If nPosScan <> 0
      aadd(aVetDelBNQ,aVetBNQ[nPosScan])
      nTamCols   := Len(aVetBNQ)
      aDel(aVetBNQ,nPosScan)
      aSize(aVetBNQ,nTamCols-1)
   Endif
Else
   //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
   //� Se for retirar a exclusao, tenho que verificar se os dados daquele linha estavam no vetor   |
   //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
   nPosScan := aScan(aVetBNQ,{|x| x[1] == cCodigo .And. x[2] == cCodInt .And. x[3] == cCodLoc .And.;
               x[4] == cCodEsp .And. x[5] == cCodSub .And.;
               x[6] == oGet42:aCols[oGet42:Linha(),oGet42:PlRetPos("BPQ_CODFIL")]})
                
   If nPosScan <> 0
      aadd(aVetBNQ,{cCodigo,cCodInt,cCodLoc,cCodEsp,cCodSub,oGet42:aCols[oGet42:Linha(),oGet42:PlRetPos("BPQ_CODFIL")],;
                     oGet42:aCols[oGet42:Linha(),oGet42:PlRetPos("BPQ_SEQFIL")],;
                     oGet42:aCols[oGet42:Linha(),oGet42:PlRetPos("BPQ_VIGFIL")],;
                     oGet42:aCols[oGet42:Linha(),oGet42:PlRetPos("BPQ_VLRFIL")],;
                     oGet42:aCols[oGet42:Linha(),oGet42:PlRetPos("BPQ_PERFIL")],;
                     oGet42:aCols[oGet42:Linha(),oGet42:PlRetPos("BPQ_NIVVAL")],;
                     oGet42:aCols[oGet42:Linha(),oGet42:PlRetPos("BPQ_CODDOC")],;
                     oGet42:aCols[oGet42:Linha(),oGet42:PlRetPos("BPQ_VIGDE")],;
                     ctod("")})
                                                    
      nTamCols   := Len(aVetDelBNQ)
      aDel(aVetDelBNQ,nPosScan)
      aSize(aVetDelBNQ,nTamCols-1)
   Endif
Endif

Return(.T.)


/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑uncao    � PLSBPQWhen � Autor � Michele Tatagiba    � Data � 22.08.02 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escricao � Valida o X3_WHEN para os campos do BPQ.                    낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
Function PLSBPQWhen(cTipo)

LOCAL lRet    := .T.
DEFAULT cTipo := ""
/*
If M->BPQ_FLAG == "1" .And. Empty(cTipo)
   lRet := .F.
Endif
*/
If lRet .And. cTipo == "V" .And. !Empty(M->BPQ_PERFIL)
   lRet := .F.
Endif

If lRet .And. cTipo == "P" .And. !Empty(M->BPQ_VLRFIL)
   lRet := .F.
Endif

If lRet .And. cTipo == "N" .And. (!Empty(M->BPQ_PERFIL) .Or. !Empty(M->BPQ_VLRFIL))
   lRet := .F.
Endif

Return(lRet)

                                 
/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑uncao    � PLSBPQRet  � Autor � Michele Tatagiba    � Data � 02.10.02 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escricao � Retorna a data da vigencia em aberto do Filme              낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿛arametros� cCampo - Campo que vai ser retornado                       낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
Function PLSBPQRet(cCampo)
    
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
      
BP8->(DBSetOrder(1))
If BP8->(DBSeek(xFilial("BP8")+M->BPQ_CODINT+M->BPQ_CODFIL))
   While !BP8->(EOF()) .And. xFilial("BP8")+M->BPQ_CODINT+M->BPQ_CODFIL == BP8->(BP8_FILIAL+BP8_CODINT+BP8_CODIGO) .And.;
         !lRet
         If Empty(BP8->BP8_VIGATE)
            cConteu := &(cCampo)
            lRet    := .T.
         Endif
   BP8->(DBSkip())
   Enddo
Endif

Return(cConteu)


/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑uncao    � PLSPOSBNQ  � Autor � Michele Tatagiba    � Data � 02.10.02 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escricao � Verifica se ja existe vigencia para esse registro e se     낢�
굇�          � essa esta e menor que a que esta sendo digitada            낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
Function PLSPOSBNQ()

LOCAL lRet := .T.

BNQ->(DBSetOrder(2))
BNQ->(DBSeek(xFilial("BNQ")+cCodigo+cCodInt+cCodLoc+cCodEsp+cCodSub+M->BPQ_CODFIL))
If M->BPQ_VIGDE < BNQ->BNQ_DATDE
   MsgInfo("A data de vigencia do Filme e menor que a data inicial("+dtoc(BNQ->BNQ_DATDE)+") da vigencia anterior.")
   lRet := .F.
Endif

Return(lRet)

/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑uncao    � PLSBPQPad  � Autor � Michele Tatagiba    � Data � 06.11.02 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escricao � Verifica se o filme e padrao                               낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
Function PLSBPQPad(cOpc)

LOCAL lRet   := .T.
LOCAL nInd   := 1
LOCAL nQtd   := 0

If cOpc == "1"
   While nInd <= Len(oGet42:aCols) .And. lRet

       If (oGet42:aCols[nInd,oGet42:PlRetPos("BPQ_CODINT")] == cCodInt .And.;
          oGet42:aCols[nInd,oGet42:PlRetPos("BPQ_CODLOC")] == cCodLoc .And.;
          oGet42:aCols[nInd,oGet42:PlRetPos("BPQ_CODESP")] == cCodEsp .And.;
          oGet42:aCols[nInd,oGet42:PlRetPos("BPQ_CODSUB")] == cCodSub .And.;
          oGet42:aCols[nInd,oGet42:PlRetPos("BPQ_PADRAO")] == "1") .Or.;
          (nInd == oGet42:Linha() .And. oGet42:aCols[nInd,oGet42:PlRetPos("BPQ_PADRAO")] == "0")
          If MsgYesNo("Ja existe outro filme cadastrado como padrao. Deseja altera-lo?")
             oGet42:aCols[nInd,oGet42:PlRetPos("BPQ_PADRAO")] := "0"
             oGet42:Atualiza()
          Else
             lRet := .F.
          Endif
       Endif

   nInd ++
   Enddo
Endif

If cOpc == "0"
   While nInd <= Len(oGet42:aCols)

       If (oGet42:aCols[nInd,oGet42:PlRetPos("BPQ_CODINT")] == cCodInt .And.;
          oGet42:aCols[nInd,oGet42:PlRetPos("BPQ_CODLOC")] == cCodLoc .And.;
          oGet42:aCols[nInd,oGet42:PlRetPos("BPQ_CODESP")] == cCodEsp .And.;
          oGet42:aCols[nInd,oGet42:PlRetPos("BPQ_CODSUB")] == cCodSub .And.;
          oGet42:aCols[nInd,oGet42:PlRetPos("BPQ_PADRAO")] == "0") .Or.;
          (nInd == oGet42:Linha() .And. oGet42:aCols[nInd,oGet42:PlRetPos("BPQ_PADRAO")] == "1")
          nQtd ++
       Endif

   nInd ++
   Enddo
      
   If nQtd == Len(oGet42:aCols) .Or. Empty(oGet42:aCols[oGet42:Linha(),oGet42:PlRetPos("BPQ_PADRAO")])
      If MsgYesNo("Nao existe nenhum filme cadastrado como Padrao. Deseja tornar esse padrao?")
         M->BPQ_PADRAO := "1"
      Else
         lRet := .F.
      Endif
   Endif
Endif


Return(lRet)
