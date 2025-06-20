#INCLUDE "HSPAHF06.ch"
#include "protheus.CH"
#include "colors.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � HSPAHF06 � Autor � GILSON DA SILVA    � Data �  05/05/2005 ���
�������������������������������������������������������������������������͹��
���Descricao � Laudo Obstetrico                                           ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Modulo Gestao Hospitalar                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function HSPAHF06()
Local cCab01    := ""

cTitulo   := STR0002 //"LAUDO OBSTETRICO"
cNomeRel  := "HSPAHF06"
nLin      := 0

GBH->(DbSetOrder(1))
GBH->(DbSeek(xFilial("GBH")+ GCY->GCY_REGGER))

GCZ->(DbSetOrder(2))
GCZ->(DbSeek(xFilial("GCZ")+ GCY->GCY_REGATE))

If nLastKey == 27
	Return(nil)
Endif

nTipo := If(aReturn[4]==1,15,18)

cCAB01 := STR0001 //"F O R M U L A R I O     P A R A     L A U D O      O B S T E T R I C O  "

Cabec(cTitulo,	cCab01, "", cNomeRel, H44GetTam(), H44GetTip())

@ PROW()   ,00     PSAY PADC(STR0003,132)  // "S U S  -  S i s t e m a   U n i c o   d e   S a u d e"
@ PROW()   ,00     PSAY PADC(STR0003,132)  // "S U S  -  S i s t e m a   U n i c o   d e   S a u d e"
@ PROW()+01,00     PSAY PADC(STR0004,132)  // "Ministerio da Saude"
@ PROW()   ,00     PSAY PADC(STR0004,132)  // "Ministerio da Saude"
@ PROW()+01,00     PSAY PADC(STR0005 + aDadosEmp[5],132)  // "GOVERNO DO ESTADO "
@ PROW()+01,00     PSAY PADC(STR0006,132)  // "Secretaria Especial de Protecao Social - Secretaria Executiva de Saude"
@ PROW()+02,00     PSAY PADC(STR0007,132)  // "LAUDO MEDICO PARA EMISSAO DE AIH"
@ PROW()   ,00     PSAY PADC(STR0007,132)  // "LAUDO MEDICO PARA EMISSAO DE AIH"
@ PROW()+02,00     PSAY STR0008 + aDadosEmp[1] // "Prontuario:_____________   Hospital: "
@ PROW()+02,00     PSAY STR0009  // "1-Codigo de Autorizacao:_______________"
@ PROW()+01,00     PSAY STR0010  // "2-Unidade de Origem:_________________________________  3-CNPJ:__________________"
@ PROW()+01,00     PSAY STR0011  // "4-Unidade de Destino:________________________________  5-CNPJ:__________________"
@ PROW()+01,00     PSAY STR0012 + GCY->GCY_NOME // "6-Nome do Paciente: "
@ PROW()+01,00     PSAY STR0013 + strzero(Calc_anos(GBH->GBH_DTNASC, GCY->GCY_DATATE),3,0) // "7-Idade: "
@ PROW() ,PCOL()+5 PSAY STR0014 + dtoc(POSICIONE("GBH",1,XFILIAL("GBH")+GCY->GCY_REGGER,"GBH_DTNASC")) // "8-Data Nasc.: "
@ PROW(),PCOL()+17 PSAY STR0015 + IIF(POSICIONE("GBH",1,XFILIAL("GBH")+GCY->GCY_REGGER,"GBH_SEXO")=="0",STR0033,STR0034) // "9-Sexo.: " // "Masculino","Feminino"
@ PROW()+01,00     PSAY STR0016 + POSICIONE("GBH",1,XFILIAL("GBH")+GCY->GCY_REGGER,"GBH_END") // "10-Endereco.: "
@ PROW() ,PCOL()+2 PSAY STR0017 + POSICIONE("GBH",1,XFILIAL("GBH")+GCY->GCY_REGGER,"GBH_BAIRRO") // "11-Bairro: "
@ PROW()+01,00     PSAY STR0018 + POSICIONE("GBH",1,XFILIAL("GBH")+GCY->GCY_REGGER,"GBH_CEP") // "12-CEP: "
@ PROW() ,PCOL()+2 PSAY STR0019 + POSICIONE("GBH",1,XFILIAL("GBH")+GCY->GCY_REGGER,"GBH_MUN") // "13-Municipio:"
@ PROW() ,PCOL()+5 PSAY STR0020 + POSICIONE("GBH",1,XFILIAL("GBH")+GCY->GCY_REGGER,"GBH_EST") // "14-U.F.:"
@ PROW()+01,00     PSAY STR0021 + iif(empty(POSICIONE("GBH",1,XFILIAL("GBH")+GCY->GCY_REGGER,"GBH_RG")),"________________",GBH->GBH_RG) // "15-Tipo DOC.:__________     16-Numero Doc.: "
@ PROW()+01,00     PSAY STR0022 + Posicione("GFD",1,xFilial("GFD")+GCY->GCY_CODRES, "GFD_NOME") // "17-Nome do Responsavel: "
@ PROW()+01,00     PSAY STR0023 // "18-Med.Solic.:______________________________ 19-CPF Dir.Clinico:________________"
@ PROW()+01,00     PSAY STR0024 + GCY->GCY_QUAINT+"/"+GCY->GCY_LEIINT + STR0025 // "     21-Enfermaria No.: _______"
@ PROW()+01,00     PSAY STR0026 + DTOC(GCY->GCY_DATATE) // "22-Carater da Internacao:______________     23-Data da Internacao: "
@ prow()+1,00      PSAY Replicate("-",132)
@ PROW()+01,00     PSAY PADC(STR0027,132)  // "Preencher em caso de Acidente de Transito"
@ PROW()   ,00     PSAY PADC(STR0028,132)  // "Preencher em caso de Acidente de Transito"
@ PROW()+02,00     PSAY STR0029 // "24-Causa Externa:__________________________ 25-CNPJ da Segur.:__________________"
@ PROW()+01,00     PSAY STR0030 // "26-Nro. do Bilhete:________________________ 27-Serie:___________________________"
@ prow()+1,00      PSAY Replicate("-",132)
@ PROW()+01,00     PSAY PADC(STR0030,132)  // "Preencher em caso de Acidente de Trabalho"
@ PROW()   ,00     PSAY PADC(STR0030,132)  // "Preencher em caso de Acidente de Trabalho"
@ PROW()+02,00     PSAY STR0031 // "28-Comunicado Acidente Trabalho_________________________________________________"
@ PROW()+01,00     PSAY STR0032 // "29-CNPJ do Empregador:__________________________________"
@ prow()+1,00      PSAY Replicate("-",132)
@ prow()+01,00     PSAY STR0035 // "  Internacao         Alta       Novo Procedimento  Dias UTI Aut   AC    Parto   " 
@ prow()+01,00     PSAY "____/____/____  ____/____/____  |________________| |__________|  |__| |________|" 
@ prow()+02,00     PSAY STR0036 // "  MO      Material/Medicamento         CID            CID II              ALA   "
@ prow()+01,00     PSAY " |__|    |____________________|    |__________|    |__________|         |_____| "
@ prow()+01,00     PSAY Replicate("-",132)
@ prow()+01,00     PSAY "+----+--------+---------+----+--------+----+--------+----+--------+----+-------+"
@ prow()+01,00     PSAY STR0037 // "|TIPO|  CRM   |DIA/PROCD|TIPO|  CRM   |TIPO|  CRM   |TIPO|  CRM   |TIPO|  CRM  |"
@ prow()+01,00     PSAY "+----+--------+---------+----+--------+----+--------+----+--------+----+-------+"
@ prow()+01,00     PSAY "|    |        |         |    |        |    |        |    |        |    |       |"
@ prow()+01,00     PSAY "+----+--------+---------+----+--------+----+--------+----+--------+----+-------+"
@ prow()+01,00     PSAY "|    |        |         |    |        |    |        |    |        |    |       |"
@ prow()+01,00     PSAY "+----+--------+---------+----+--------+----+--------+----+--------+----+-------+"
@ prow()+01,00     PSAY "|    |        |         |    |        |    |        |    |        |    |       |"
@ prow()+01,00     PSAY "+----+--------+---------+----+--------+----+--------+----+--------+----+-------+"
@ prow()+01,00     PSAY "|    |        |         |    |        |    |        |    |        |    |       |"
@ prow()+01,00     PSAY "+----+--------+---------+----+--------+----+--------+----+--------+----+-------+"
@ prow()+01,00     PSAY STR0038 // "                                                            SOMA TIPOS |       |"
@ prow()+01,00     PSAY "                                                                       +-------+"
@ prow()+01,00     PSAY STR0039 // "      ORTESE E PROTESE                               EXAMES                     "
@ prow()+01,00     PSAY "+----+--------+----+---------+                  " 
@ prow()+01,00     PSAY STR0040 // "|SADT|PROCEDIM| QTD|N. Fiscal|  COD  QTDE SADT   COD  QTDE SADT   COD  QTDE SADT"
@ prow()+01,00     PSAY "+----+--------+----+---------+ +----+----+----+ +----+----+----+ +----+----+----+"
@ prow()+01,00     PSAY "|    |        |    |         | |    |    |    | |    |    |    | |    |    |    |"
@ prow()+01,00     PSAY "+----+--------+----+---------+ +----+----+----+ +----+----+----+ +----+----+----+"
@ prow()+01,00     PSAY "|    |        |    |         | |    |    |    | |    |    |    | |    |    |    |"
@ prow()+01,00     PSAY "+----+--------+----+---------+ +----+----+----+ +----+----+----+ +----+----+----+"
@ prow()+01,00     PSAY "|    |        |    |         | |    |    |    | |    |    |    | |    |    |    |"
@ prow()+01,00     PSAY "+----+--------+----+---------+ +----+----+----+ +----+----+----+ +----+----+----+"
@ prow()+02,00     PSAY STR0041 //"Soma SADT:       Soma Qtde:       Soma Cod:        Soma Qtde:     Soma SADT:     "
Return()