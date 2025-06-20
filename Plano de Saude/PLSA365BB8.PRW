#INCLUDE "plsa365bb8.ch"

#include "PROTHEUS.CH"
#include "PLSMGER.CH"

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� As funcoes abaixo sao utilizadas no browse de U.S no cadastro de Local de Atd.  |
//� Sao chamadas na validacao e exclusao de uma linha do Browse oGet07              |
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�


/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑uncao    � PLSBB8VLD  � Autor � Michele Tatagiba    � Data � 20.08.02 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escricao � Valida uma acao no browse de Local de Atendimento          낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
Function PLSBB8Vld()

LOCAL lRet       := .T.
LOCAL nPosScan   := 0 
M->BB8_CODIGO := ccodigo
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Caso nao tenha sido informado nenhum valor de U.S                             |
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
If M->BB8_VALCH == 0 .And. Empty(M->BB8_EXPRES)
   Return(.T.)
Endif

If M->BB8_VALCH <> 0 .And. Empty(dtos(M->BB8_VIGUS))
   MsgInfo(STR0001) //"Informe uma data de vigencia para o valor da US."
   Return(.F.)
Endif

If M->BB8_VALCH == 0 .And. Empty(M->BB8_EXPRES)
   MsgInfo(STR0002) //"Informe se o nivel zero e valido."
   Return(.F.)
Endif
          
BN8->(DBSetOrder(1))
If BN8->(DBSeek(xFilial("BN8")+cCodigo+M->BB8_CODINT+M->BB8_CODLOC))
   //If M->BB8_VIGUS < BN8->BN8_DATDE
      //MsgInfo(STR0003+dtoc(BN8->BN8_DATDE)) //"A data de vigencia da US e menor que a ultima data de vigencia "
      //Return(.F.)
   //Else                  
      //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
      //� Caso a data de vigencia seja igual a data de, entao verifico o valor da US    |
      //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
      //If M->BB8_VIGUS == BN8->BN8_DATDE
         //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
         //� Se o valor da US for diferente, nao consigo colocar a data final  |
         //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
         //If M->BB8_VALCH <> BN8->BN8_VLRUS
        	//MsgInfo(STR0004) //"A data de vigencia da US e igual a data da vigencia anterior."
       	    //Return(.F.)
         //Else
       	 //   lRet := .T.
            //Endif
         //Else
         //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
         //� Crio uma nova vigencia de US                                      |
         //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
         nPosScan := aScan(aVetBN8,{|x| x[2] == M->BB8_CODINT .And. x[3] == M->BB8_CODLOC})
         If nPosScan == 0
            aadd(aVetBN8,{cCodigo,M->BB8_CODINT,M->BB8_CODLOC,M->BB8_VALCH,M->BB8_FORMUL,M->BB8_EXPRES,"",M->BB8_VIGUS,ctod("")})
         Else
            aVetBN8[nPosScan,4] := If(M->BB8_FORMUL == "1", M->BB8_VALCH,0)
            aVetBN8[nPosScan,5] := M->BB8_FORMUL
            aVetBN8[nPosScan,6] := If(M->BB8_FORMUL == "2" ,M->BB8_EXPRES, "")
            aVetBN8[nPosScan,7] := ""
            aVetBN8[nPosScan,8] := M->BB8_VIGUS
         Endif
            
         lRet := .T.
      //Endif
   //Endif
Else
   //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
   //� Crio uma nova vigencia de US                                      |
   //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
   nPosScan := aScan(aVetBN8,{|x| x[2] == M->BB8_CODINT .And. x[3] == M->BB8_CODLOC})
   If nPosScan == 0
      aadd(aVetBN8,{cCodigo,M->BB8_CODINT,M->BB8_CODLOC,M->BB8_VALCH,M->BB8_FORMUL,M->BB8_EXPRES,"",M->BB8_VIGUS,ctod("")})
   Else
      aVetBN8[nPosScan,4] := If(M->BB8_FORMUL == "1", M->BB8_VALCH,0)
      aVetBN8[nPosScan,5] := M->BB8_FORMUL
      aVetBN8[nPosScan,6] := If(M->BB8_FORMUL == "2" ,M->BB8_EXPRES, "")
      aVetBN8[nPosScan,7] := ""
      aVetBN8[nPosScan,8] := M->BB8_VIGUS
   Endif
   lRet := .T. 
Endif


Return(lRet)

/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑uncao    � PLSBB8Del  � Autor � Michele Tatagiba    � Data � 22.08.02 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escricao � Valida a exclusao de uma linha no browse de Local de Atend.낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
Function PLSBB8Del()                                   

LOCAL nPosScan
LOCAL nTamCols := 1

nPosScan := aScan(aVetBN8,{|x| x[1] == cCodigo .And. x[2] == cCodInt .And.;
            x[3] == oGet07:aCols[oGet07:Linha(),oGet07:PlRetPos("BB8_CODLOC")]})
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Se for exclusao da linha, tiro o dado do vetor                    |
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�      
If oGet07:aCols[oGet07:Linha(),Len(oGet07:aHeader)+1]
   If nPosScan <> 0
      aadd(aVetDelBN8,aVetBN8[nPosScan])
      nTamCols   := Len(aVetBN8)
      aDel(aVetBN8,nPosScan)
      aSize(aVetBN8,nTamCols-1)
   Endif
Else
   //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
   //� Se for retirar a exclusao, tenho que verificar se os dados daquele linha estavam no vetor   |
   //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
   nPosScan := aScan(aVetDelBN8,{|x| x[1] == cCodigo .And. x[2] == cCodInt .And.;
                x[3] == oGet07:aCols[oGet07:Linha(),oGet07:PlRetPos("BB8_CODLOC")]})
   If nPosScan <> 0
      aadd(aVetBN8,{cCodigo,cCodInt,oGet07:aCols[oGet07:Linha(),oGet07:PlRetPos("BB8_CODLOC")],;
                     oGet07:aCols[oGet07:Linha(),oGet07:PlRetPos("BB8_VALCH")],;
                     oGet07:aCols[oGet07:Linha(),oGet07:PlRetPos("BB8_FORMUL")],;
                     oGet07:aCols[oGet07:Linha(),oGet07:PlRetPos("BB8_EXPRES")],;
                     "",;
                     oGet07:aCols[oGet07:Linha(),oGet07:PlRetPos("BB8_VIGUS")],;
                     ctod("")})
                                                    
      nTamCols   := Len(aVetDelBN8)
      aDel(aVetDelBN8,nPosScan)
      aSize(aVetDelBN8,nTamCols-1)
   Endif
Endif


Return(.T.)

/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑uncao    � PLSBB8When � Autor � Michele Tatagiba    � Data � 22.08.02 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escricao � Valida o X3_WHEN para os campos do BB8.                    낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
Function PLSBB8When(cTipo)

LOCAL lRet    := .T.
DEFAULT cTipo := ""

/*
If M->BB8_FLAG == "1" .And. Empty(cTipo)
   lRet := .F.
Endif
*/
If lRet .And. cTipo == "1" .And. M->BB8_FORMUL == "2"
   M->BB8_VALCH  := 0
   lRet := .F.
Endif

If lRet .And. cTipo == "2" .And. M->BB8_FORMUL == "1"
   M->BB8_EXPRES := ""
   lRet := .F.
Endif

If lRet .And. cTipo == "N" .And. (!Empty(M->BB8_VALCH) .Or. !Empty(M->BB8_EXPRES))
   lRet := .F.
Endif

Return(lRet)


Function PLSPOSBN8()

LOCAL lRet := .T.

//BN8->(DBSetOrder(2))
//BN8->(DBSeek(xFilial("BN8")+cCodigo+cCodInt+M->BB8_CODLOC))
//If M->BB8_VIGUS < BN8->BN8_DATDE
//   MsgInfo(STR0005+dtoc(BN8->BN8_DATDE)+STR0006) //"A data de vigencia da US e menor que a data inicial("###") da vigencia anterior."
//   lRet := .F.
//Endif


Return(lRet)
