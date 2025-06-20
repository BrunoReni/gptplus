
#include "PROTHEUS.CH"
#include "PLSMGER.CH"


//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� As funcoes abaixo sao utilizadas no browse de Material de uma operadora.|
//� Sao chamadas na validacao e exclusao de uma linha do Browse oGet30      |
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�


/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑uncao    � PLSBPDVld  � Autor � Michele Tatagiba    � Data � 02.10.02 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escricao � Valida a inclusao de uma linha no browse de Material da    낢�
굇�          � Operadora                                                  낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
Function PLSBPDVld()

LOCAL lRet       := .T.
LOCAL lRetBPD    := .T.
LOCAL nPosScan   := 0 

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Se foi informado uma valor, e obrigatorio o codigo da Unidade de Medida |
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
If M->BPD_VLRMAT <> 0 .And. Empty(M->BPD_CODDOC)
   MsgInfo("Informe uma Unidade de Medida de Valor para esse Material.")
   Return(.F.)
Endif

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Verifico se o nivel zero e valido                                       |
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
If M->BPD_VLRMAT == 0 .And. M->BPD_PERMAT == 0 .And. Empty(M->BPD_NIVVAL)
   MsgInfo("Informe se o nivel zero e valido.")
   Return(.F.)
Endif
          
BNE->(DBSetOrder(1))
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Verifico se existe alguma data de vigencia anterior a essa.             |
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
If BNE->(DBSeek(xFilial("BNE")+cCodigo+M->BPD_CODINT+M->BPD_CODTAB+M->BPD_CODMAT))
   If M->BPD_VIGDE < BNE->BNE_DATDE
      MsgInfo("A data de vigencia do Material e menor que a ultima data de vigencia "+dtoc(BNE->BNE_DATDE))
      Return(.F.)
   Else                  
      //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
      //� Caso a data de vigencia seja igual a data de, entao verifico o valor do Material        |
      //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
      If M->BPD_VIGDE == BNE->BNE_DATDE
         //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
         //� Se o valor do Material for diferente, nao consigo colocar a data final        |
         //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
         If M->BPD_VLRMAT <> BNE->BNE_VLRMAT
       	    MsgInfo("A data de vigencia do Material e igual a data da vigencia anterior.")
       	    Return(.F.)
         Else           
            //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
            //� Se o percentual do Material for diferente, nao consigo colocar a data final   |
            //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�         
            If M->BPD_PERMAT <> BNE->BNE_PERMAT
         	   MsgInfo("A data de vigencia do Material e igual a data da vigencia anterior.")
         	   Return(.F.)
            Else            
        	   lRet := .T.
        	Endif
         Endif
      Else
         //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
         //� Crio uma nova vigencia de Material                                |
         //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
         nPosScan := aScan(aVetBNE,{|x| x[2] == M->BPD_CODINT .And. x[3] == M->BPD_CODTAB .And. x[4] == M->BPD_CODMAT })
         If nPosScan == 0
            aadd(aVetBNE,{cCodigo,M->BPD_CODINT,M->BPD_CODTAB,M->BPD_CODMAT,M->BPD_SEQMAT,M->BPD_VIGMAT,M->BPD_VLRMAT,M->BPD_MATIPO,M->BPD_CODDOC,M->BPD_PERMAT,M->BPD_NIVVAL,M->BPD_VIGDE,ctod("")})
         Else
            aVetBNE[nPosScan,5]  := M->BPD_SEQMAT
            aVetBNE[nPosScan,6]  := M->BPD_VIGMAT
            aVetBNE[nPosScan,7]  := M->BPD_VLRMAT
            aVetBNE[nPosScan,8]  := M->BPD_MATIPO
            aVetBNE[nPosScan,9]  := M->BPD_CODDOC
            aVetBNE[nPosScan,10] := M->BPD_PERMAT
            aVetBNE[nPosScan,11] := M->BPD_NIVVAL
            aVetBNE[nPosScan,12] := M->BPD_VIGDE
         Endif
            
         lRet := .T.
      Endif
   Endif
Else
   //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
   //� Crio uma nova vigencia de Material                                |
   //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
   nPosScan := aScan(aVetBNE,{|x| x[2] == M->BPD_CODINT .And. x[3] == M->BPD_CODTAB .And. x[4] == M->BPD_CODMAT })
   If nPosScan == 0
      aadd(aVetBNE,{cCodigo,M->BPD_CODINT,M->BPD_CODTAB,M->BPD_CODMAT,M->BPD_SEQMAT,M->BPD_VIGMAT,M->BPD_VLRMAT,M->BPD_MATIPO,M->BPD_CODDOC,M->BPD_PERMAT,M->BPD_NIVVAL,M->BPD_VIGDE,ctod("")})
   Else
      aVetBNE[nPosScan,5]  := M->BPD_SEQMAT
      aVetBNE[nPosScan,6]  := M->BPD_VIGMAT
      aVetBNE[nPosScan,7]  := M->BPD_VLRMAT
      aVetBNE[nPosScan,8]  := M->BPD_MATIPO
      aVetBNE[nPosScan,9]  := M->BPD_CODDOC
      aVetBNE[nPosScan,10] := M->BPD_PERMAT
      aVetBNE[nPosScan,11] := M->BPD_NIVVAL
      aVetBNE[nPosScan,12] := M->BPD_VIGDE
   Endif
                     
   lRet := .T.
Endif

Return(lRet)


/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑uncao    � PLSBPDDel  � Autor � Michele Tatagiba    � Data � 22.08.02 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escricao � Valida a exclusao de uma linha no browse de Materiais da   낢�
굇�          � Operadora                                                  낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
Function PLSBPDDel()

LOCAL nPosScan
LOCAL nTamCols := 1
/*
If M->BPD_FLAG == "1"
   lRet := .F.
Endif
*/
nPosScan := aScan(aVetBNE,{|x| x[1] == cCodigo .And. x[2] == cCodInt .And.;
            x[3] == oGet30:aCols[oGet30:Linha(),oGet30:PlRetPos("BPD_CODTAB")] .And.;
            x[4] == oGet30:aCols[oGet30:Linha(),oGet30:PlRetPos("BPD_CODMAT")]})
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Se for exclusao da linha, tiro o dado do vetor                    |
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�      
If oGet30:aCols[oGet30:Linha(),Len(oGet30:aHeader)+1]
   If nPosScan <> 0
      aadd(aVetDelBNE,aVetBNE[nPosScan])
      nTamCols   := Len(aVetBNE)
      aDel(aVetBNE,nPosScan)
      aSize(aVetBNE,nTamCols-1)
   Endif
Else
   //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
   //� Se for retirar a exclusao, tenho que verificar se os dados daquele linha estavam no vetor   |
   //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
   nPosScan := aScan(aVetBNE,{|x| x[1] == cCodigo .And. x[2] == cCodInt .And.;
                x[3] == oGet30:aCols[oGet30:Linha(),oGet30:PlRetPos("BPD_CODTAB")] .And.;
                x[4] == oGet30:aCols[oGet30:Linha(),oGet30:PlRetPos("BPD_CODMAT")]})
                
   If nPosScan <> 0
      aadd(aVetBNE,{cCodigo,cCodInt,oGet30:aCols[oGet30:Linha(),oGet30:PlRetPos("BPD_CODTAB")],;
                     oGet30:aCols[oGet30:Linha(),oGet30:PlRetPos("BPD_CODMAT")],;
                     oGet30:aCols[oGet30:Linha(),oGet30:PlRetPos("BPD_SEQMAT")],;
                     oGet30:aCols[oGet30:Linha(),oGet30:PlRetPos("BPD_VIGMAT")],;
                     oGet30:aCols[oGet30:Linha(),oGet30:PlRetPos("BPD_VLRMAT")],;
                     oGet30:aCols[oGet30:Linha(),oGet30:PlRetPos("BPD_MATIPO")],;
                     oGet30:aCols[oGet30:Linha(),oGet30:PlRetPos("BPD_CODDOC")],;
                     oGet30:aCols[oGet30:Linha(),oGet30:PlRetPos("BPD_PERMAT")],;
                     oGet30:aCols[oGet30:Linha(),oGet30:PlRetPos("BPD_NIVVAL")],;
                     oGet30:aCols[oGet30:Linha(),oGet30:PlRetPos("BPD_VIGDE")],;
                     ctod("")})
                                                    
      nTamCols   := Len(aVetDelBNE)
      aDel(aVetDelBNE,nPosScan)
      aSize(aVetDelBNE,nTamCols-1)
   Endif
Endif

Return(.T.)


/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑uncao    � PLSBPDWhen � Autor � Michele Tatagiba    � Data � 22.08.02 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escricao � Valida o X3_WHEN para os campos do BPD.                    낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
Function PLSBPDWhen(cTipo)

LOCAL lRet    := .T.
DEFAULT cTipo := ""
/*
If M->BPD_FLAG == "1" .And. Empty(cTipo)
   lRet := .F.
Endif
*/
If lRet .And. cTipo == "V" .And. !Empty(M->BPD_PERMAT)
   lRet := .F.
Endif

If lRet .And. cTipo == "P" .And. !Empty(M->BPD_VLRMAT)
   lRet := .F.
Endif

If lRet .And. cTipo == "N" .And. (!Empty(M->BPD_PERMAT) .Or. !Empty(M->BPD_VLRMAT))
   lRet := .F.
Endif

Return(lRet)


/*                   
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑uncao    � PLSBPDRet  � Autor � Michele Tatagiba    � Data � 02.10.02 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escricao � Retorna a data da vigencia em aberto do Material           낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿛arametros� cCampo - Campo que vai ser retornado                       낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
Function PLSBPDRet(cCampo)
    
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
      
BS6->(DBSetOrder(1))
If BS6->(DBSeek(xFilial("BS6")+M->BPD_CODINT+M->BPD_CODTAB+M->BPD_CODMAT))
   While !BS6->(EOF()) .And. xFilial("BS6")+M->BPD_CODINT+M->BPD_CODTAB+M->BPD_CODMAT == BS6->(BS6_FILIAL+BS6_CODINT+BS6_CODTAB+BS6_MACODI) .And.;
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
굇쿑uncao    � PLSPOSBNE  � Autor � Michele Tatagiba    � Data � 02.10.02 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escricao � Verifica se ja existe vigencia para esse registro e se     낢�
굇�          � essa esta e menor que a que esta sendo digitada            낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
Function PLSPOSBNE()

LOCAL lRet := .T.

BNE->(DBSetOrder(2))
BNE->(DBSeek(xFilial("BNE")+cCodigo+cCodInt+M->BPD_CODTAB+M->BPD_CODMAT))
If M->BPD_VIGDE < BNE->BNE_DATDE
   MsgInfo("A data de vigencia do Material e menor que a data inicial("+dtoc(BNC->BNC_DATDE)+") da vigencia anterior.")
   lRet := .F.
Endif


Return(lRet)
