#INCLUDE "HSPAHR77.ch"
#include "Protheus.ch"
#include "TopConn.ch"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � HSPAHR77 � Autor � HEIMDALL CASTRO    � Data �22/06/05     ���
�������������������������������������������������������������������������͹��
���Descricao � Relatorio de KITS                                          ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � GESTAO HOSPITALAR.                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function HSPAHR77()
 Local cDesc1  := STR0001 //"Este programa tem como objetivo imprimir relatorio "
 Local cDesc2  := STR0002 //"de acordo com os parametros informados pelo usuario."
 Local cDesc3  := ""
 Local cPict   := ""
 Local imprime := .T.
 Local aOrd    := {}
 Local nLinTotal := 60
 
 Private cCabec1 := "" //"C�digo Kit      Descri��o                                              C�digo Item         Descri��o Produto/Tx e Di�rias     Qtd."
 Private cCabec2 := ""
 Private cTitulo := STR0003 //"Rela��o de kits"
 Private lEnd         := .F.
 Private lAbortPrint  := .F.
 Private limite       := 132
 Private tamanho      := "M"
 Private nomeprog     := "HSPAHR77"
 Private nTipo        := 15
 Private aReturn      := {STR0004, 1, STR0005, 2, 2, 1, "", 1}  //"Zebrado"###"Administracao"
 Private nLastKey     := 0
 Private cbtxt        := Space(10)
 Private cbcont       := 00
 Private CONTFL       := 01
 Private m_pag        := 01
 Private cString      := ""
 Private wnrel        := "HSPAHR77"
 Private nLin         := 80

 Private cCODIMP      := ""
 Private nMaxLin      := 0 // quantidade maxima de linhas p/ impressao
 
 Private cCodKit_De   := ""
 Private cCodKit_Ate  := ""
 
 Private lTamProd := IIf((TamSx3("GAF_CCOKIT")[1])<=15, .T., .F.)
 cCabec1 := IIf(lTamProd,STR0013,STR0014)
 
 cPerg := "HSPR77"
 If !Pergunte(cPerg,.T.)
  return
 EndIf               
 
 cCodKit_De  := mv_par01
 cCodKit_Ate := mv_par02

 nMaxLin := HS_MaxLin(cCODIMP)
 nLin    := nMaxLin * 2
           
 wnrel := SetPrint("", NomeProg, "", @cTitulo, cDesc1, cDesc2, cDesc3, .T., aOrd, .T., Tamanho, , .T.)
 If nLastKey == 27
  Return()
 Endif
 
 SetDefault(aReturn,cString)
 
 If nLastKey == 27
  Return
 Endif
                
 nTipo := 18
 RptStatus({|| RunRepRel(cCabec1, cCabec2, cTitulo, nLin, nLinTotal)}, cTitulo)
Return(Nil)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Fun��o    �RUNREPREL � Autor � HEIMDALL CASTRO    � Data �18/04/08     ���
�������������������������������������������������������������������������͹��
���Descri��o � Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS ���
���          � monta a janela com a regua de processamento.               ���
�������������������������������������������������������������������������͹��
���Uso       � GESTAO HOSPITALAR                                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function RunRepRel(cCabec1, cCabec2, cTitulo, nLin, nLinTotal)
 
 Local cSql    := ""
 Local cCodKit := ""
 
 cSQL := "SELECT GAG.GAG_CODKIT CODKIT, GAF.GAF_DESKIT DESKIT, GAF.GAF_CCOKIT CCOPRI, GAG.GAG_CCOKIT CCOKIT, SB1.B1_DESC DESCR, GAG.GAG_QTDKIT QTDKIT "
 cSQL += "FROM " + RetSqlName("GAG") + " GAG "
 cSQL += "JOIN " + RetSqlName("GAF") + " GAF ON GAF.GAF_FILIAL = '" + xFilial("GAF") + "' AND GAF.D_E_L_E_T_ <> '*' AND GAF.GAF_CODKIT = GAG.GAG_CODKIT " 
 cSQL += "JOIN " + RetSqlName("SB1") + " SB1 ON SB1.B1_FILIAL = '" + xFilial("SB1") + "' AND SB1.D_E_L_E_T_ <> '*' AND SB1.B1_COD = GAG.GAG_CCOKIT " 
 cSQL += "WHERE GAF.GAF_CODKIT BETWEEN '" + cCodKit_De + "' AND '" + cCodKit_Ate + "' AND "
 cSQL += "GAG.D_E_L_E_T_ <> '*' AND GAG.GAG_FILIAL = '" + xFilial("GAG") + "' AND GAF.GAF_CCOKIT <> GAG.GAG_CCOKIT " 
 cSQL += "ORDER BY GAG.GAG_CODKIT "

 TCQUERY cSQL NEW ALIAS "QRY"
 DbSelectArea("QRY")
 
 DbGoTop()
 If Eof()
  HS_MsgInf(STR0008, STR0011, STR0012) //"Nenhum dado foi encontrado para a selecao efetuada."###"Aten��o"###"Rotina de execucao do relatorio"
  DbCloseArea()
  Return()
 Endif 
             
  //���������������������������������������������������������������������Ŀ
 //� SETREGUA -> Indica quantos registros serao processados para a regua �
 //�����������������������������������������������������������������������
 SetRegua(RecCount())
 
 While !EOF()                                                                                
  IncRegua()
  
  If nLin+2 > nMaxLin
   FS_Cabec()
   nLin := 8
  Endif
    
  @ nLin, 002 PSAY SUBSTR(QRY->CODKIT, 1, 40)
  @ nLin, 010 PSAY QRY->DESKIT 
  @ nLin, 050 PSAY QRY->CCOPRI
  @ nLin, IIf(lTamProd,068,083) PSAY SUBSTR(HS_INIPADR("SB1", 1, QRY->CCOPRI, "B1_DESC"), 1, 40)
  @ nLin, IIf(lTamProd,118,133) PSAY HS_INIPADR("GAG", 1, QRY->CODKIT + QRY->CCOPRI, "GAG_QTDKIT")
  
  cCodKit := QRY->CODKIT

  nLin++    
  
		While (QRY->CODKIT == cCodKit)
		 If nLin+2 > nMaxLin
    FS_Cabec()
    nLin    := 8
   Endif
   
   @ nLin, 050 PSAY QRY->CCOKIT
   @ nLin, IIf(lTamProd,068,083) PSAY SUBSTR(QRY->DESCR, 1, 40)
   @ nLin, IIf(lTamProd,118,133) PSAY QRY->QTDKIT 
  	nLin++
      
 	 DbSkip() 
  End
          
  nLin += 1
  
  @ nLin, 001 PSAY "----------------------------------------------------------------------------------------------------------------------------"
             
  nLin += 1
 
 End 

 Set Device  to Screen
 
 If aReturn[5]==1
  dbCommitAll()
  SET PRINTER TO
  OurSpool(wnrel)
 Endif

 MS_FLUSH() 
 DBCloseArea()
 
Return(Nil)       

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Fun��o    �FS_Cabec  � Autor � Cibele Peria       � Data �  29/03/05   ���
�������������������������������������������������������������������������͹��
���Descri��o � Cabecalho do relatorio                                     ���
�������������������������������������������������������������������������͹��
���Uso       � GESTAO HOSPITALAR                                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function FS_Cabec()
 Cabec(cTitulo, cCabec1, cCabec2, NomeProg, Tamanho, nTipo, ,.T.) 
Return()
