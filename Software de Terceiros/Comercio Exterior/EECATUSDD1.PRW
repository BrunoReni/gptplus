
#INCLUDE "PROTHEUS.CH"
#Include "TOPCONN.CH"
#DEFINE ENTER CHR(13)+CHR(10)

Function EECAtuSdD1()

Local cTitlUpd := "ATUALIZA��O DOS SALDOS DE ENTRADA DE FIM ESPEC�FICO"
Local cDescUpd := "Esta rotina tem por objetivo atualizar os saldos dispon�veis dos itens das notas fiscais de entrada"+;
                  " (tipo de entrada definido como fim espec�fico de exporta��o) que possuam saldo a vincular aos itens"+;
                  " das notas fiscais de sa�da de exporta��o. � extremamente necess�rio fazer um backup das tabelas SD1"+;
                  " e EYY do banco de dados antes de prosseguir com esta atualiza��o!"
Private oProgress 
 
      oUpd            := AVUpdate01():New()
      oUpd:aChamados  := { {EEC, {||ExecuteAtu()}} }//MMM = (EIC,EEC,EDC,EFF,ECO) / XXX = RELEASE
      oUpd:cTitulo    := cTitlUpd
      oUpd:cDescricao := cDescUpd 
      oUpd:Init(,.F.)

return

/*
Funcao        : ExecuteAtu()
Parametros    :
Retorno       :
Objetivos     : Axecutar a atualiza��o com barra de status.
Autor         : NCF
Data/Hora     : AGO/2017
Revisao       :
Obs.          :
*/
Static Function ExecuteAtu()
Private oProgress := EasyProgress():New()
oProgress:SetProcess({|| ExecuteUPD() },'Processando verifica��o e atualiza��o dos saldos...') 
oProgress:Init() 

Return

Static Function ExecuteUPD()
Local i
Local cQuery, cCondAdic
Local cMsgLogFim := ""
Private cLogUPDSld := ""
/* Arquivo de Log */
cArq := "\Comex\LogNfRem" + DtoS(dDataBase) + "_" + SUBSTR(TIME(), 1, 2) + "_" + SUBSTR(TIME(), 4, 2) + "_" + SUBSTR(TIME(), 7, 2) + ".txt"
If File(cArq)
   FErase(cArq)
Endif
hFile:= EasyCreateFile(cArq)

cQuery:= "Select R_E_C_N_O_ as RECNO "
cQuery+= " From " + RetSqlName("EYY") + " EYY"
cQuery+= " Where " + IF(TcSrvType()<>"AS/400","EYY.D_E_L_E_T_ <> '*'","EYY.@DELETED@ <> '*'")

lAtuSD1 := AtuSLDSD1( hFile , @cLogUPDSld )

If !lAtuSD1
   cMsgLogFim += "N�o foi poss�vel atualizar a tabela de itens das notas fiscais de entrada com os saldos dispon�veis de remessa para exporta��o!"+ENTER+;
                 "Os saldos das notas fiscais n�o foram atualizados!"+ENTER+;
                 "Verifique o arquivo de log na pasta \Protheus_Data\comex do ambiente (arquivo 'lognfremAAAMMDD_HH_MM_SS.txt')"
   MsgStop(cMsgLogFim)
   cLogUPDSld += cMsgLogFim  
EndIf

If lAtuSD1
   //BEGIN TRANSACTION

      For i := 1 To 2
         cCondAdic   := If( i == 1, " AND EYY_D1ITEM <> ''", " AND EYY_D1ITEM = ''" )
         AtuNFRemExp( cQuery + cCondAdic , hFile, @cLogUPDSld, i )   
      Next i
      cLogUPDSld += "ATUALIZACAO FINALIZADA!"+ENTER+"Verifique o arquivo de log na pasta \Protheus_Data\comex do ambiente (arquivo 'lognfremAAAMMDD_HH_MM_SS.txt')" 

   //END TRANSACTION
EndIf

oUpd:cTexto += cLogUPDSld

FClose(hFile)

Return 


/*
Funcao        : AtuNFRemExp()
Parametros    :
Retorno       :
Objetivos     : Atualizar a base de dados, para contemplar os ajustes na rotina de nota fiscal de remessa com fim espec�fico de exporta��o
Autor         : WFS
Data/Hora     : jun/2016
Revisao       :
Obs.          :
*/
Static Function AtuNFRemExp( cQuery, hFile, cLogUPDSld, nVez )

//Local aFiliais:= {}
Local cDir:= "\Comex\"
Local lCp_Cod_I := .T.
Begin Sequence

   aOrdSX3 := SaveOrd("SX3")                                   //NCF - 17/03/2017 - Verifica��o tempor�ria de exist�ncia do campo no dicion�rio de dados para ativa��o (cliente Durli Couros)
   SX3->(DbSetOrder(2))                                        //                   Este trecho ser� posteriormente substitu�do ou retirado quando homologada a nova rotina de Vincula��o de NFs.
   If !SX3->(DbSeek("EYY_COD_I"))                              //                   O campo EYY_COD_I s� existe nos clientes que utilizam a nova rotina.
      lCp_Cod_I := .F.
   EndIf
   RestOrd(aOrdSX3,.T.)

   /* verificar se o ambiente est� atualizado para as altera��es da rotina */
   If !lCp_Cod_I .Or. EYY->(FieldPos("EYY_SEQEMB")) == 0 .Or. SD1->(FieldPos("D1_SLDEXP")) == 0
      MsgStop("Ambiente n�o preparado para executar a nova rotina de vincula��o de Notas Fiscais de entrada de fim espec�fico de exporta��o!"+ENTER+;
              "Os saldos das notas fiscais n�o ser�o atualizados!")
      Break
   EndIf
   
   If Select("EYYTMP") > 0
      EYYTMP->(dbCloseArea())
   End If

   cQuery:= ChangeQuery(cQuery)
   TcQuery cQuery Alias "EYYTMP" New

   EYYTMP->(DBGoTop())

   /* interromper, quando n�o houver registros */
   If EYYTMP->(Bof()) .And. EYYTMP->(Eof())
      EYYTMP->(DBCloseArea()) 
      cLogUPDSld += "N�o foram encontrados registros com saldo necess�rio a atualizar " +;
                    If(nVez == 1, "vinculados ao saldo do item da Nf de remessa", "vinculados ao saldo total da Nf de remessa" ) +;
                                  ", portanto n�o foi realizada nenhuma altera��o!" + ENTER
      Break
   EndIf

   /* in�cio da atualiza��o da carga de dados */
   EE9->(DBSetOrder(1)) //EE9_FILIAL+EE9_PEDIDO+EE9_SEQUEN+EE9_PREEMB+EE9_HOUSE
   SD1->(DBSetOrder(1)) //D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM

   EYYTMP->(DBGoTop())
   ntotRegAtu := EYYTMP->(EasyRecCount())
   oProgress:SetRegua(ntotRegAtu)
   
   While EYYTMP->(!Eof())

      cLogUPDSld:= " " + ENTER

      EYY->(DBGoTo(EYYTMP->RECNO))

      EYY->(RecLock("EYY", .F.))

      /* Atualiza��o da sequencia do embarque */
      IF Empty(EYY->EYY_SEQEMB) 
         EYY->EYY_SEQEMB := RetSeqEmb(@cLogUPDSld)
      EndIf
      EYY->EYY_D1ITEM := RetD1Item(EYY->EYY_D1ITEM, @cLogUPDSld )
      EYY->EYY_D1PROD := If(!Empty(EYY->EYY_D1ITEM) .And. Empty(EYY->EYY_D1PROD),SD1->D1_COD,"")
      EYY->(MsUnlock())

      FWrite(hFile, cLogUPDSld, Len(cLogUPDSld))

      EYYTMP->(DBSkip())
      
      If !oProgress:IncRegua()
         Break
      EndIf
   EndDo

   EYYTMP->(dbCloseArea())

End Sequence 

Return


/*
Funcao        : RetSeqEmb()
Parametros    :
Retorno       :
Objetivos     : Retornar a sequ�ncia do item no processo de embarque
Autor         : WFS
Data/Hora     : jun/2016
Revisao       :
Obs.          :
*/
Static Function RetSeqEmb(cLogUPDSld)
Local cSeqEmb:= ""
Local cChave
Local cQuery := ""

   Begin Sequence
     
      /* verificar se existem registros para serem atualizados
      ser�o considerados registros legados apenas os que n�o possuirem sequ�ncia do embarque e
      item da nota fiscal de entrada */
      If TcSrvType() <> "AS/400"
         cDelete := " And D_E_L_E_T_ <> '*'"
      EndIf

      cQuery   := "Select EE9_FILIAL, EE9_PEDIDO, EE9_SEQUEN, EE9_PREEMB, EE9_SEQEMB, EE9_NF, EE9_SERIE "

      cQuery   += " From " + RetSqlName("EE9")

      cWhere   := " Where EE9_FILIAL = '"+EYY->EYY_FILIAL+"'"+;
                  "   AND EE9_PEDIDO = '"+EYY->EYY_PEDIDO+"'"+;
                  "   AND EE9_SEQUEN = '"+EYY->EYY_SEQUEN+"'"+;
                  "   AND EE9_PREEMB = '"+EYY->EYY_PREEMB+"'"+;
                  "   AND EE9_NF     = '"+EYY->EYY_NFSAI +"'"+;
                  "   AND EE9_SERIE  = '"+EYY->EYY_SERSAI+"'"
      
      cOrderBy := " Order By EE9_FILIAL, EE9_PREEMB, EE9_PEDIDO, EE9_SEQUEN, EE9_SEQEMB"
      
      If SELECT("EE9TMP") > 0
         EE9TMP->(DBCloseArea())
      EndIf
      
      /* Montagem da Query */
      cQuery += cWhere + cDelete + cOrderBy
      cQuery:= ChangeQuery(cQuery)
      TcQuery cQuery Alias "EE9TMP" New

      EE9TMP->(DBGoTop())

      /* interromper, quando n�o houver registros */
      If EE9TMP->(Bof()) .And. EE9TMP->(Eof())
         EE9TMP->(DBCloseArea())
         Break
      EndIf
      
      While EE9TMP->(!Eof())
         cLogUPDSld += "Atualiza��o do registro EYY do processo " + AllTrim(EYY->EYY_PREEMB) +;
                 " pedido "                                 + AllTrim(EYY->EYY_PEDIDO) +;
                 " sequencia "                              + AllTrim(EYY->EYY_SEQUEN) +;
                 " com a sequencia de embarque "            + AllTrim(EE9->EE9_SEQEMB) + ENTER
         cSeqEmb:= EE9TMP->EE9_SEQEMB 
         EE9TMP->(DBSkip())        
      Enddo
   
   End Sequence   

   If Empty(cSeqEmb)
      cLogUPDSld += "N�o foi encontrada a sequ�ncia de embarque para o registro EYY do processo " + AllTrim(EYY->EYY_PREEMB) +;
              " pedido " + AllTrim(EYY->EYY_PEDIDO) +;
              " sequencia " + AllTrim(EYY->EYY_SEQUEN) + ENTER
   EndIf
Return cSeqEmb



/*
Funcao        : RetD1Item()
Parametros    :
Retorno       :
Objetivos     : Retornar a linha do item na nota fiscal de entrada
Autor         : WFS
Data/Hora     : jun/2016
Revisao       :
Obs.          :
*/
Static Function RetD1Item(cD1Item, cLogUPDSld)
Local cChave
Local nQtdCvExNF
Local aPosSD1   := {}, cChavAux 
Default cD1Item := ""

If EE9->(DBSeek(EYY->(EYY_FILIAL + EYY_PEDIDO + EYY_SEQUEN + EYY_PREEMB)))
   cChave:= EYY->(EYY_FILIAL + EYY_NFENT + EYY_SERENT + EYY_FORN + EYY_FOLOJA)
EndIf

If !Empty(cChave)
   aPosSD1  := PosItD1vinc(  cChave, cD1Item , EE9->EE9_COD_I, "PRODUTO" /*If( GetMv("MV_EEC0051",,.F.), "NCM" ,"PRODUTO" )*/ )
   If aPosSD1[1]
      SD1->(DbGoTo(aPosSD1[4]))
      cD1Item := aPosSD1[3]
      SD1->(RecLock("SD1", .F.))
      SD1->D1_SLDEXP -= aPosSD1[2]
      SD1->(MsUnlock())
      If AvFlags("ROTINA_VINC_FIM_ESPECIFICO_RP12.1.20")
         EYY->EYY_D1PROD := SD1->D1_COD
         EYY->EYY_POSIPI := If( !Empty(SD1->D1_TEC), SD1->D1_TEC , Posicione("SB1",1,xFilial("SB1")+SD1->D1_COD,"B1_POSIPI") )
         EYY->EYY_UNIDAD := EE9->EE9_UNIDAD
         EYY->EYY_UMDSD1 := SD1->D1_UM
      EndIf
      cLogUPDSld += GetMSgLog( 2 , aPosSD1[2] )        
   EndIf 
EndIf

If Empty(cD1Item)
   cLogUPDSld += GetMSgLog( 3 , 0 )
EndIf

Return cD1Item


/*
Funcao        : AtuSLDSD1()
Parametros    : cFilAtu - filial que ter� os itens de notas atualizados
Retorno       :
Objetivos     : atualizar o saldo do item dispon�vel para vincular a exporta��o
Autor         : WFS
Data/Hora     : jun/2016
Revisao       :
Obs.          :
*/
Static Function AtuSLDSD1( hFile, cLogUPDSld )
Local lRet := .F.
Local cQuery
Local cMsgError := ""

   //TCLink()

   cQuery := "UPDATE "+RetSqlName("SD1")+" SET D1_SLDEXP = D1_QUANT"
   cQuery += " WHERE " + IF(TcSrvType()<>"AS/400","D_E_L_E_T_ <> '*'","@DELETED@ <> '*'")
                   
   nStatus := TCSqlExec(cQuery)
   If !(lRet := !(nStatus < 0) )
      cMsgError := TCSQLError()
      conout( "TCSQLError() " + TCSQLError() )
      FWrite( hFile, "OCORREU UM PROBLEMA COM A ATUALIZA��O DA TABELA SD1 NO BANCO DE DADOS: " + cMsgError  , Len(cLogUPDSld) )
   EndIf
   
   //TCUnlink()

Return lRet


/*
Funcao        : PosItD1vinc()
Parametros    : cChaveEYY - Chave do item de remessa vinculado por capa ou item da Nfe
                cD1Item   - Item da NFe de remessa caso haja vincula��o por item
                cCod_I    - C�digo do Item de Ref. do embarque
                cTipo     - Conforme o par�metro MV_EEC0051 (T="NCM", F="PRODUTO")
Retorno       :
Objetivos     : atualizar o saldo do item dispon�vel para vincular a exporta��o
Autor         : NCF
Data/Hora     : 03/2018
Revisao       :
Obs.          :
*/
Static Function PosItD1vinc(  cChaveEYY , cD1Item , cCod_I, cTipo )

Local lAchou      := .F.
Local aResult     := {lAchou,0,cD1Item,0}
Local lSeekSD1    := .F.
Local aOrd        := SAveOrd({"SD1","EYY","EE9","SB1"})
Local cTecD1Item  := ""
Default cTipo     := "PRODUTO"
Default cChaveEYY := EYY->(EYY_FILIAL + EYY_NFENT + EYY_SERENT + EYY_FORN + EYY_FOLOJA)
Default cD1Item   := ""

SD1->(DbSetOrder(1))
SD1->(DbGoTop())
ChkFile("SB1")

lSeekSD1 := SD1->(DbSeek(cChaveEYY))

If lSeekSD1

   While SD1->(!Eof()) .And. SD1->(D1_FILIAL + D1_DOC + D1_SERIE + D1_FORNECE + D1_LOJA) == cChaveEYY

      If cTipo == "PRODUTO"
         
         If SD1->D1_COD == cCod_I .And. If( !Empty(cD1Item), SD1->D1_ITEM == AvKey(cD1Item,"D1_ITEM") , .T.)
            //nQtdCvExNF := EasyConvQt( EE9->EE9_COD_I ,{{ EE9->EE9_UNIDAD , EYY->EYY_QUANT }}, SD1->D1_UM ,.F.)
            nQtdCvExNF := EasyConvQt( EE9->EE9_COD_I , GetEYYQtds("EYY",SD1->D1_UM) , SD1->D1_UM ,.F.)
            If SD1->D1_SLDEXP >= nQtdCvExNF
               cD1Item := SD1->D1_ITEM
               lAchou := .T.
               EXIT
            EndIf
         EndIf          

      ElseIf cTipo == "NCM"
         cTecD1Item := If( !Empty(SD1->D1_TEC), SD1->D1_TEC , Posicione("SB1",1,xFilial("SB1")+SD1->D1_COD,"B1_POSIPI") )
         If cTecD1Item == EE9->EE9_POSIPI .And. If( !Empty(cD1Item), SD1->D1_ITEM == AvKey(cD1Item,"D1_ITEM"), .T.)
            //nQtdCvExNF := EasyConvQt( EE9->EE9_COD_I ,{{ EE9->EE9_UNIDAD , EYY->EYY_QUANT }}, SD1->D1_UM ,.F.)
            nQtdCvExNF := EasyConvQt( EE9->EE9_COD_I , GetEYYQtds("EYY",SD1->D1_UM) , SD1->D1_UM ,.F.)
            If  SD1->D1_SLDEXP >= nQtdCvExNF
               cD1Item := SD1->D1_ITEM
               lAchou := .T.
               EXIT
            EndIf
         EndIf

      EndIf
    
      SD1->(DbSkip()) 
      
   EndDo

   If lAchou
      aResult := {lAchou,nQtdCvExNF,cD1Item,SD1->(Recno())}
   EndIf

EndIf

RestOrd(aOrd,.T.)

Return aResult

/*
Funcao        : GetMSgLog()
Parametros    : nTipo     - Tipo da Mensagem a gerar
Retorno       : cMsg      - Mensagem criada para log
Objetivos     : Montar mensagens solicitadas para log em um mesmo lugar
Autor         : NCF
Data/Hora     : 03/2018
Revisao       :
Obs.          :
//nTipo: 1 = Mensagem de log de atualiza��o geral da coluna D1_SDLEXP com base na quantidade do campo D1_QUANT
//       2 = Mensagem de Log de atualiza��o do saldo da coluna D1_SLDEXP no registro posicionado com base na vincula��o ao EYY_QUANT
//       3 = Mensagem de log de item de Nfe correspondente com saldo n�o encontrado para vincula��o ao item de exporta��o */
Static Function GetMSgLog( nTipo, nQtdeUtilizada )
Local cMsg := ""

If nTipo == 1

   cMsg += "Atualiza��o do saldo inicial para o documento " + AllTrim(SD1->D1_DOC)   +;
           " s�rie "                                        + AllTrim(SD1->D1_SERIE) +;
           " fornecedor/ Loja "                             + AllTrim(SD1->D1_FORNECE)    + "/ "  + AllTrim(SD1->D1_LOJA)         +;
           " item/ produto "                                + AllTrim(SD1->D1_ITEM)       + "/ "  + AllTrim(SD1->D1_COD)  + ENTER +;
           " Saldo inicial: "                               + AllTrim(Str(SD1->D1_QUANT)) + ENTER + ENTER

ElseIf nTipo == 2

   cMsg +=  "Atualiza��o do saldo do documento de entrada " + AllTrim(SD1->D1_DOC) +;
            " s�rie "             + AllTrim(SD1->D1_SERIE)      +;
            " fornecedor "        + AllTrim(SD1->D1_FORNECE)    +;
            " loja "              + AllTrim(SD1->D1_LOJA)       +;
            " produto "           + AllTrim(SD1->D1_COD)        +;
            " item "              + AllTrim(SD1->D1_ITEM)       +;
            " Unid.Med.Item NF "  + AllTrim(SD1->D1_UM) + ENTER +;
            " Qtde. utilizada : " + Alltrim(Transform( nQtdeUtilizada , Avsx3("D1_QUANT",6) )) + "("+AllTrim(SD1->D1_UM)+")" + ;
            " equivalente � "     + Alltrim(Transform( EYY->EYY_QUANT , Avsx3("D1_QUANT",6) )) + "(" +AllTrim(EE9->EE9_UNIDAD)+")"

ElseIf nTipo == 3

   cMsg += "N�o foi encontrado item correspondente com saldo a vincular no documento de entrada: "+ ENTER +;
           "|Nota: "      + EYY->EYY_NFENT           +"|S�rie: " + EYY->EYY_SERENT +;
           "|Fornecedor: "+ EYY->EYY_SERENT          +"|Loja: " + EYY->EYY_FOLOJA +;
           "|Produto: "   + EE9->EE9_COD_I           + " para o registro EYY do processo " + AllTrim(EYY->EYY_PREEMB) +;
           " Pedido: "    + AllTrim(EYY->EYY_PEDIDO) +;
           " Sequencia: " + AllTrim(EYY->EYY_SEQUEN) + ENTER

EndIf

Return cMsg


Static Function GetEYYQtds(cAlias,cD1UM)
Local aRet
           //    Unidade DE[1]         Qtde. DE[1]        Unidade DE[2]                                     Qtde. DE[2]    
  aRet := {  { EE9->EE9_UNIDAD , (cAlias)->EYY_QUANT } , { If(!Empty(EE9->EE9_UNPES), EE9->EE9_UNPES,"KG"), ((cAlias)->EYY_QUANT * EE9->EE9_PSLQUN) } }

Return aRet