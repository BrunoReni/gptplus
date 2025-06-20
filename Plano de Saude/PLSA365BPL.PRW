#INCLUDE "plsa365bpl.ch"

#include "PROTHEUS.CH"
#include "PLSMGER.CH"


//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� As funcoes abaixo sao utilizadas no browse de Material de um Local de Atendimento   |
//� Sao chamadas na validacao e exclusao de uma linha do Browse oGet37                  |
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�


/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑uncao    � PLSBPLVld  � Autor � Michele Tatagiba    � Data � 02.10.02 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escricao � Valida a inclusao de uma linha no browse de Material da    낢�
굇�          � Operadora                                                  낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
Function PLSBPLVld()

LOCAL lRet       := .T.
LOCAL lRetBPL    := .T.
LOCAL nPosScan   := 0 

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Se foi informado uma valor, e obrigatorio o codigo da Unidade de Medida |
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
If M->BPL_VLRMAT <> 0 .And. Empty(M->BPL_CODDOC)
   MsgInfo(STR0001) //"Informe uma Unidade de Medida de Valor para esse Material."
   Return(.F.)
Endif

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Verifico se o nivel zero e valido                                       |
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
If M->BPL_VLRMAT == 0 .And. M->BPL_PERMAT == 0 .And. Empty(M->BPL_NIVVAL)
   MsgInfo(STR0002) //"Informe se o nivel zero e valido."
   Return(.F.)
Endif
          
BNK->(DBSetOrder(1))
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Verifico se existe alguma data de vigencia anterior a essa.             |
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
If BNK->(DBSeek(xFilial("BNK")+cCodigo+M->BPL_CODINT+M->BPL_CODLOC+M->BPL_CODTAB+M->BPL_CODMAT))
   If M->BPL_VIGDE < BNK->BNK_DATDE
      MsgInfo(STR0003+dtoc(BNK->BNK_DATDE)) //"A data de vigencia do Material e menor que a ultima data de vigencia "
      Return(.F.)
   Else                  
      //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
      //� Caso a data de vigencia seja igual a data de, entao verifico o valor do Material        |
      //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
      If M->BPL_VIGDE == BNK->BNK_DATDE
         //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
         //� Se o valor do Material for diferente, nao consigo colocar a data final        |
         //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
         If M->BPL_VLRMAT <> BNK->BNK_VLRMAT
       	    MsgInfo(STR0004) //"A data de vigencia do Material e igual a data da vigencia anterior."
       	    Return(.F.)
         Else           
            //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
            //� Se o percentual do Material for diferente, nao consigo colocar a data final   |
            //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�         
            If M->BPL_PERMAT <> BNK->BNK_PERMAT
         	   MsgInfo(STR0004) //"A data de vigencia do Material e igual a data da vigencia anterior."
        	   Return(.F.)
            Else            
        	   lRet := .T.
        	Endif
         Endif
      Else
         //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
         //� Crio uma nova vigencia de Material                                |
         //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
         nPosScan := aScan(aVetBNK,{|x| x[2] == M->BPL_CODINT .And. x[3] == M->BPL_CODLOC .And. x[4] == M->BPL_CODTAB .And. x[5] == M->BPL_CODMAT })
         If nPosScan == 0
            aadd(aVetBNK,{cCodigo,M->BPL_CODINT,M->BPL_CODLOC,M->BPL_CODTAB,M->BPL_CODMAT,M->BPL_VIGMAT,M->BPL_VLRMAT,M->BPL_MATIPO,M->BPL_CODDOC,M->BPL_PERMAT,M->BPL_NIVVAL,M->BPL_VIGDE,ctod("")})
         Else
            aVetBNK[nPosScan,6]  := M->BPL_VIGMAT
            aVetBNK[nPosScan,7]  := M->BPL_VLRMAT
            aVetBNK[nPosScan,8]  := M->BPL_MATIPO
            aVetBNK[nPosScan,9]  := M->BPL_CODDOC
            aVetBNK[nPosScan,10] := M->BPL_PERMAT
            aVetBNK[nPosScan,11] := M->BPL_NIVVAL
            aVetBNK[nPosScan,12] := M->BPL_VIGDE
         Endif
            
         lRet := .T.
      Endif
   Endif
Else
   //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
   //� Crio uma nova vigencia de Material                                |
   //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
   nPosScan := aScan(aVetBNK,{|x| x[2] == M->BPL_CODINT .And. x[3] == M->BPL_CODLOC .And. x[4] == M->BPL_CODTAB .And. x[5] == M->BPL_CODMAT })
   If nPosScan == 0
      aadd(aVetBNK,{cCodigo,M->BPL_CODINT,M->BPL_CODLOC,M->BPL_CODTAB,M->BPL_CODMAT,M->BPL_VIGMAT,M->BPL_VLRMAT,M->BPL_MATIPO,M->BPL_CODDOC,M->BPL_PERMAT,M->BPL_NIVVAL,M->BPL_VIGDE,ctod("")})
   Else
      aVetBNK[nPosScan,6]  := M->BPL_VIGMAT
      aVetBNK[nPosScan,7]  := M->BPL_VLRMAT
      aVetBNK[nPosScan,8]  := M->BPL_MATIPO
      aVetBNK[nPosScan,9]  := M->BPL_CODDOC
      aVetBNK[nPosScan,10] := M->BPL_PERMAT
      aVetBNK[nPosScan,11] := M->BPL_NIVVAL
      aVetBNK[nPosScan,12] := M->BPL_VIGDE
   Endif
                     
   lRet := .T.
Endif

Return(lRet)


/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑uncao    � PLSBPLDel  � Autor � Michele Tatagiba    � Data � 22.08.02 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escricao � Valida a exclusao de uma linha no browse de Materiais da   낢�
굇�          � Operadora                                                  낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
Function PLSBPLDel()

LOCAL nPosScan
LOCAL nTamCols := 1
/*
If M->BPL_FLAG == "1"
   lRet := .F.
Endif
*/
nPosScan := aScan(aVetBNK,{|x| x[1] == cCodigo .And. x[2] == cCodInt .And. x[3] == cCodLoc .And.;
            x[4] == oGet37:aCols[oGet37:Linha(),oGet37:PlRetPos("BPL_CODTAB")] .And.;
            x[5] == oGet37:aCols[oGet37:Linha(),oGet37:PlRetPos("BPL_CODMAT")]})
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Se for exclusao da linha, tiro o dado do vetor                    |
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�      
If oGet37:aCols[oGet37:Linha(),Len(oGet37:aHeader)+1]
   If nPosScan <> 0
      aadd(aVetDelBNK,aVetBNK[nPosScan])
      nTamCols   := Len(aVetBNK)
      aDel(aVetBNK,nPosScan)
      aSize(aVetBNK,nTamCols-1)
   Endif
Else
   //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
   //� Se for retirar a exclusao, tenho que verificar se os dados daquele linha estavam no vetor   |
   //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
   nPosScan := aScan(aVetBNK,{|x| x[1] == cCodigo .And. x[2] == cCodInt .And. x[3] == cCodLoc .And.;
                x[4] == oGet37:aCols[oGet37:Linha(),oGet37:PlRetPos("BPL_CODTAB")] .And.;
                x[5] == oGet37:aCols[oGet37:Linha(),oGet37:PlRetPos("BPL_CODMAT")]})
                
   If nPosScan <> 0
      aadd(aVetBNK,{cCodigo,cCodInt,cCodLoc,oGet37:aCols[oGet37:Linha(),oGet37:PlRetPos("BPL_CODTAB")],;
                     oGet37:aCols[oGet37:Linha(),oGet37:PlRetPos("BPL_CODMAT")],;
                     oGet37:aCols[oGet37:Linha(),oGet37:PlRetPos("BPL_VIGMAT")],;
                     oGet37:aCols[oGet37:Linha(),oGet37:PlRetPos("BPL_VLRMAT")],;
                     oGet37:aCols[oGet37:Linha(),oGet37:PlRetPos("BPL_MATIPO")],;
                     oGet37:aCols[oGet37:Linha(),oGet37:PlRetPos("BPL_CODDOC")],;
                     oGet37:aCols[oGet37:Linha(),oGet37:PlRetPos("BPL_PERMAT")],;
                     oGet37:aCols[oGet37:Linha(),oGet37:PlRetPos("BPL_NIVVAL")],;
                     oGet37:aCols[oGet37:Linha(),oGet37:PlRetPos("BPL_VIGDE")],;
                     ctod("")})
                                                    
      nTamCols   := Len(aVetDelBNK)
      aDel(aVetDelBNK,nPosScan)
      aSize(aVetDelBNK,nTamCols-1)
   Endif
Endif

Return(.T.)


/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑uncao    � PLSBPLWhen � Autor � Michele Tatagiba    � Data � 22.08.02 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escricao � Valida o X3_WHEN para os campos do BPL.                    낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
Function PLSBPLWhen(cTipo)

LOCAL lRet    := .T.
DEFAULT cTipo := ""
/*
If M->BPL_FLAG == "1" .And. Empty(cTipo)
   lRet := .F.
Endif
*/
If lRet .And. cTipo == "V" .And. !Empty(M->BPL_PERMAT)
   lRet := .F.
Endif

If lRet .And. cTipo == "P" .And. !Empty(M->BPL_VLRMAT)
   lRet := .F.
Endif

If lRet .And. cTipo == "N" .And. (!Empty(M->BPL_PERMAT) .Or. !Empty(M->BPL_VLRMAT))
   lRet := .F.
Endif

Return(lRet)


/*                   
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑uncao    � PLSBPLRet  � Autor � Michele Tatagiba    � Data � 02.10.02 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escricao � Retorna a data da vigencia em aberto dos Materiais         낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿛arametros� cCampo - Campo que vai ser retornado                       낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
Function PLSBPLRet(cCampo)
    
LOCAL cConteu
LOCAL lRet   := .F.

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
      
BS6->(DBSetOrder(1))
If BS6->(DBSeek(xFilial("BS6")+M->BPL_CODINT+M->BPL_CODTAB+M->BPL_CODMAT))
   While !BS6->(EOF()) .And. xFilial("BS6")+M->BPL_CODINT+M->BPL_CODTAB+M->BPL_CODMAT == BS6->(BS6_FILIAL+BS6_CODINT+BS6_CODTAB+BS6_MACODI) .And.;
         !lRet
         If Empty(BS6->BS6_VIGATE)
            cConteu := &(cCampo)
            lRet    := .T.
         Endif
   BS6->(DBSkip())
   Enddo
Endif

Return(cConteu)


/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑uncao    � PLSPOSBNK  � Autor � Michele Tatagiba    � Data � 02.10.02 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escricao � Verifica se ja existe vigencia para esse registro e se     낢�
굇�          � essa esta e menor que a que esta sendo digitada            낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
Function PLSPOSBNK()

LOCAL lRet := .T.

BNK->(DBSetOrder(2))
BNK->(DBSeek(xFilial("BNK")+cCodigo+cCodInt+cCodLoc+M->BPL_CODTAB+M->BPL_CODMAT))
If M->BPL_VIGDE < BNK->BNK_DATDE
   MsgInfo(STR0005+dtoc(BNC->BNC_DATDE)+STR0006) //"A data de vigencia do Material e menor que a data inicial("###") da vigencia anterior."
   lRet := .F.
Endif


Return(lRet)
