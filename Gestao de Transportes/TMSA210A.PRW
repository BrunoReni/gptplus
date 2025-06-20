#Include "Protheus.ch"
#Include "TmsA210.ch"

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � TmsA210A � Autor � Robson Alves          � Data �15.02.2002���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Carregamento de transporte rodoviario.                     ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TmsA210A()                                                 ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function TmsA210A()

Local aHlpPor1    :=  {"Informe a Filial do Docto./No.Docto","/S�rie Docto ..."}
Local aHlpIng1    :=  {"Enter branch of the doc./doc. nbr. ","/Doc. series..."}
Local aHlpEsp1    :=  {"Informe la sucursal del dcto./n�dcto.","/Serie Dcto ..."}
Local aHlpPor2    :=  {"A Filial informada n�o pertence ao ","Parceiro respons�vel pelo documento."}
Local aHlpIng2    :=  {"The branch entered does not belong to","Partner responsible for the document"}
Local aHlpEsp2    :=  {"A Filial informada n�o pertence ao ","Socio responsablel por el  documento."}
Local aHlpPor3    :=  {"A Filial informada n�o est� configurada"," no par�metro MV_FILDPC."}
Local aHlpIng3    :=  {"The branch entered is not configured "," in the parameter MV_FILDPC."}
Local aHlpEsp3    :=  {"La Sucursal informada no est� configurada"," en el parametro MV_FILDPC."}

Private cCadastro  := STR0001  //"Carregamento Rodoviario" 
Private aRotina := MenuDef()
//�����������������������������������������������������������������������Ŀ
//� Chama a funcao manutencao de carregamento.( 2 = Transporte / 1 = Rodo-�
//�viario.                                                                �
//�������������������������������������������������������������������������
TmsA210("2", "1")

//Ajuste de Novos Helps
PutHelp("PTMSA21017",aHlpPor2,aHlpIng2,aHlpEsp2,.F.)
PutHelp("PTMSA21018",aHlpPor3,aHlpIng3,aHlpEsp3,.F.)
PutHelp("PTMSA21019",{"Nota fiscal n�o encontrada !!!"},{"Invoice not found! "},{"� Factura no encontrada !"},.F.)
PutHelp("PTMSA21020",aHlpPor1,aHlpIng1,aHlpEsp1,.F.)
PutHelp("PTMSA21021",{"Informe a filial de Descarga : "},{"Enter unload branch: "},{"Informe la sucursal de Descarga : "},.F.)
PutHelp("PTMSA21022",{"Filial de Descarga Inv�lida ... "},{"Invalid unload branch ... "},{"Sucursal de Descarga Invalida ... "},.F.)

Return Nil
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MENUDEF  � Autor � Jefferson Tomaz       � Data �29.12.2008���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Menu                                                       ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function MenuDef()

Local aRotina := MenuD210()

Return(aRotina)