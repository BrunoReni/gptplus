#INCLUDE "plsa365bp6.ch"

#include "PROTHEUS.CH"
#include "PLSMGER.CH"


//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� As funcoes abaixo sao utilizadas no browse de Taxas para uma operadora. |
//� Sao chamadas na validacao e exclusao de uma linha do Browse oGet13      |
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�



/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑uncao    � PLSBP6Vld  � Autor � Michele Tatagiba    � Data � 22.08.02 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escricao � Valida a inclusao de uma linha no browse de Taxas da Opera 낢�
굇�          � dora.                                                      낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
Function PLSBP6Vld()

LOCAL lRet       := .T.
LOCAL lRetBP6    := .T.
LOCAL nPosScan   := 0

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Se foi informado o valor da taxa, e obrigatorio informar qual a Un.Med. |
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
If M->BP6_VLRTAX <> 0 .And. Empty(M->BP6_CODDOC)
   MsgInfo(STR0001) //"Informe uma Unidade de Medida de Valor para essa Taxa."
   Return(.F.)
Endif

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Verifico se o nivel zero e valido                                       |
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
If M->BP6_VLRTAX == 0 .And. M->BP6_PERTAX == 0 .And. Empty(M->BP6_NIVVAL)
   MsgInfo(STR0002) //"Informe se o nivel zero e valido."
   Return(.F.)
Endif
          
BNA->(DBSetOrder(1))
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Verifico se existe alguma data de vigencia anterior a essa.             |
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
If BNA->(DBSeek(xFilial("BNA")+cCodigo+M->BP6_CODINT+M->BP6_CODTAX))
   If M->BP6_VIGDE < BNA->BNA_DATDE
      MsgInfo(STR0003+dtoc(BNA->BNA_DATDE)) //"A data de vigencia da Taxa e menor que a ultima data de vigencia "
      Return(.F.)
   Else                  
      //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
      //� Caso a data de vigencia seja igual a data de, entao verifico o valor da taxa  |
      //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
      If M->BP6_VIGDE == BNA->BNA_DATDE
         //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
         //� Se o valor da taxa for diferente, nao consigo colocar a data final|
         //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
         If M->BP6_VLRTAX <> BNA->BNA_VLRTAX
       	    MsgInfo(STR0004) //"A data de vigencia da taxa e igual a data da vigencia anterior."
       	    Return(.F.)
         Else           
            //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
            //� Se o percentual da taxa for diferente, nao consigo colocar a data final |
            //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�         
            If M->BP6_PERTAX <> BNA->BNA_PERTAX
         	   MsgInfo(STR0004) //"A data de vigencia da taxa e igual a data da vigencia anterior."
        	   Return(.F.)            
            Else            
        	   lRet := .T.
        	Endif
         Endif
      Else
         //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
         //� Crio uma nova vigencia de taxa                                    |
         //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
         nPosScan := aScan(aVetBNA,{|x| x[2] == M->BP6_CODINT .And. x[3] == M->BP6_CODTAX})
         If nPosScan == 0
            aadd(aVetBNA,{cCodigo,M->BP6_CODINT,M->BP6_CODTAX,M->BP6_SEQTAX,M->BP6_VIGTAX,M->BP6_VLRTAX,M->BP6_PERTAX,M->BP6_NIVVAL,M->BP6_CODDOC,M->BP6_VIGDE,ctod("")})
         Else
            aVetBNA[nPosScan,4]  := M->BP6_SEQTAX
            aVetBNA[nPosScan,5]  := M->BP6_VIGTAX
            aVetBNA[nPosScan,6]  := M->BP6_VLRTAX
            aVetBNA[nPosScan,7]  := M->BP6_PERTAX
            aVetBNA[nPosScan,8]  := M->BP6_NIVVAL
            aVetBNA[nPosScan,9]  := M->BP6_CODDOC
            aVetBNA[nPosScan,10] := M->BP6_VIGDE
         Endif
            
         lRet := .T.
      Endif
   Endif
Else
   //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
   //� Crio uma nova vigencia de taxa                                    |
   //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
   nPosScan := aScan(aVetBNA,{|x| x[2] == M->BP6_CODINT .And. x[3] == M->BP6_CODTAX})
   If nPosScan == 0
      aadd(aVetBNA,{cCodigo,M->BP6_CODINT,M->BP6_CODTAX,M->BP6_SEQTAX,M->BP6_VIGTAX,M->BP6_VLRTAX,M->BP6_PERTAX,M->BP6_NIVVAL,M->BP6_CODDOC,M->BP6_VIGDE,ctod("")})
   Else
      aVetBNA[nPosScan,4]  := M->BP6_SEQTAX
      aVetBNA[nPosScan,5]  := M->BP6_VIGTAX
      aVetBNA[nPosScan,6]  := M->BP6_VLRTAX
      aVetBNA[nPosScan,7]  := M->BP6_PERTAX
      aVetBNA[nPosScan,8]  := M->BP6_NIVVAL
      aVetBNA[nPosScan,9]  := M->BP6_CODDOC
      aVetBNA[nPosScan,10] := M->BP6_VIGDE
   Endif
   
   lRet := .T. 
Endif

Return(lRet)


/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑uncao    � PLSBP6Del  � Autor � Michele Tatagiba    � Data � 22.08.02 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escricao � Valida a exclusao de uma linha no browse de Taxas da Opera 낢�
굇�          � dora.                                                      낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
Function PLSBP6Del()

LOCAL nPosScan
LOCAL nTamCols := 1               
LOCAL lRet     := .T.

/*
If M->BP6_FLAG == "1"
   lRet := .F.
Endif
*/

nPosScan := aScan(aVetBNA,{|x| x[1] == cCodigo .And. x[2] == cCodInt .And.;
            x[3] == oGet13:aCols[oGet13:Linha(),oGet13:PlRetPos("BP6_CODTAX")]})
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Se for exclusao da linha, tiro o dado do vetor                    |
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�      
If oGet13:aCols[oGet13:Linha(),Len(oGet13:aHeader)+1]
   If nPosScan <> 0
      aadd(aVetDelBNA,aVetBNA[nPosScan])
      nTamCols   := Len(aVetBNA)
      aDel(aVetBNA,nPosScan)
      aSize(aVetBNA,nTamCols-1)
   Endif
Else
   //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
   //� Se for retirar a exclusao, tenho que verificar se os dados daquele linha estavam no vetor   |
   //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
   nPosScan := aScan(aVetBNA,{|x| x[1] == cCodigo .And. x[2] == cCodInt .And.;
                x[3] == oGet13:aCols[oGet13:Linha(),oGet13:PlRetPos("BP6_CODTAX")]})
                
   If nPosScan <> 0
      aadd(aVetBNA,{cCodigo,cCodInt,oGet13:aCols[oGet13:Linha(),oGet13:PlRetPos("BP6_CODTAX")],;
                     oGet13:aCols[oGet13:Linha(),oGet13:PlRetPos("BP6_SEQTAX")],;
                     oGet13:aCols[oGet13:Linha(),oGet13:PlRetPos("BP6_VIGTAX")],;
                     oGet13:aCols[oGet13:Linha(),oGet13:PlRetPos("BP6_VLRTAX")],;
                     oGet13:aCols[oGet13:Linha(),oGet13:PlRetPos("BP6_PERTAX")],;
                     oGet13:aCols[oGet13:Linha(),oGet13:PlRetPos("BP6_NIVVAL")],;
                     oGet13:aCols[oGet13:Linha(),oGet13:PlRetPos("BP6_CODDOC")],;
                     oGet13:aCols[oGet13:Linha(),oGet13:PlRetPos("BP6_VIGDE")],;
                     ctod("")})
                                                    
      nTamCols   := Len(aVetDelBNA)
      aDel(aVetDelBNA,nPosScan)
      aSize(aVetDelBNA,nTamCols-1)
   Endif
Endif

Return(.T.)


/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑uncao    � PLSBP6When � Autor � Michele Tatagiba    � Data � 22.08.02 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escricao � Valida o X3_WHEN para os campos do BP6.                    낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
Function PLSBP6When(cTipo)

LOCAL lRet    := .T.
DEFAULT cTipo := ""

/*
If M->BP6_FLAG == "1" .And. Empty(cTipo)
   lRet := .F.
Endif
*/

If lRet .And. cTipo == "V" .And. !Empty(M->BP6_PERTAX)
   M->BP6_NIVVAL := "0"
   lRet := .F.
Endif    

If lRet .And. cTipo == "P" .And. !Empty(M->BP6_VLRTAX)
   M->BP6_NIVVAL := "0"
   lRet := .F.
Endif

If lRet .And. cTipo == "N" .And. (!Empty(M->BP6_PERTAX) .Or. !Empty(M->BP6_VLRTAX))
   lRet := .F.
Endif

Return(lRet)             


/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑uncao    � PLSBP6Ret  � Autor � Michele Tatagiba    � Data � 02.10.02 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escricao � Retorna a data da vigencia em aberto da Taxa               낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿛arametros� cCampo - Campo que vai ser retornado                       낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
Function PLSBP6Ret(cCampo)
    
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
      
BLP->(DBSetOrder(1))
If BLP->(DBSeek(xFilial("BLP")+M->BP6_CODINT+M->BP6_CODTAX))
   While !BLP->(EOF()) .And. xFilial("BLP")+M->BP6_CODINT+M->BP6_CODTAX == BLP->(BLP_FILIAL+BLP_CODINT+BLP_CODTAX) .And.;
         !lRet
         If Empty(BLP->BLP_VIGATE)
            cConteu := &(cCampo)
            lRet    := .T.
         Endif
   BLP->(DBSkip())
   Enddo
Endif

Return(cConteu)


/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑uncao    � PLSPOSBNA  � Autor � Michele Tatagiba    � Data � 02.10.02 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escricao � Verifica se ja existe vigencia para esse registro e se     낢�
굇�          � essa esta e menor que a que esta sendo digitada            낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
Function PLSPOSBNA()

LOCAL lRet := .T.

BNA->(DBSetOrder(2))
BNA->(DBSeek(xFilial("BNA")+cCodigo+cCodInt+M->BP6_CODTAX))
If M->BP6_VIGDE < BNA->BNA_DATDE
   MsgInfo(STR0005+dtoc(BNA->BNA_DATDE)+STR0006) //"A data de vigencia da Taxa e menor que a data inicial("###") da vigencia anterior."
   lRet := .F.
Endif


Return(lRet)
