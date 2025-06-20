#INCLUDE "plsa365bph.ch"

#include "PROTHEUS.CH"
#include "PLSMGER.CH"


//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� As funcoes abaixo sao utilizadas no browse de Diaria para um Local de Atend.  |
//� Sao chamadas na validacao e exclusao de uma linha do Browse oGet34            |
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�


/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑uncao    � PLSBPHVld  � Autor � Michele Tatagiba    � Data � 14.10.02 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escricao � Valida a inclusao de uma linha no browse de Diarias do     낢�
굇�          � Local de Atendimento                                       낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
Function PLSBPHVld()

LOCAL lRet       := .T.
LOCAL lRetBPH    := .T.
LOCAL nPosScan   := 0                      

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Se foi informado uma valor, e obrigatorio o codigo da Unidade de Medida |
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
If M->BPH_VLRDIA <> 0 .And. Empty(M->BPH_CODDOC)
   MsgInfo(STR0001) //"Informe uma Unidade de Medida de Valor para essa Diaria."
   Return(.F.)
Endif

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Verifico se o nivel zero e valido                                       |
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
If M->BPH_VLRDIA == 0 .And. M->BPH_PERDIA == 0 .And. Empty(M->BPH_NIVVAL)
   MsgInfo(STR0002) //"Informe se o nivel zero e valido."
   Return(.F.)
Endif
          
BNJ->(DBSetOrder(1))
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Verifico se existe alguma data de vigencia anterior a essa.             |
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
If BNJ->(DBSeek(xFilial("BNJ")+cCodigo+M->BPH_CODINT+M->BPH_CODLOC+M->BPH_CODDIA))
   If M->BPH_VIGDE < BNJ->BNJ_DATDE
      MsgInfo(STR0003+dtoc(BNJ->BNJ_DATDE)) //"A data de vigencia da Diaria e menor que a ultima data de vigencia "
      Return(.F.)
   Else                  
      //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
      //� Caso a data de vigencia seja igual a data de, entao verifico o valor da diaria|
      //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
      If M->BPH_VIGDE == BNJ->BNJ_DATDE
         //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
         //� Se o valor da diaria for diferente, nao consigo colocar a data final|
         //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
         If M->BPH_VLRDIA <> BNJ->BNJ_VLRDIA
       	    MsgInfo(STR0004) //"A data de vigencia da diaria e igual a data da vigencia anterior."
       	    Return(.F.)
         Else           
            //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
            //� Se o percentual da taxa for diferente, nao consigo colocar a data final |
            //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�         
            If M->BPH_PERDIA <> BNJ->BNJ_PERDIA
         	   MsgInfo(STR0004) //"A data de vigencia da diaria e igual a data da vigencia anterior."
        	   Return(.F.)
            Else            
        	   lRet := .T.
        	Endif
         Endif
      Else
         //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
         //� Crio uma nova vigencia de taxa                                    |
         //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
         nPosScan := aScan(aVetBNJ,{|x| x[2] == M->BPH_CODINT .And. x[3] == M->BPH_CODLOC .And. x[4] == M->BPH_CODDIA})
         If nPosScan == 0
            aadd(aVetBNJ,{cCodigo,M->BPH_CODINT,M->BPH_CODLOC,M->BPH_CODDIA,M->BPH_VIGDIA,M->BPH_SEQDIA,M->BPH_VLRDIA,M->BPH_PERDIA,M->BPH_NIVVAL,M->BPH_CODDOC,M->BPH_VIGDE,ctod("")})
         Else
            aVetBNJ[nPosScan,5]  := M->BPH_SEQDIA
            aVetBNJ[nPosScan,6]  := M->BPH_VIGDIA
            aVetBNJ[nPosScan,7]  := M->BPH_VLRDIA
            aVetBNJ[nPosScan,8]  := M->BPH_PERDIA
            aVetBNJ[nPosScan,9]  := M->BPH_NIVVAL
            aVetBNJ[nPosScan,10] := M->BPH_CODDOC
            aVetBNJ[nPosScan,11] := M->BPH_VIGDE
         Endif
            
         lRet := .T.
      Endif
   Endif
Else
   //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
   //� Crio uma nova vigencia de taxa                                    |
   //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
   nPosScan := aScan(aVetBNJ,{|x| x[2] == M->BPH_CODINT .And. x[3] == M->BPH_CODLOC .And. x[4] == M->BPH_CODDIA})
   If nPosScan == 0
      aadd(aVetBNJ,{cCodigo,M->BPH_CODINT,M->BPH_CODLOC,M->BPH_CODDIA,M->BPH_VIGDIA,M->BPH_SEQDIA,M->BPH_VLRDIA,M->BPH_PERDIA,M->BPH_NIVVAL,M->BPH_CODDOC,M->BPH_VIGDE,ctod("")})
   Else
      aVetBNJ[nPosScan,5]  := M->BPH_SEQDIA
      aVetBNJ[nPosScan,6]  := M->BPH_VIGDIA
      aVetBNJ[nPosScan,7]  := M->BPH_VLRDIA
      aVetBNJ[nPosScan,8]  := M->BPH_PERDIA
      aVetBNJ[nPosScan,9]  := M->BPH_NIVVAL
      aVetBNJ[nPosScan,10] := M->BPH_CODDOC
      aVetBNJ[nPosScan,11] := M->BPH_VIGDE
   Endif
            
   lRet := .T. 
Endif

Return(lRet)


/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑uncao    � PLSBPHDel  � Autor � Michele Tatagiba    � Data � 22.08.02 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escricao � Valida a exclusao de uma linha no browse de Diarias da     낢�
굇�          � Operadora                                                  낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
Function PLSBPHDel()

LOCAL nPosScan
LOCAL nTamCols := 1
/*
If M->BPH_FLAG == "1"
   lRet := .F.
Endif
*/
nPosScan := aScan(aVetBNJ,{|x| x[1] == cCodigo .And. x[2] == cCodInt .And. x[3] == cCodLoc .And.;
            x[4] == oGet34:aCols[oGet34:Linha(),oGet34:PlRetPos("BPH_CODDIA")]})
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Se for exclusao da linha, tiro o dado do vetor                    |
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�      
If oGet34:aCols[oGet34:Linha(),Len(oGet34:aHeader)+1]
   If nPosScan <> 0
      aadd(aVetDelBNJ,aVetBNJ[nPosScan])
      nTamCols   := Len(aVetBNJ)
      aDel(aVetBNJ,nPosScan)
      aSize(aVetBNJ,nTamCols-1)
   Endif
Else
   //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
   //� Se for retirar a exclusao, tenho que verificar se os dados daquele linha estavam no vetor   |
   //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
   nPosScan := aScan(aVetBNJ,{|x| x[1] == cCodigo .And. x[2] == cCodInt .And. x[3] == cCodLoc .And.;
                x[4] == oGet34:aCols[oGet34:Linha(),oGet34:PlRetPos("BPH_CODDIA")]})
                
   If nPosScan <> 0
      aadd(aVetBNJ,{cCodigo,cCodInt,cCodLoc,oGet34:aCols[oGet34:Linha(),oGet34:PlRetPos("BPH_CODDIA")],;
                     oGet34:aCols[oGet34:Linha(),oGet34:PlRetPos("BPH_SEQDIA")],;
                     oGet34:aCols[oGet34:Linha(),oGet34:PlRetPos("BPH_VIGDIA")],;
                     oGet34:aCols[oGet34:Linha(),oGet34:PlRetPos("BPH_VLRDIA")],;
                     oGet34:aCols[oGet34:Linha(),oGet34:PlRetPos("BPH_PERDIA")],;
                     oGet34:aCols[oGet34:Linha(),oGet34:PlRetPos("BPH_NIVVAL")],;
                     oGet34:aCols[oGet34:Linha(),oGet34:PlRetPos("BPH_CODDOC")],;
                     oGet34:aCols[oGet34:Linha(),oGet34:PlRetPos("BPH_VIGDE")],;
                     ctod("")})
                                                    
      nTamCols   := Len(aVetDelBNJ)
      aDel(aVetDelBNJ,nPosScan)
      aSize(aVetDelBNJ,nTamCols-1)
   Endif
Endif

Return(.T.)


/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑uncao    � PLSBPHWhen � Autor � Michele Tatagiba    � Data � 22.08.02 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escricao � Valida o X3_WHEN para os campos do BPH.                    낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
Function PLSBPHWhen(cTipo)

LOCAL lRet    := .T.
DEFAULT cTipo := ""
/*
If M->BPH_FLAG == "1" .And. Empty(cTipo)
   lRet := .F.
Endif
*/
If lRet .And. cTipo == "V" .And. !Empty(M->BPH_PERDIA)
   lRet := .F.
Endif

If lRet .And. cTipo == "P" .And. !Empty(M->BPH_VLRDIA)
   lRet := .F.
Endif

If lRet .And. cTipo == "N" .And. (!Empty(M->BPH_PERDIA) .Or. !Empty(M->BPH_VLRDIA))
   lRet := .F.
Endif

Return(lRet)             


/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑uncao    � PLSBPHRet  � Autor � Michele Tatagiba    � Data � 02.10.02 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escricao � Retorna a data da vigencia em aberto da Diaria             낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿛arametros� cCampo - Campo que vai ser retornado                       낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
Function PLSBPHRet(cCampo)
    
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
If BP9->(DBSeek(xFilial("BP9")+M->BPH_CODINT+M->BPH_CODDIA))
   While !BP9->(EOF()) .And. xFilial("BP9")+M->BPH_CODINT+M->BPH_CODDIA == BP9->(BP9_FILIAL+BP9_CODINT+BP9_CODIGO) .And.;
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
굇쿑uncao    � PLSPOSBNJ  � Autor � Michele Tatagiba    � Data � 02.10.02 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escricao � Verifica se ja existe vigencia para esse registro e se     낢�
굇�          � essa esta e menor que a que esta sendo digitada            낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
Function PLSPOSBNJ()

LOCAL lRet := .T.

BNJ->(DBSetOrder(2))
BNJ->(DBSeek(xFilial("BNJ")+cCodigo+cCodInt+cCodLoc+M->BPH_CODDIA))
If M->BPH_VIGDE < BNJ->BNJ_DATDE 
   MsgInfo(STR0005+dtoc(BNJ->BNJ_DATDE)+STR0006) //"A data de vigencia da Diaria e menor que a data inicial("###") da vigencia anterior."
   lRet := .F.
Endif


Return(lRet)
