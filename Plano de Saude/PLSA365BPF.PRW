
#include "PROTHEUS.CH"
#include "PLSMGER.CH"


//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� As funcoes abaixo sao utilizadas no browse de Porte Anestesico de uma operadora  |
//� Sao chamadas na validacao e exclusao de uma linha do Browse oGet32               |
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸

/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑uncao    � PLSBPFVld  � Autor � Michele Tatagiba    � Data � 02.10.02 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escricao � Valida a inclusao de uma linha no browse de Porte          낢�
굇�          � Anestesico na Operadora                                    낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
Function PLSBPFVld()

LOCAL lRet       := .T.
LOCAL lRetBPF    := .T.
LOCAL nPosScan   := 0 

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Se foi informado uma valor, e obrigatorio o codigo da Unidade de Medida |
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
If M->BPF_VLRPOR <> 0 .And. Empty(M->BPF_CODDOC)
   MsgInfo("Informe uma Unidade de Medida de Valor para esse Porte Anestesico.")
   Return(.F.)
Endif

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Verifico se o nivel zero e valido                                       |
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
If M->BPF_VLRPOR == 0 .And. M->BPF_PERPOR == 0 .And. Empty(M->BPF_NIVVAL)
   MsgInfo("Informe se o nivel zero e valido.")
   Return(.F.)
Endif
          
BNH->(DBSetOrder(1))
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Verifico se existe alguma data de vigencia anterior a essa.             |
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
If BNH->(DBSeek(xFilial("BNH")+cCodigo+M->BPF_CODINT+Str(M->BPF_CODPOR,2)))
   If M->BPF_VIGDE < BNH->BNH_DATDE
      MsgInfo("A data de vigencia do Porte Anestesico e menor que a ultima data de vigencia "+dtoc(BNH->BNH_DATDE))
      Return(.F.)
   Else                  
      //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
      //� Caso a data de vigencia seja igual a data de, entao verifico o valor do Porte Anestesico|
      //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
      If M->BPF_VIGDE == BNH->BNH_DATDE
         //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
         //� Se o valor do Porte Anestesico for diferente, nao consigo colocar a data final        |
         //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
         If M->BPF_VLRPOR <> BNH->BNH_VLRPOR
       	    MsgInfo("A data de vigencia do Porte Anestesico e igual a data da vigencia anterior.")
       	    Return(.F.)
         Else           
            //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
            //� Se o percentual do Porte Anestesico for diferente, nao consigo colocar a data final   |
            //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�         
            If M->BPF_PERPOR <> BNH->BNH_PERPOR
         	   MsgInfo("A data de vigencia do Porte Anestesico e igual a data da vigencia anterior.")
        	   Return(.F.)
            Else            
        	   lRet := .T.
        	Endif
         Endif
      Else
         //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
         //� Crio uma nova vigencia de Porte Anestesico                        |
         //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
         nPosScan := aScan(aVetBNH,{|x| x[2] == M->BPF_CODINT .And. x[3] == M->BPF_CODPOR })
         If nPosScan == 0
            aadd(aVetBNH,{cCodigo,M->BPF_CODINT,M->BPF_CODPOR,M->BPF_SEQPOR,M->BPF_VLRPOR,M->BPF_VIGPOR,M->BPF_CODDOC,M->BPF_PERPOR,M->BPF_NIVVAL,M->BPF_VIGDE,ctod("")})
         Else
            aVetBNH[nPosScan,4]  := M->BPF_SEQPOR
            aVetBNH[nPosScan,5]  := M->BPF_VLRPOR
            aVetBNH[nPosScan,6]  := M->BPF_VIGPOR
            aVetBNH[nPosScan,7]  := M->BPF_CODDOC
            aVetBNH[nPosScan,8]  := M->BPF_PERPOR
            aVetBNH[nPosScan,9]  := M->BPF_NIVVAL
            aVetBNH[nPosScan,10] := M->BPF_VIGDE
         Endif
            
         lRet := .T.
      Endif
   Endif
Else
   //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
   //� Crio uma nova vigencia de Porte Anestesico                        |
   //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
   nPosScan := aScan(aVetBNH,{|x| x[2] == M->BPF_CODINT .And. x[3] == M->BPF_CODPOR })
   If nPosScan == 0
      aadd(aVetBNH,{cCodigo,M->BPF_CODINT,M->BPF_CODPOR,M->BPF_SEQPOR,M->BPF_VLRPOR,M->BPF_VIGPOR,M->BPF_CODDOC,M->BPF_PERPOR,M->BPF_NIVVAL,M->BPF_VIGDE,ctod("")})
   Else
      aVetBNH[nPosScan,4]  := M->BPF_SEQPOR
      aVetBNH[nPosScan,5]  := M->BPF_VLRPOR
      aVetBNH[nPosScan,6]  := M->BPF_VIGPOR
      aVetBNH[nPosScan,7]  := M->BPF_CODDOC
      aVetBNH[nPosScan,8]  := M->BPF_PERPOR
      aVetBNH[nPosScan,9]  := M->BPF_NIVVAL
      aVetBNH[nPosScan,10] := M->BPF_VIGDE
   Endif
                     
   lRet := .T.
Endif

Return(lRet)


/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑uncao    � PLSBPFDel  � Autor � Michele Tatagiba    � Data � 22.08.02 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escricao � Valida a exclusao de uma linha no browse de Porte          낢�
굇�          � Anestesico na Operadora                                    낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
Function PLSBPFDel()

LOCAL nPosScan
LOCAL nTamCols := 1
/*
If M->BPF_FLAG == "1"
   lRet := .F.
Endif
*/
nPosScan := aScan(aVetBNH,{|x| x[1] == cCodigo .And. x[2] == cCodInt .And.;
            x[3] == oGet32:aCols[oGet32:Linha(),oGet32:PlRetPos("BPF_CODPOR")]})
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Se for exclusao da linha, tiro o dado do vetor                    |
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�      
If oGet32:aCols[oGet32:Linha(),Len(oGet32:aHeader)+1]
   If nPosScan <> 0
      aadd(aVetDelBNH,aVetBNH[nPosScan])
      nTamCols   := Len(aVetBNH)
      aDel(aVetBNH,nPosScan)
      aSize(aVetBNH,nTamCols-1)
   Endif
Else
   //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
   //� Se for retirar a exclusao, tenho que verificar se os dados daquele linha estavam no vetor   |
   //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
   nPosScan := aScan(aVetBNH,{|x| x[1] == cCodigo .And. x[2] == cCodInt .And.;
                x[3] == oGet32:aCols[oGet32:Linha(),oGet32:PlRetPos("BPF_CODPOR")]})
                
   If nPosScan <> 0
      aadd(aVetBNH,{cCodigo,cCodInt,oGet32:aCols[oGet32:Linha(),oGet32:PlRetPos("BPF_CODPOR")],;
                     oGet32:aCols[oGet32:Linha(),oGet32:PlRetPos("BPF_VLRPOR")],;
                     oGet32:aCols[oGet32:Linha(),oGet32:PlRetPos("BPF_VIGPOR")],;
                     oGet32:aCols[oGet32:Linha(),oGet32:PlRetPos("BPF_CODDOC")],;
                     oGet32:aCols[oGet32:Linha(),oGet32:PlRetPos("BPF_PERPOR")],;
                     oGet32:aCols[oGet32:Linha(),oGet32:PlRetPos("BPF_NIVVAL")],;
                     oGet32:aCols[oGet32:Linha(),oGet32:PlRetPos("BPF_VIGDE")],;
                     ctod("")})
                                                    
      nTamCols   := Len(aVetDelBNH)
      aDel(aVetDelBNH,nPosScan)
      aSize(aVetDelBNH,nTamCols-1)
   Endif
Endif

Return(.T.)


/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑uncao    � PLSBPFWhen � Autor � Michele Tatagiba    � Data � 22.08.02 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escricao � Valida o X3_WHEN para os campos do BPF.                    낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
Function PLSBPFWhen(cTipo)

LOCAL lRet    := .T.
DEFAULT cTipo := ""
/*
If M->BPF_FLAG == "1" .And. Empty(cTipo)
   lRet := .F.
Endif
*/
If lRet .And. cTipo == "V" .And. !Empty(M->BPF_PERPOR)
   lRet := .F.
Endif

If lRet .And. cTipo == "P" .And. !Empty(M->BPF_VLRPOR)
   lRet := .F.
Endif

If lRet .And. cTipo == "N" .And. (!Empty(M->BPF_PERPOR) .Or. !Empty(M->BPF_VLRPOR))
   lRet := .F.
Endif

Return(lRet)

/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑uncao    � PLSBPFRet  � Autor � Michele Tatagiba    � Data � 02.10.02 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escricao � Retorna a data da vigencia em aberto do Porte Anestesico   낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿛arametros� cCampo - Campo que vai ser retornado                       낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
Function PLSBPFRet(cCampo)
    
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
      
BKF->(DBSetOrder(1))
If BKF->(DBSeek(xFilial("BKF")+M->BPF_CODINT+Str(M->BPF_CODPOR,2)))
   While !BKF->(EOF()) .And. xFilial("BKF")+M->BPF_CODINT+Str(M->BPF_CODPOR,2) == BKF->(BKF_FILIAL+BKF_CODINT+Str(BKF_PORTE,2)) .And.;
         !lRet
         If Empty(BKF->BKF_VIGATE)
            cConteu := &(cCampo)
            lRet    := .T.
         Endif
   BKF->(DBSkip())
   Enddo
Endif

Return(cConteu)


/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑uncao    � PLSPOSBNH  � Autor � Michele Tatagiba    � Data � 02.10.02 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escricao � Verifica se ja existe vigencia para esse registro e se     낢�
굇�          � essa esta e menor que a que esta sendo digitada            낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
Function PLSPOSBNH()

LOCAL lRet := .T.

BNH->(DBSetOrder(2))
BNH->(DBSeek(xFilial("BNH")+cCodigo+cCodInt+Str(M->BPF_CODPOR,2)))
If M->BPF_VIGDE < BNH->BNH_DATDE
   MsgInfo("A data de vigencia do Porte Anestesico e menor que a data inicial("+dtoc(BNH->BNH_DATDE)+") da vigencia anterior.")
   lRet := .F.
Endif


Return(lRet)
