#INCLUDE "EECFATNF.ch"

/*
Programa        : EECFATNF
Objetivo        : Gravar Notas Fiscais de Complemento
Autor           : Cristiano A. Ferreira
Data/Hora       : 26/06/2000 15:35
Parametros      : aParamIXB
                  aParamIXB[1] := aCab (idem mata410)
                  aParamIXB[2] := nOpc (idem mata410)
Retorno         : .T./.F.
                  .T., processamento ok
                  .F., erro
Obs.            :
*/

#include "EECRDM.CH"

/*
Funcao      : EECFATNF
Parametros  : 
Retorno     : 
Objetivos   : 
Autor       : Cristiano A. Ferreira 
Data/Hora   : 26/06/2000 15:35      
Revisao     :
Obs.        : Convertido por CCF em 11/09/2000
*/

Function EECFATNF(aArray)

Local lRet := .F., nAliasOld := Select()
Local aCab
Local nOpc, nPreEmb, nTipoCad, nNF, nTipoNF
Local cPreEmb, cNF, cTipoNF, cField
Local lExist, I

Begin Sequence
   /*
   Exemplo de chamada do Rdmake:

   aCab := {}
   aAdd(aCab,{"EEM_TIPOCA","N",nil}) // Nota Fiscal (obrigatorio)
   aAdd(aCab,{"EEM_PREEMB",SC5->C5_PEDEXP,nil}) // Nro.do Embarque (obrigatorio)
   aAdd(aCab,{"EEM_TIPONF","2",nil}) // Tipo de Nota 2-Complementar (obrigatorio)
   aAdd(aCab,{"EEM_NRNF",cNumerodaNota,nil}) // (obrigatorio)
   aAdd(aCab,{"EEM_SERIE",cSeriedaNota,nil})
   aAdd(aCab,{"EEM_DTNF",dDataNF,nil})
   aAdd(aCab,{"EEM_VLNF",nValordaNota,nil}) // (obrigatorio)
   aAdd(aCab,{"EEM_VLMERC",nValordasMerc,nil}) // (obrigatorio)
   aAdd(aCab,{"EEM_VLFRET",nValorFrete,nil})
   aAdd(aCab,{"EEM_VLSEGU",nValorSegur,nil})
   aAdd(aCab,{"EEM_OUTROS",nValordasOutrosDespesas,nil})

   nOpc := 3 // para Inclusao
   ou
   nOpc := 5 // para Estorno

   IF EasyEntryPoint("EECFATNF")
      lOk := ExecBlock("EECFATNF",.F.,.F.,{aCab,nOpc})
   Endif
   */

   nAliasOld := Select()

   // Abre Arquivos do SIGAEEC
   IF Select("EEC") == 0
      ChkFile("EEC")
   Endif

   IF Select("EEM") == 0
      ChkFile("EEM")
   Endif

   lRet := .f.

   IF ValType(aArray) <> "A" .Or. Len(aArray) < 2
      HELP(" ",1,"AVG0005031") //MsgStop("Falta alguns parametros para a execu��o !","EECFATNF - Erro")
      Break
   Endif
      
   aCab := aArray[1]
   nOpc := aArray[2]

   nPreEmb := aScan(aCab,{|x| Upper(AllTrim(x[1])) == "EEM_PREEMB"})
   
   IF nPreEmb == 0
      HELP(" ",1,"AVG0005032") //MsgStop("Processo � obrigat�rio para a execu��o !","EECFATNF - Erro")
      Break
   Endif   
   
   cPreEmb := aCab[nPreEmb][2]
   
   EEC->(dbSetOrder(1))
   IF ! EEC->(dbSeek(xFilial()+cPreEmb))
      MsgStop(STR0001+cPreEmb+STR0002,STR0003) //"Processo Nro. "###" n�o cadastrado !"###"EECFATNF - Erro"
      Break
   Endif
   
   nTipoCad := aScan(aCab,{|x| Upper(AllTrim(x[1])) == "EEM_TIPOCA"})
   
   IF nTipoCad == 0
      HELP(" ",1,"AVG0005033") //MsgStop("EEM_TIPOCA � obrigat�rio para a execu��o !","EECFATNF - Erro")
      Break
   Endif   
   
   cTipoCad := aCab[nTipoCad][2]
   
   nNF := aScan(aCab,{|x| Upper(AllTrim(x[1])) == "EEM_NRNF"})
   
   IF nNF == 0
      HELP(" ",1,"AVG0005034") //MsgStop("Nro. da Nota � obrigat�rio para a execu��o !","EECFATNF - Erro")
      Break
   Endif   
   
   cNF := aCab[nNF][2]
   
   nTipoNF := aScan(aCab,{|x| Upper(AllTrim(x[1])) == "EEM_TIPONF"})
   
   IF nTipoNF == 0
      HELP(" ",1,"AVG0005035") //MsgStop("EEM_TIPONF � obrigat�rio para a execu��o !","EECFATNF - Erro")
      Break
   Endif   
   
   cTipoNF := aCab[nTipoNF][2]
   
   EEM->(dbSetOrder(1))
   lExist := EEM->(dbSeek(xFilial()+AvKey(cPreEmb,"EEM_PREEMB")+AvKey(cTipoCad,"EEM_TIPOCA")+AvKey(cNF,"EEM_NRNF")+AvKey(cTipoNF,"EEM_TIPONF")))
   
   IF nOpc == 3
      IF lExist
         HELP(" ",1,"AVG0000634") //MsgStop("Nota j� cadastrada !","EECFATNF - Erro")
         Break
      Endif
      
      EEM->(RecLock("EEM",.T.))
      
      For i:=1 to Len(aCab)
         cField := aCab[i][1]
         
         IF cField $ "EEM_VLMERC/EEM_VLNF"
            IF ! (aCab[i][2] > 0)
               HELP(" ",1,"AVG0005036") //MsgStop("Erro no valor da nota/valor da mercadoria !","EECFATNF")
               Break
            Endif
         Endif
         
         Eval(FieldWBlock(cField,Select("EEM")),aCab[i][2])
      Next i
      
      EEM->EEM_FILIAL := xFilial("EEM")
      
      //RMD - 24/02/15 - Projeto Chave NF
      SerieNfId("EEM",1,"EEM_SERIE",,,,EEM->EEM_SERIE)
      
      EEM->(MsUnlock())
      
   Else 
      IF ! lExist
         HELP(" ",1,"AVG0005037") //MsgStop("Nota n�o cadastrada !","EECFATNF - Erro")
         Break
      Endif
      
      EEM->(RecLock("EEM",.F.))
      EEM->(dbDelete())
      EEM->(MsUnlock())
   Endif   
      
   lRet := .t. 
   
End Sequence

Select(nAliasOld)

Return lRet

*------------------------------------------------------------------------------*
* FIM DO PROGRAMA EECFATNF.PRW                                                 *
*------------------------------------------------------------------------------*

