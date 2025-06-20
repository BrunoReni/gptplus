#INCLUDE "PROTHEUS.CH"
#INCLUDE "TRMR020.CH"
/*
��������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������
����������������������������������������������������������������������������������Ŀ��
���Programa  � TRMR020  � Autor � Eduardo Ju            � Data �  26/06/06         ���
����������������������������������������������������������������������������������Ĵ��
���Descri��o � Relatorio de Cargos do Treinamento                                  ���
����������������������������������������������������������������������������������Ĵ��
���Sintaxe   � TRMR020                                                             ���
����������������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.                      ���
����������������������������������������������������������������������������������Ĵ��
���Programador � Data     � BOPS �  Motivo da Alteracao                            ���
����������������������������������������������������������������������������������Ĵ��
���Cecilia Car.�31/07/2014�TPZWAO	   �AIncluido o fonte da 11 para a 12 e efetua ���
���            �          �			   �da a limpeza.                              ���
���Esther V.   �08/05/2017�DRHPONTP-330�Incluida validacao de compartilhamento para���
���            �          �            �tabelas envolvendo campo MATRICULA.        ���
�����������������������������������������������������������������������������������ٱ�
���Willian U.  �16/05/2017�DRHPONTP-504�Ajuste do campo QV_DESCFAT para            ���
���            �          �            �imprimir 100 caracteres                    ���
�����������������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������������
������������������������������������������������������������������������������������*/
Function TRMR020()

Local oReport
Local aArea 	:= GetArea()
Private cAliasX	:= "SRA"
Private cFator	:= ""
Private cItEscCar	:= ""    

	If !(ValCompSRA()) //valida compartilhamento entre tabelas
		Return(.F.)
	EndIf

//��������������������������������������������������������������Ŀ
//� Verifica as perguntas selecionadas                           �
//����������������������������������������������������������������
Pergunte("TRR20R",.F.)
oReport := ReportDef()
oReport:PrintDialog()	

RestArea( aArea )

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �ReportDef() � Autor � Eduardo Ju          � Data � 26.06.06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Definicao do Componente de Impressao do Relatorio           ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function ReportDef()

Local oReport
Local oSection1
Local oSection2
Local oSection3
Local oSection4
Local oSection5
Local oSection6
Local oSection7
Local oSection8
Local oSection9
Local aOrdem    := {}

Private cCalend
Private cCurso
Private cTurma
Private cTipo
Private cTeste
Private nTot
Private cDescCalend
Private cDescCurso
Private cDescTipo
Private dData

//������������������������������������������������������������������������Ŀ
//�Criacao do componente de impressao                                      �
//�TReport():New                                                           �
//�ExpC1 : Nome do relatorio                                               �
//�ExpC2 : Titulo                                                          �
//�ExpC3 : Pergunte                                                        �
//�ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  �
//�ExpC5 : Descricao                                                       �
//��������������������������������������������������������������������������
oReport:=TReport():New("TRMR020",STR0001,"TRR20R",{|oReport| PrintReport(oReport)},STR0065+" "+STR0002+" "+STR0003)	//"Relatorio de Funcionarios"#"Ser� impresso de acordo com os parametros solicitados pelo usuario"
oReport:SetLandscape()
Pergunte("TRR20R",.F.)
cFator	:= Alltrim(MV_PAR08)

Aadd( aOrdem, STR0004)	// "Matricula"
Aadd( aOrdem, STR0005)	// "Nome"
Aadd( aOrdem, STR0006)	// "Centro de Custo"
Aadd( aOrdem, STR0007)	// "Cargo" 

//����������������������������������������Ŀ
//� Criacao da Primeira Secao: Funcionario �
//������������������������������������������ 
oSection1 := TRSection():New(oReport,STR0051,{"SRA","SQ3","SI3"},aOrdem,/*Campos do SX3*/,/*Campos do SIX*/)
oSection1:SetTotalInLine(.F.)
oSection1:SetHeaderBreak()

TRCell():New(oSection1,"RA_FILIAL","SRA")				//Matricula do Funcionario
TRCell():New(oSection1,"RA_MAT","SRA")					//Matricula do Funcionario
TRCell():New(oSection1,"RA_NOME","SRA")					//Nome do Funcionario
TRCell():New(oSection1,"RA_NASC","SRA")					//Dt. de Nascimento
TRCell():New(oSection1,"RA_ADMISSA","SRA")				//Dt. de Admissao
TRCell():New(oSection1,"RA_ESTCIVI","SRA",,,15,,{|| Left(TrmDesc("SX5","33"+(cAliasX)->RA_ESTCIVI,"SX5->X5_DESCRI"),15)})										//Estado Civil
TRCell():New(oSection1,"RA_CARGO","SRA",,,,,{|| fGetCargo((cAliasX)->RA_MAT,(cAliasX)->RA_FILIAL)})																//Cargo
TRCell():New(oSection1,"Q3_DESCSUM","SQ3","",,,,{|| FDesc("SQ3",fGetCargo((cAliasX)->RA_MAT,(cAliasX)->RA_FILIAL),"SQ3->Q3_DESCSUM",30,(cAliasX)->RA_FILIAL)})	//Descricao do Cargo
TRCell():New(oSection1,"RA_CC","SRA")					//Centro De Custo
TRCell():New(oSection1,"I3_DESC","SI3","")				//Descricao do CC

TRPosition():New(oSection1,"SQ3",1,{|| TrmSqOrd("SQ3")})
TRPosition():New(oSection1,"SI3",1,{|| xFilial("SI3", (cAliasX)->RA_FILIAL) + (cAliasX)->RA_CC})

//����������������������������������������������������Ŀ
//� Criacao da Segunda Secao: Graduacao do Funcionario �
//������������������������������������������������������
oSection2 := TRSection():New(oSection1,STR0017,{"SQ8","SQ2","SQ4","SQV","SQ1"},/*aOrdem*/,/*Campos do SX3*/,/*Campos do SIX*/)
oSection2:SetTotalInLine(.F.)
oSection2:SetHeaderBreak()
oSection2:ShowHeader(.T.)	//Imprime Cabecalho da Secao
oSection2:SetLeftMargin(3)	//Identacao da Secao      

TRCell():New(oSection2,"Q8_FATOR"	,"SQ8")									//Codigo do Fator
TRCell():New(oSection2,"QV_DESCFAT"	,"SQV","",,100)							//Descricao do Fator
TRCell():New(oSection2,"Q4_GRAU"	,"SQ4",STR0052)							//Codigo do Grau do Cargo
TRCell():New(oSection2,"Q2_DESC"	,"SQ2","",,20)							//Descricao do Grau do Cargo
TRCell():New(oSection2,"Q2_PONTOSI"	,"SQ2",STR0053,"@E 9999.99",,,,,,,.T.)	//Pontos do Cargo
TRCell():New(oSection2,"Q8_GRAU"	,"SQ8",STR0054)							//Codigo do Grau do Funcionario
TRCell():New(oSection2,"QV_DESCGRA"	,"SQV","",,100)							//Descricao do Grau do Funcionario
TRCell():New(oSection2,"Q8_PONTOS"	,"SQ8",STR0053,"@E 9999.99",,,,,,,.T.)	//Pontos do Funcionario
TRCell():New(oSection2,"Q1_DESCDET"	,"SQ1")																//Codigo da Descricao Detalhada do Fator
TRCell():New(oSection2,"Q1_MEMO1"	,"SQ1",STR0043,,,,{|| MSMM(SQ1->Q1_DESCDET,,,,3,,,"SQ1")},,,,.T.)	//Descricao Detalhada do Fator
TRCell():New(oSection2,"Q8_OBS"		,"SQ8")																//Codigo da Observacao do Fator do Funcionario
TRCell():New(oSection2,"Q8_MEMO1"	,"SQ8",STR0045,/*Picture*/,,/*lPixel*/,{|| MSMM(SQ8->Q8_OBS,,,,3)})	//Descricao da Observacao do Fator do Funcionario

TRPosition():New(oSection2,"SQV",1,{|| xFilial("SQV",SQ8->Q8_FILIAL) + SQ8->Q8_FATOR + SQ8->Q8_GRAU })
TRPosition():New(oSection2,"SQ4",2,{|| TrmSqOrd("SQ4")})
TRPosition():New(oSection2,"SQ2",2,{|| xFilial("SQ2",SQ4->Q4_FILIAL) + SQ4->Q4_FATOR + SQ4->Q4_GRAU})
TRPosition():New(oSection2,"SQ1",3,{|| xFilial("SQ1",SQ8->Q8_FILIAL) + SQ8->Q8_FATOR })

oSection2:SetLineStyle()

//��������������������������������������������������Ŀ
//� Criacao da Terceira Secao: Historico da Carreira �
//����������������������������������������������������
oSection3 := TRSection():New(oSection1,STR0023,{"SQC"},/*aOrdem*/,/*Campos do SX3*/,/*Campos do SIX*/)
oSection3:SetTotalInLine(.F.)
oSection3:SetHeaderBreak()
oSection3:ShowHeader(.T.) 	//Imprime Cabecalho da Secao
oSection3:SetLeftMargin(3)	//Identacao da Secao         

TRCell():New(oSection3,"QC_ADMISSA","SQC")			//Data de Admissao
TRCell():New(oSection3,"QC_DEMISSA","SQC")			//Data de Demissao
TRCell():New(oSection3,"QC_EMPRESA","SQC")			//Empresa
TRCell():New(oSection3,"QC_CARGO","SQC")			//Cargo

//������������������������������������������������������������Ŀ
//� Criacao da Quarta Secao: Historico da Carreira na Empresa  �
//��������������������������������������������������������������
oSection4 := TRSection():New(oSection1,STR0026,{"SR7"/*,"SRJ"*/},/*aOrdem*/,/*Campos do SX3*/,/*Campos do SIX*/)
oSection4:SetTotalInLine(.F.)
oSection4:SetHeaderBreak()
oSection4:ShowHeader(.T.) 	//Imprime Cabecalho da Secao
oSection4:SetLeftMargin(3)	//Identacao da Secao                    

TRCell():New(oSection4,"R7_DATA","SR7")				//Data do Aumento
TRCell():New(oSection4,"R7_TIPO","SR7")				//Tipo de Aumento
TRCell():New(oSection4,"X5_DESCRI","SX5","",,20)	//Descricao do Tipo de Aumento
TRCell():New(oSection4,"R7_FUNCAO","SR7")			//Funcao
TRCell():New(oSection4,"RJ_DESC","SRJ")				//Descricao da Funcao

TRPosition():New(oSection4,"SRJ",1,{|| xFilial("SRJ",SR7->R7_FILIAL) + SR7->R7_FUNCAO})
TRPosition():New(oSection4,"SX5",1,{|| xFilial("SX5",SR7->R7_FILIAL) + "41" + SR7->R7_TIPO})

//������������������������������������������������Ŀ
//� Criacao da Quinta Secao: Cursos do Funcionario �
//��������������������������������������������������
oSection5 := TRSection():New(oSection1,STR0020,{"RA4"/*,"RA1","RA9","RA0"*/},/*aOrdem*/,/*Campos do SX3*/,/*Campos do SIX*/)	
oSection5:SetTotalInLine(.F.)  
oSection5:SetHeaderBreak()
oSection5:ShowHeader(.T.) 	//Imprime Cabecalho da Secao
oSection5:SetLeftMargin(3)	//Identacao da Secao   
                                
TRCell():New(oSection5,"RA4_CURSO","RA4",STR0055)	//Codigo do Curso do Funcionario
TRCell():New(oSection5,"RA1_DESC","RA1","")		//Descricao do Curso  
TRCell():New(oSection5,"RA4_SINONI","RA4",STR0056)	//Sinonimo do Curso
TRCell():New(oSection5,"RA9_DESCR","RA9","")  		//Descricao do Sinonimo do Curso  
TRCell():New(oSection5,"RA4_DATAIN","RA4",STR0057)//Periodo: Data Inicio do Curso
TRCell():New(oSection5,"RA4_DATAFI","RA4","") 		//Periodo: Data Final do Curso 
TRCell():New(oSection5,"RA4_DURACA","RA4") 			//Duracao
TRCell():New(oSection5,"RA4_UNDURA","RA4","") 		//Unidade de Duracao
TRCell():New(oSection5,"RA4_VALIDA","RA4",STR0058) //Validade

//TRCell():New(<oParent>, <cName>, [ <cAlias> ], [ <cTitle> ],;
//							[ <cPicture> ], [ <nSize> ], [ <.lPixel.> ], [ <bBlock> ],;
//							[ <"cAlign"> ], [ <.lLineBreak.> ], [ <"cHeaderAlign"> ], [ <.lCellBreak.> ],;
//							[ <nColSpace> ], [<.lAutoSize.>], [ <nClrBack> ], [ <nClrFore> ])

//NECESSIDADE DE TREINAMENTO                                
TRCell():New(oSection5,"NECES","",STR0059,/*Picture*/,6,/*lPixel*/,{|| IIF(RA5->( DbSeek(xFilial("RA5") + (cAliasX)->RA_CARGO+(cAliasX)->RA_CC+RA4->RA4_CURSO )),STR0066,STR0067) }) //Descricao Detalhada do Fator 
TRCell():New(oSection5,"RA4_ENTIDA","RA4",STR0060)	//Codigo da Entidade 
TRCell():New(oSection5,"RA0_DESC","RA0","",,25)	//Descricao Codigo da Entidade 
TRCell():New(oSection5,"RA4_NOTA","RA4")			//Nota
TRCell():New(oSection5,"RA4_PRESEN","RA4")			//Presenca

//REALIZADO
TRPosition():New(oSection5,"RA1",1,{|| xFilial("RA1",RA4->RA4_FILIAL) + RA4->RA4_CURSO}) 
TRPosition():New(oSection5,"RA9", 1, {|| xFilial("RA9", RA4->RA4_FILIAL) + RA4->RA4_SINONI})
TRPosition():New(oSection5,"RA0",1,{|| xFilial("RA0",RA4->RA4_FILIAL) + RA4->RA4_ENTIDA}) 
TRPosition():New(oSection5,"RA5",2,{|| xFilial("RA5",(cAliasX)->RA_FILIAL) + (cAliasX)->RA_CARGO+(cAliasX)->RA_CC+RA4->RA4_CURSO}) 


//��������������������������������������������������Ŀ
//� Criacao da Sexta Secao: Cursos Extracurriculares �
//����������������������������������������������������
oSection6 := TRSection():New(oSection1,STR0030,{"SQ9"},/*aOrdem*/,/*Campos do SX3*/,/*Campos do SIX*/)	
oSection6:SetTotalInLine(.F.)  
oSection6:SetHeaderBreak()
oSection6:ShowHeader(.T.) 	//Imprime Cabecalho da Secao
oSection6:SetLeftMargin(3)	//Identacao da Secao  
                            
TRCell():New(oSection6,"Q9_DATA","SQ9")				//Data do Termino do Curso 
TRCell():New(oSection6,"Q9_DESCRIC","SQ9",,,40)	//Descricao do Curso
TRCell():New(oSection6,"Q9_ENTIDAD","SQ9")			//Entidade do Curso
TRCell():New(oSection6,"Q9_ESCOLAR","SQ9")			//Escolaridade
TRCell():New(oSection6,"Q9_PONTOS","SQ9")			//Pontos

TRFunction():New(oSection6:Cell("Q9_PONTOS"),/*cId*/,"SUM",/*oBreak*/,/*cTitle*/,"@E 9999.99"/*cPicture*/,/*uFormula*/,/*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/)

//������������������������������������������������Ŀ
//� Criacao da Setima Secao: Solicitacao de Cursos �
//��������������������������������������������������
oSection7 := TRSection():New(oSection1,STR0033,{"RA3"/*,"RA1","RA2"*/},/*aOrdem*/,/*Campos do SX3*/,/*Campos do SIX*/)	
oSection7:SetTotalInLine(.F.)  
oSection7:SetHeaderBreak()
oSection7:ShowHeader(.T.) 	//Imprime Cabecalho da Secao
oSection7:SetLeftMargin(3)	//Identacao da Secao   

TRCell():New(oSection7,"RA3_CURSO","RA3",STR0055)		//Codigo do Curso    
TRCell():New(oSection7,"RA1_DESC","RA1","")			//Descricao do Curso  
TRCell():New(oSection7,"RA3_TURMA","RA3")				//Turma  
TRCell():New(oSection7,"RA3_CALEND","RA3",STR0061)		//Calendario de Treinamento
TRCell():New(oSection7,"RA2_DESC","RA2","")			//Descricado do Calendario
TRCell():New(oSection7,"RA3_RESERV","RA3")				//Codigo do Tipo da Reserva #SUPRIMIR
TRCell():New(oSection7,"X5_DESCRI","SX5",STR0062,,20)//Descricao do Tipo da Reserva
TRCell():New(oSection7,"RA3_NVEZAD","RA3") 		   		//Periodo: Data Final do Curso 
TRCell():New(oSection7,"RA3_DATA","RA3",STR0063)		//Data da Solicitacao  
TRCell():New(oSection7,"RA2_DATAIN","RA2",STR0057)		//Periodo: Data Inicio do Curso
TRCell():New(oSection7,"RA2_DATAFI","RA2","") 			//Periodo: Data Final do Curso 

TRPosition():New(oSection7,"RA1",1,{|| xFilial("RA1",RA3->RA3_FILIAL) + RA3->RA3_CURSO}) 
TRPosition():New(oSection7,"RA2",1,{|| xFilial("RA2",RA3->RA3_FILIAL) + RA3->RA3_CALEND+RA3->RA3_CURSO+RA3->RA3_TURMA})
TRPosition():New(oSection7,"SX5",1,{|| xFilial("SX5",RA3->RA3_FILIAL) + "R7" + RA3->RA3_RESERV})

//����������������������������������������������������Ŀ
//� Criacao da Oitava Secao: Avaliacoes de Treinamento �
//������������������������������������������������������
oSection8 := TRSection():New(oSection1,STR0040,{"RAI"},/*aOrdem*/,/*Campos do SX3*/,/*Campos do SIX*/)	
oSection8:SetTotalInLine(.F.)  
oSection8:SetHeaderBreak()
oSection8:ShowHeader(.T.) 	//Imprime Cabecalho da Secao
oSection8:SetLeftMargin(3)	//Identacao da Secao  

TRCell():New(oSection8,"RAI_CALEND","RAI")			//Codigo do Calendario  
TRCell():New(oSection8,"RA2_DESC","RA2","")		//Descricado do Calendario
TRCell():New(oSection8,"RAI_CURSO","RAI")			//Codigo do Curso  
TRCell():New(oSection8,"RA1_DESC","RA1","")		//Descricao do Curso  
TRCell():New(oSection8,"RAI_TURMA","RAI")		  	//Turma
TRCell():New(oSection8,"RAI_TIPO","RAI",STR0064)	//Codigo do Tipo de Avaliacao  
TRCell():New(oSection8,"X5_DESCRI","SX5","",,20)	//Descricao do Tipo de Avaliacao  
TRCell():New(oSection8,"RAI_TESTE","RAI")		  	//Codigo da Avaliacao 

//If Len("RAI_TESTE") == 3
TRCell():New(oSection8,"QQ_DESCRIC","SQQ","")	  	//Descricao da Avaliacao 
/*Else
	TRCell():New(oSection8,"QW_DESCRIC","SQW","",,20)	  //Descricao da Avaliacao 
EndIf*/

TRCell():New(oSection8,"RAJ_DATA","RAJ")		  	//Data da Avaliacao 

//TRCell():New(oSection8,"DATA","","Data",,8,,{|| dData })		  	//Data da Avaliacao 
TRCell():New(oSection8,"RAI_RESULT","RAI",,,,,{|| TrTotResult() })		//Resultado da Avaliacao 

TRPosition():New(oSection8,"RA1",1,{|| xFilial("RA1",RAI->RAI_FILIAL) + RAI->RAI_CURSO})   
TRPosition():New(oSection8,"RA2",1,{|| xFilial("RA2",RAI->RAI_FILIAL) + RAI->RAI_CALEND+RAI->RAI_CURSO+RAI->RAI_TURMA})
TRPosition():New(oSection8,"SX5",1,{|| xFilial("SX5",RAI->RAI_FILIAL) + "RJ" + RAI->RAI_TIPO})          
TRPosition():New(oSection8,"RAJ",1,{|| xFilial("RAJ",RAI->RAI_FILIAL) + RAI->RAI_CALEND+RAI->RAI_CURSO})  

//If Len("RAI_TESTE") == 3
	TRPosition():New(oSection8,"SQQ",1,{|| xFilial("SQQ",RAI->RAI_FILIAL) + Alltrim(RAI->RAI_TESTE)}) 
/*Else
	TRPosition():New(oSection8,"SQW",1,{|| xFilial("SQW") + RAI->RAI_TESTE}) 
EndIf*/

//������������������������������������Ŀ
//� Criacao da Nona Secao: Habilidades �
//��������������������������������������
oSection9 := TRSection():New(oSection1,STR0048,{"RBI","RBH","RBK","RBL"},/*aOrdem*/,/*Campos do SX3*/,/*Campos do SIX*/)	
oSection9:SetTotalInLine(.F.)  
oSection9:SetHeaderBreak()
oSection9:ShowHeader(.T.) 	//Imprime Cabecalho da Secao
oSection9:SetLeftMargin(3)	//Identacao da Secao  

TRCell():New(oSection9,"RBI_HABIL","RBI")		  	   	//Codigo da Habilidade
TRCell():New(oSection9,"RBG_DESC","RBG","",,40) 		//Descricao da Habilidade
TRCell():New(oSection9,"RBI_ESCALA"	,"RBI") 	   	   	//Escala
TRCell():New(oSection9,"RBK_DESCRI"	,"RBK","",,30) 		//Descricao da Escala
TRCell():New(oSection9,"RBI_ITESCA"	,"RBI",STR0068) 	//Item de Escala do Funcionario
TRCell():New(oSection9,"RBL_DESCRI"	,"RBL","",,30)		//Descricao do Item de Escala 
TRCell():New(oSection9,"RBH_ITESCA"	,"RBH",STR0069,,,,{|| FItEscCar() }) 	//Item de Escala dp Cargo
TRCell():New(oSection9,"X_RBL_DESCRI","RBL","",,30,,{|| FDesc("RBL",RBH->RBH_ESCALA+cItEscCar,"RBL_DESCRI") }) //Descricao do Item de Escala do Cargo

TRPosition():New(oSection9,"RBG",1,{|| xFilial("RBG",RBI->RBI_FILIAL) + RBI->RBI_HABIL }) 
TRPosition():New(oSection9,"RBK",1,{|| xFilial("RBK",RBI->RBI_FILIAL) + RBI->RBI_ESCALA }) 
TRPosition():New(oSection9,"RBL",1,{|| xFilial("RBL",RBI->RBI_FILIAL) + RBI->RBI_ESCALA + RBI->RBI_ITESCA }) 

Return oReport   

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TrmSqOrd()  � Autor � Leandro Dr.         � Data � 09.03.09 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Seta a ordem de pesquisa do SQ3 e SQ4                       ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �TRMR020                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function TrmSqOrd(cAlias)
Local aArea  := GetArea()
Local bRet   := {|| }
Local cChave := ""

dbSelectArea("SQ3")
dbSetOrder(1)

If dbSeek(xFilial("SQ3", (cAliasX)->RA_FILIAL)+(cAliasX)->RA_CARGO+(cAliasX)->RA_CC)
	cChave 	:= (cAliasX)->RA_CARGO+SQ3->Q3_CC
Else
	cChave	:= (cAliasX)->RA_CARGO+Space(TamSX3("RA_CC")[1])
EndIf

If cAlias == "SQ3"
	bRet := {|| xFilial("SQ3", (cAliasX)->RA_FILIAL) + cChave}
Else
	bRet := {|| xFilial("SQ4", (cAliasX)->RA_FILIAL) + cChave + SQ8->Q8_FATOR}
EndIf

RestArea(aArea)

Return Eval(bRet)

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �ReportDef() � Autor � Eduardo Ju          � Data � 28.06.06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Impressao do Relatorio                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function PrintReport(oReport)

Local oSection1 := oReport:Section(1)
Local oSection2 := oReport:Section(1):Section(1)  
Local oSection3 := oReport:Section(1):Section(2)
Local oSection4 := oReport:Section(1):Section(3)
Local oSection5 := oReport:Section(1):Section(4)
Local oSection6 := oReport:Section(1):Section(5)
Local oSection7 := oReport:Section(1):Section(6)
Local oSection8 := oReport:Section(1):Section(7)
Local oSection9 := oReport:Section(1):Section(8)
Local cAcessaSRA:= &("{ || " + ChkRH(FunName(),"SRA","2") + "}")
Local cFiltro 	:= ""
Local nOrdem  	:= osection1:GetOrder()
Local cIndCond	:= ""                                               
Local cSituacao	:= MV_PAR06
Local nRegX		:= 1

oSection1:SetLineCondition(cAcessaSRA)

oSection2:SetLineCondition( {|| fCheckSq8() })

//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                         �
//� MV_PAR01        //  Filial                                   � 
//� MV_PAR02        //  Matricula                                � 
//� MV_PAR03        //  Nome                                     � 
//� MV_PAR04        //  Centro Custo                             � 
//� MV_PAR05        //  Cargo                                    � 
//� MV_PAR06        //  Situacao do Funcionario					 � 
//� MV_PAR07        //  Imprime Graduacao S/N                    � 
//� MV_PAR08        //  Fator Graduacao                          � 
//� MV_PAR09        //  Impr Pontos S/N  		                 � 
//� MV_PAR10        //  Impr Somente Totais Ptos S/N             � 
//� MV_PAR11       	//  Imprime Desc. Detalhada do Fator S/N 	 � 
//� MV_PAR12       	//  Imprime Observacao do Fator Funcion. S/N � 
//� MV_PAR13        //  Imprime Historico Carreira S/N           � 
//� MV_PAR14        //  Imprime Historico Carreira Empresa S/N   � 
//� MV_PAR15        //  Imprime Cursos S/N                       � 
//� MV_PAR16        //  Imprime Cursos Realizados S/N/Ambos      � 
//� MV_PAR17       	//  Imprime Sinonimo de Curso S/N 			 � 
//� MV_PAR18        //  Imprime Cursos Extracurriculares S/N     � 
//� MV_PAR19        //  Imprime Solicitacao Cursos S/N           � 
//� MV_PAR20        //  Imprime Avaliacoes Cursos S/N			 � 
//� MV_PAR21       	//  Imprime Habilidades                      � 
//� MV_PAR22        //  Impr. um Funcion. por Folha S/N          � 
//����������������������������������������������������������������

//��������������������������Ŀ
//� Graduacao do Funcionario �
//����������������������������
If MV_PAR07 <> 1
	oSection2:Disable()
EndIf        

//�������������������������������������������������������������������Ŀ
//� Imprime Pontos dos Fatores de Graduacao do Cargo e do Funcionario �
//���������������������������������������������������������������������
If MV_PAR09 <> 1    
	oSection2:Cell("Q2_PONTOSI"):Disable()
	oSection2:Cell("Q8_PONTOS"):Disable()
EndIf	

//������������������������������������������������������������������������������Ŀ
//� Imprime Totais dos Pontos dos Fatores de Graduacao do Cargo e do Funcionario �
//��������������������������������������������������������������������������������
If MV_PAR10 = 1               
	TRFunction():New(oSection2:Cell("Q2_PONTOSI"),/*cId*/,"SUM",/*oBreak*/,/*cTitle*/,"@E 9999.99"/*cPicture*/,/*uFormula*/,/*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/)
	TRFunction():New(oSection2:Cell("Q8_PONTOS"),/*cId*/,"SUM",/*oBreak*/,/*cTitle*/,"@E 9999.99"/*cPicture*/,/*uFormula*/,/*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/)
EndIf

//��������������������������������������Ŀ
//� Imprime Descricao Detalhada do Fator �
//����������������������������������������
If MV_PAR11 <> 1
	oSection2:Cell("Q1_DESCDET"):Disable()	
	oSection2:Cell("Q1_MEMO1"):Disable() 
Else 
	oSection2:Cell("Q1_DESCDET"):Disable()	
	oSection2:Cell("Q1_MEMO1"):SetLineBreak() //Impressao de campo Memo
EndIf                                     

//�����������������������������������������Ŀ
//� Imprime Observacao do Fator Funcionario �
//�������������������������������������������
If MV_PAR12 <> 1      	
	oSection2:Cell("Q8_OBS"):Disable()
	oSection2:Cell("Q8_MEMO1"):Disable() 
Else
	oSection2:Cell("Q8_OBS"):Disable()
	oSection2:Cell("Q8_MEMO1"):SetLineBreak() //Impressao de campo Memo
	oSection2:SetLineBreak()
EndIf

//�����������������������Ŀ
//� Historico de Carreira �
//�������������������������
If MV_PAR13 <> 1
	oSection3:Disable()
EndIf

//����������������������������������Ŀ
//� Historico de Carreira na Empresa �
//������������������������������������
If MV_PAR14 <> 1
	oSection4:Disable()
EndIf

//�����������������������Ŀ
//� Cursos do Funcionario �
//�������������������������
If MV_PAR15 <> 1
	oSection5:Disable()
EndIf

//��������������������Ŀ
//� Graduacao do Cargo �
//����������������������
/*If MV_PAR16
	
EndIf */

//����������������������������Ŀ
//� Imprime Sinonimo do Cursos �
//������������������������������
If MV_PAR17 <> 1
	oSection5:Cell("RA4_SINONI"):Disable()	
	oSection5:Cell("RA9_DESCR"):Disable()	
Endif

//��������������������������Ŀ
//� Cursos Extracurriculares �
//����������������������������
If MV_PAR18 <> 1 
	oSection6:Disable()
EndIf

//��������������������������Ŀ
//� Solicitacao de Curso     �
//����������������������������
If MV_PAR19 <> 1 
	oSection7:Disable()
Else
	oSection7:Cell("RA3_RESERV"):Disable()
EndIf

//���������������������������Ŀ
//� Avaliacoes de Treinamento �
//�����������������������������
If MV_PAR20 <> 1 
	oSection8:Disable()
EndIf

//�������������Ŀ
//� Habilidades �
//���������������
If MV_PAR21 <> 1 
	oSection9:Disable()
EndIf

//����������������������������������Ŀ
//� Imprime Um Funcionario por Folha �
//������������������������������������
If MV_PAR22 == 1   		
	oSection1:SetPageBreak(.T.) //Salta Pagina		
EndIf

cSitQuery	:= ""
// filtro do relatorio
//Transforma parametros do tipo Range em expressao ADVPL para ser utilizada no filtro
MakeSqlExpr("TRR20R")
cAliasX	:= GetNextAlias()
//-- Modifica variaveis para a Query
For nRegX:=1 to Len(cSituacao)
	cSitQuery += "'"+Subs(cSituacao,nRegX,1)+"'"
	If ( nRegX+1 ) <= Len(cSituacao)
		cSitQuery += "," 
	Endif
Next nRegX     
cSitQuery := "%" + cSitQuery + "%"

oSection1:BeginQuery()

If nOrdem == 1
	cOrdem := "%RA_FILIAL,RA_MAT%"
ElseIf nOrdem == 2
	cOrdem := "%RA_FILIAL,RA_NOME%" 
ElseIf nOrdem == 3
	cOrdem := "%RA_FILIAL,RA_CC%"
Elseif nOrdem == 4
	cOrdem := "%RA_FILIAL,RA_CARGO%"
Endif

BeginSql alias cAliasX  //"SRA"              
	SELECT RA_FILIAL, RA_MAT, RA_NOME, RA_NASC, RA_ADMISSA, RA_ESTCIVI, RA_CARGO, RA_CC
FROM %table:SRA% SRA 
WHERE	SRA.RA_SITFOLH IN (%exp:Upper(cSitQuery)%) AND
		SRA.%notDel%   
		ORDER BY %exp:cOrdem%
	EndSql
END REPORT QUERY oSection1 PARAM MV_PAR01, MV_PAR02, MV_PAR03 , MV_PAR04 , MV_PAR05

oSection1:EndQuery()

dbSelectArea( cAliasX )                              
   		    
//���������������������������Ŀ
//� Condicao para Impressao   �
//�����������������������������
oSection2:SetRelation({|| xFilial("SQ8", (cAliasX)->RA_FILIAL) + (cAliasX)->RA_MAT} ,"SQ8",1,.T.)
oSection2:SetParentFilter({|cParam| SQ8->Q8_FILIAL+SQ8->Q8_MAT == cParam},{|| (cAliasX)->RA_FILIAL + (cAliasX)->RA_MAT })

oSection3:SetRelation({|| xFilial("SQC", (cAliasX)->RA_FILIAL) + (cAliasX)->RA_MAT} ,"SQC",1,.T.)
oSection3:SetParentFilter({|cParam| SQC->QC_FILIAL+SQC->QC_MAT == cParam},{|| (cAliasX)->RA_FILIAL + (cAliasX)->RA_MAT})

oSection4:SetRelation({|| xFilial("SR7", (cAliasX)->RA_FILIAL) + (cAliasX)->RA_MAT},"SR7",1,.T.)
oSection4:SetParentFilter({|cParam| SR7->R7_FILIAL+SR7->R7_MAT == cParam},{|| (cAliasX)->RA_FILIAL + (cAliasX)->RA_MAT }) 

//Criacao de Indice Temporario	
oSection5:SetFilter("", "RA4_FILIAL + RA4_MAT + RA4_CURSO + RA4_SINONI")
oSection5:SetRelation({|| xFilial("RA4", (cAliasX)->RA_FILIAL) + (cAliasX)->RA_MAT},"RA4", oSection8:GetIdxOrder(),.T.)
oSection5:SetParentFilter({|cParam| RA4->RA4_FILIAL + RA4->RA4_MAT == cParam}, {|| (cAliasX)->RA_FILIAL + (cAliasX)->RA_MAT})

oSection6:SetRelation({|| xFilial("SQ9", (cAliasX)->RA_FILIAL) + (cAliasX)->RA_MAT},"SQ9",1,.T.)
oSection6:SetParentFilter({|cParam| SQ9->Q9_FILIAL+SQ9->Q9_MAT == cParam},{|| (cAliasX)->RA_FILIAL + (cAliasX)->RA_MAT })
	
oSection7:SetRelation({|| xFilial("RA3", (cAliasX)->RA_FILIAL) + (cAliasX)->RA_MAT},"RA3",1,.T.)
oSection7:SetParentFilter({|cParam| RA3->RA3_FILIAL+RA3->RA3_MAT == cParam},{|| (cAliasX)->RA_FILIAL + (cAliasX)->RA_MAT })

//Criacao de Indice Temporario	
oSection8:SetFilter("","RAI_FILIAL+RAI_MAT+RAI_CALEND+RAI_CURSO+RAI_TURMA+RAI_TESTE")
oSection8:SetRelation({|| xFilial("RAI", (cAliasX)->RA_FILIAL) + (cAliasX)->RA_MAT},"RAI",oSection8:GetIdxOrder(),.T.)
oSection8:SetParentFilter({|cParam| RAI->RAI_FILIAL+RAI->RAI_MAT == cParam},{|| (cAliasX)->RA_FILIAL + (cAliasX)->RA_MAT })
	
oSection9:SetRelation({|| xFilial("RBI", (cAliasX)->RA_FILIAL) + (cAliasX)->RA_MAT},"RBI",1,.T.)
oSection9:SetParentFilter({|cParam| RBI->RBI_FILIAL+RBI->RBI_MAT == cParam},{|| (cAliasX)->RA_FILIAL + (cAliasX)->RA_MAT })
		                              
oReport:SetMeter((cAliasX)->(LastRec()))	
oSection1:Print() //Imprimir 

Return Nil       

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TrTotResult � Autor � Eduardo Ju          � Data � 30.06.06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Somatoria da Pontuacao da Avaliacao                         ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � TRMR020                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function TrTotResult()

Local cLoop 	:= RAI->RAI_MAT+RAI->RAI_CALEND+RAI->RAI_CURSO+RAI->RAI_TURMA+RAI->RAI_TESTE
Local nTotal 	:= 0
Local cSvAlias 	:= Alias()
Local lSkip 	:= .F.

DbSelectArea("RAI")
While !Eof() .And. RAI->RAI_MAT+RAI->RAI_CALEND+RAI->RAI_CURSO+RAI->RAI_TURMA+RAI->RAI_TESTE == cLoop
	lSkip := .T.
	nTotal += RAI->RAI_RESULT
	DbSkip()
EndDo

If lSkip
	DbSkip(-1)
EndIf

DbSelectArea(cSvAlias)

Return nTotal

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �FItEscCar   � Autor � Eduardo Ju          � Data � 17.10.07 ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Codigo e Descri��o do Item de Escala do 'Cargo'             ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � TRMR020                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function FItEscCar()  
  
Local aSaveArea	:= GetArea()
Local cCargo 	:= fGetCargo((cAliasX)->RA_MAT,(cAliasX)->RA_FILIAL)
Local cCC    	:= (cAliasX)->RA_CC  
	
dbSelectArea("SQ3")
dbSetOrder(1)

If dbSeek(xFilial("SQ3")+cCargo+cCC) .Or. dbSeek(xFilial("SQ3")+cCargo) 
    	
	dbSelectArea("RBH")
   	dbSetOrder(2)
	
	If dbSeek(xFilial("RBH")+SQ3->Q3_GRUPO+cCargo+cCC) .Or. dbSeek(xFilial("RBH")+SQ3->Q3_GRUPO+cCargo)
					
		While RBH->(!Eof()) 
							            
			If RBH->RBH_HABIL+RBH->RBH_ESCALA == RBI->RBI_HABIL+RBI->RBI_ESCALA  					
				cItEscCar := RBH->RBH_ITESCA
				Exit
			EndIf 
			
        	RBH->(dbSkip())
   		EndDo
		
	EndIf
EndIf  

RestArea(aSaveArea)
	    
Return cItEscCar

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �TRMR020   �Autor  �Microsiga           � Data �  10/28/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function fCheckSQ8()   

Local aAreaSq8	:= GetArea()
Local lRetorno	:= .F.

dbSelectArea("SQ8")
dbSetOrder(1) //Q8_FILIAL+Q8_MAT+Q8_FATOR
If dbSeek(xFilial("SQ8",(cAliasX)->RA_FILIAL)+(cAliasX)->RA_MAT+cFator)
	lRetorno	:= .T.
Endif
        
RestArea(aAreaSQ8)

Return(lRetorno)
