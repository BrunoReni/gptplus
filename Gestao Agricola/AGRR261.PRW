#INCLUDE "RWMAKE.CH" 
#INCLUDE "MSOLE.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � AGRR261  � Autor � Danyel Bernuci        � Data � 14/12/05 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Autorizacao de Transferencia					              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAAGR                                                    ���
�������������������������������������������������������������������������Ĵ��
���           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            ���
�������������������������������������������������������������������������Ĵ��
��� PROGRAMADOR  � DATA   � BOPS �  MOTIVO DA ALTERACAO                   ���
�������������������������������������������������������������������������Ĵ��
���              �        �      �                                        ��� 
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function AGRR261()  
Local	oDlgWord 	:= NIL
Private	cPerg	 	:= "AGR261"
Private uDoc   		:= Nil
Private aInfo	 	:= {}

	@ 000,000 To 180,300 Dialog oDlgWord Title OemToAnsi("Autorizacao de Transferencia")												
	@ 020,020 Say OemToAnsi("Esta rotina consiste em imprimir autorizacao")
	@ 028,020 Say OemToAnsi("de transferencia em duas Unidades de Medidas") 
	@ 010,010 To 060,137
	@ 065,025 BmpButton Type 5 Action Eval( { ||Pergunte(cPerg,.t.) } )
	@ 065,060 BmpButton Type 6 Action (OLE_CloseFile(uDoc),OLE_CloseLink(uDoc),Eval( { || Pergunte(cPerg,.f.) , AGR261IMP() } ))
	@ 065,095 BmpButton Type 2 Action (Close(oDlgWord),nOpc := 2)
	Activate Dialog oDlgWord Centered

Return(Nil)
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �AGR261PROC� Autor � Danyel Bernuci        � Data � 14/12/05 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Seleciona o Modelo do Documento							  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � AGRR261                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function AGR261PROC()
Local 	sAlias		:= 	GetArea()
Local	cNameVar	:=	ReadVar()
Local 	cTipo			:= "Modelo de Documentos(*.DOT)  |*.DOT | "													
Local 	cNewPathArq	:= cGetFile(cTipo,OemToAnsi("Selecione o Documento de Autorizacao"))									

IF !Empty( cNewPathArq )
	IF Upper( Subst( AllTrim( cNewPathArq), - 3 ) ) == Upper( AllTrim( "DOT" ) )	
		Aviso( "Arquivo Selecionado" , cNewPathArq , { "OK" } )								
    Else
    	MsgAlert( "Arquivo Inv�lido ", "Aten��o" )															
    	Return
    EndIF
Else
    Aviso("Cancelada a Selecao!","Voce cancelou  a selecao do arquivo." ,{ "OK" } )													
    Return
EndIF

&cNameVar	:=	cNewPathArq

RestArea(sAlias)

Return .t.

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �AGR261IMP � Autor � Danyel Bernuci        � Data � 14/12/05 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Importa as Variaveis para o Modelo do Documento			  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � AGRR261                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function AGR261IMP()
Local uVar   := {} 
  
	//�����������������������������������������������������������������������Ŀ
	//�Inicializa o Ole com o MS-Word 97 ( 8.0 )						        �
	//�������������������������������������������������������������������������


 		uDoc := OLE_CreateLink('TMsOleWord97') ; OLE_NewFile(uDoc,mv_par02)
  		uVar := AGR261VAR()
  
        /*
   		��������������������������������������������������������������Ŀ
        � Ajustando as Variaveis do Documento                          �
   		����������������������������������������������������������������
		*/
		Aeval(	uVar																								,; 
				{ |x| OLE_SetDocumentVar( uDoc, x[1]  																,;
											IF( Subst( AllTrim( x[3] ) , 4 , 2 )  == "->"          			    ,; 
												Transform( x[2] , PesqPict( Subst( AllTrim( x[3] ) , 1 , 3 )		,;
																			Subst( AllTrim( x[3] )  				,;
										        			         			  - ( Len( AllTrim( x[3] ) ) - 5 )	 ;	
										          								 )	  	 							 ; 
																	      )                                          ;
												         )															,; 
												Transform( x[2] , x[3] )                                     		 ;
				  	 						  ) 														 	 		 ; 
										)																			 ;
				}     																 							 	 ;
			 )
		/*
   		��������������������������������������������������������������Ŀ
        � Atualiza as Variaveis                                        �
   		����������������������������������������������������������������
   		*/ 
        OLE_UpDateFields(uDoc)
 	    /*
		�����������������������������������������������������������������������Ŀ
		�Imprimindo o Documento                                                 �
		�������������������������������������������������������������������������
		*/
        
        OLE_SetProperty( uDoc, '450', .F. )
        
        
Return Nil

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �AGR261VAR � Autor � Danyel Bernuci        � Data � 14/12/05 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Faz o Tratamento das Variaveis							  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � AGRR261                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function AGR261VAR()
Local	aMeses	:=	{"Janeiro","Fevereiro","Marco","Abril","Maio","Junho","Julho","Agosto","Setembro","Outubro","Novembro","Dezembro"}
Local	cDsclio	:=	Space(40)
Local	cRgclio	:=	Space(20)
Local	cCgclio	:=	Space(14)
Local	cInclio	:=	Space(20)
Local	cEnclio	:=	Space(30)
Local	cMuclio	:=	Space(02)
Local	cUfclio	:=	Space(02)
Local	cDsclid	:=	Space(40)
Local	cRgclid	:=	Space(20)
Local	cCgclid	:=	Space(14)
Local	cInclid	:=	Space(20)
Local	cEnclid	:=	Space(30)
Local	cMuclid	:=	Space(02)
Local	cUfclid	:=	Space(02)
Local	cDsArma	:=	Space(40)
Local	cRgArma	:=	Space(20)
Local	cCgArma	:=	Space(14)
Local	cInArma	:=	Space(20)
Local	cEnArma	:=	Space(30)
Local	cMuArma	:=	Space(30)
Local	cUfArma	:=	Space(02)
Local	cDtaExt	:=	""
Local	cExtens	:=	""
Local	nQtdUn	:=	0
Local	nQtdSeg	:=	0
Local	cUm		:=	Space(02)
Local	cSegum	:=	Space(02)

Local	uVetor	:= 	{}
Local	__k,__i
Local	aFilName:=	{"REAIS","REAL","CENTAVOS","CENTAVO"} 
Local	aVarName:=	{"cExtUm"}
Private	cExtUm	:=	""
Private	cExtSeg	:=	""	 
      
		//������������������������������Ŀ
		//�Posiciona na Autorizacao Saida�
		//��������������������������������
      	DbSelectArea("NPI")
	  	DBSetOrder(1)
	  	If DbSeek(xFilial("NPI")+mv_par01)
			//����������������������������������������������Ŀ
			//�Verifica o Produto Relacionado a Transferencia�
			//������������������������������������������������
			DbSelectArea("SB1")
			DbSetOrder(1)
			If DbSeek(xFilial("SB1")+npi->npi_codpro)
	
				//�����������������������������������������Ŀ
				//�Verifica as Informacoes do Cliente origem�
				//�������������������������������������������
				DbSelectArea("SA1")
				DbSetOrder(1)
				If DbSeek(xFilial("SA1")+npi->npi_cdclio+npi->npi_ljclio)
					cDsclio	:=	Alltrim(sa1->a1_nome)
					cRgclio	:=	Alltrim(sa1->a1_pfisica)
					cCgclio	:=	Alltrim(sa1->a1_cgc)
					If Len(cCgclio)<14
						cCgclio	:=	Alltrim(Transform(cCgclio,"@r 999.999.999-99"))					
					Else
						cCgclio	:=	Alltrim(Transform(cCgclio,"@r 999.999.999/9999-99"))					
					Endif										
					cInclio	:=	Alltrim(sa1->a1_inscr)
					cEnclio	:=	Alltrim(sa1->a1_end)
					cMuclio	:=	Upper(SubStr(Alltrim(sa1->a1_mun),1,1))+Lower(SubStr(Alltrim(sa1->a1_mun),2,(Len(Alltrim(sa1->a1_mun))-1)))  
					cUfclio	:=	Alltrim(sa1->a1_est)


					//�������������������������������������������Ŀ
					//�Verifica as Informacoes do Cliente Destino �
					//���������������������������������������������
					DbSelectArea("SA1")
					DbSetOrder(1)
					DbSeek(xFilial("SA1")+npi->npi_cdclid+npi->npi_ljclid)
					cDsclid	:=	Alltrim(sa1->a1_nome)
					cRgclid	:=	Alltrim(sa1->a1_pfisica)
					cCgclid	:=	Alltrim(sa1->a1_cgc)
					If Len(cCgclid)<14
						cCgclid	:=	Alltrim(Transform(cCgclid,"@r 999.999.999-99"))					
					Else
						cCgclid	:=	Alltrim(Transform(cCgclid,"@r 999.999.999/9999-99"))					
					Endif										
					cInclid	:=	Alltrim(sa1->a1_inscr)
					cEnclid	:=	Alltrim(sa1->a1_end)
					cMuclid	:=	Upper(SubStr(Alltrim(sa1->a1_mun),1,1))+Lower(SubStr(Alltrim(sa1->a1_mun),2,(Len(Alltrim(sa1->a1_mun))-1)))
					cUfclid	:=	Alltrim(sa1->a1_est)


					//������������������������������������Ŀ
					//�Verifica as Informacoes do Armazem  �
					//��������������������������������������
					DbSelectArea("NNR")
					DbSetOrder(1)
					If DbSeek(xFilial("NNR")+npi->npi_arm)
						//����������������������������������������Ŀ
						//�Verifica o cliente amarrado ao Armazem  �
						//������������������������������������������
						DbSelectArea("SA1")
						DbSetOrder(1)
						If DbSeek(xFilial("SA1")+nnr->nnr_codcli+nnr->nnr_lojcli)							
							cDsArma	:=	Alltrim(sa1->a1_nome)
							cRgArma	:=	Alltrim(sa1->a1_pfisica)
							cCgArma	:=	Alltrim(sa1->a1_cgc)
							If Len(cCgArma)<14
								cCgArma	:=	Alltrim(Transform(cCgArma,"@r 999.999.999-99"))					
							Else
								cCgArma	:=	Alltrim(Transform(cCgArma,"@r 999.999.999/9999-99"))					
							Endif										
							cInArma	:=	Alltrim(sa1->a1_inscr)
							cEnArma	:=	Alltrim(sa1->a1_end)
							cMuArma	:=	Upper(SubStr(Alltrim(sa1->a1_mun),1,1))+Lower(SubStr(Alltrim(sa1->a1_mun),2,(Len(Alltrim(sa1->a1_mun))-1)))  
							cUfArma	:=	Alltrim(sa1->a1_est)
							//������������������Ŀ
							//�Verifica a Safra  �
							//��������������������
							DbSelectArea("NN1")
							DbSetOrder(1)
							If DbSeek(xFilial("NN1")+npi->npi_safra)							
								//�����������������������������������������������Ŀ
								//�Verifica se existe a primeira unidade de medida�
								//�e se a mesma eh diferente da unidade padrao	  �
								//�������������������������������������������������
								If Len(Alltrim(mv_par03))>0 .And. Alltrim(mv_par03)<>Alltrim(sb1->b1_um)	  
	 								cUm		:=	Alltrim(mv_par03)	
									nQtdUn	:=	Agrx001(Alltrim(sb1->b1_um),Alltrim(mv_par03),npi->npi_quant)									
									cExtUm	:=	Extenso(Round(nQtdUn,2))										
								Else
	 								cUm		:=	Alltrim(sb1->b1_um)
									nQtdUn	:=	Round(npi->npi_quant,2)
									cExtUm	:=	Alltrim(Extenso(nQtdUn))									
								Endif
	
								//�����������������������������������������������Ŀ
								//�Verifica se existe a segunda unidade de medida �
								//�e se a mesma eh diferente da unidade padrao	  �
								//�������������������������������������������������
							 	If Len(Alltrim(mv_par04))>0 .And. Alltrim(mv_par04)<>Alltrim(sb1->b1_um)	   
	 								cSegum	:=	Alltrim(mv_par04)
									nQtdSeg	:=	Agrx001(Alltrim(sb1->b1_um),Alltrim(mv_par04),npi->npi_quant)
									cExtSeg	:=	Alltrim(Extenso(Round(nQtdSeg,2)))										
							 		Aadd(aVarName,"cExtSeg")
							 	Endif
							 					        
				   				cDtaExt	:=	Alltrim(Str(Day(npi->npi_data)))+Space(01)+'de'+Space(01)+aMeses[Month(npi->npi_data)]+Space(01)+'de'+Space(01)+Alltrim(Str(Year(npi->npi_data)))
								
								For __k	:=	1 To Len(aVarName)
									For __i	:= 1 To Len(aFilName)
										If At(aFilName[__i],(&(aVarName[__k])))>0
											&(aVarName[__k])	:=	Alltrim(Stuff((&(aVarName[__k])),(At(aFilName[__i],(&(aVarName[__k])))),Len(Alltrim(aFilName[__i])),""))	
									    Endif
								    Next __i
								Next __k        								
								//���������������������������������������������������������Ŀ
								//�Faz a formatacao do extenso a ser impresso na autorizacao�
								//�����������������������������������������������������������
								cExtens	:=	Alltrim(Transform(nQtdUn,"@e 999,999,999.99"))+Space(01)+Alltrim(cUm)+Space(01)+"("+cExtUm+")"+Space(01)+Lower(Alltrim(Posicione('SAH',1,xFilial('SAH')+cUm,"AH_DESCPO")))+Space(01)+"de"+Space(01)+Lower(Alltrim(sb1->b1_desc))								
								If nQtdSeg>0 
									cExtens	+=	Space(01)+"que"+Space(01)+"corresponde"+Space(01)+"a"+Space(01)+Alltrim(Transform(nQtdSeg,"@e 999,999,999.99"))+Space(01)+Alltrim(cSegum)+Space(01)+"("+cExtSeg+")"+Space(01)+Lower(Alltrim(Posicione('SAH',1,xFilial('SAH')+cSegum,"AH_DESCPO")))
						        Endif
								aAdd( uVetor, {"VAR_CODIGO",Alltrim(npi->npi_codigo) ,"NPI->NPI_CODIGO"	,"Codigo Transferencia"    	})
								aAdd( uVetor, {"VAR_DATADC",cDtaExt					 ,""				,"Data por Extenso"         })
								aAdd( uVetor, {"VAR_SAFRA1",npi->npi_safra			 ,"NPI->NPI_SAFRA"	,"Safra"                    })
								aAdd( uVetor, {"VAR_SAFDES",Alltrim(nn1->nn1_descri) ,"NN1->NN1_DESCRI"	,"Descricao da Safra"       })
								aAdd( uVetor, {"VAR_DSARMA",cDsArma					 ,""				,"Descricao do Armazem"     })
								aAdd( uVetor, {"VAR_RGARMA",cRgArma					 ,""				,"Rg do Armazem" 		    })
								aAdd( uVetor, {"VAR_CGARMA",cCgArma					 ,""				,"Cnpj/Cpf do Armazem"      })
								aAdd( uVetor, {"VAR_INARMA",cInArma					 ,""				,"Inscricao do Armazem"     })
								aAdd( uVetor, {"VAR_ENARMA",cEnArma					 ,""				,"Endereco do Armazem"	    })
								aAdd( uVetor, {"VAR_MUARMA",cMuArma					 ,""				,"Municipio do Armazem"     })
								aAdd( uVetor, {"VAR_UFARMA",cUfArma					 ,""				,"Estado do Armazem"	    })
								aAdd( uVetor, {"VAR_DSCLIO",cDsclio					 ,""				,"Descricao Cliente Origem" })
								aAdd( uVetor, {"VAR_RGCLIO",cRgclio					 ,""				,"Rg Cliente Origem" 		})
								aAdd( uVetor, {"VAR_CGCLIO",cCgclio					 ,""				,"Cnpj/Cpf Cliente Origem" 	})
								aAdd( uVetor, {"VAR_INCLIO",cInclio					 ,""				,"Inscricao Cliente Origem"	})
								aAdd( uVetor, {"VAR_ENCLIO",cEnclio					 ,""				,"Endereco Cliente Origem" 	})
								aAdd( uVetor, {"VAR_MUCLIO",cMuclio					 ,""				,"Municipio Cliente Origem"	})
								aAdd( uVetor, {"VAR_UFCLIO",cUfclio					 ,""				,"Estado Cliente Origem"  	})
								aAdd( uVetor, {"VAR_EXTENS",cExtens					 ,""				,"Extenso das Unidades"  	})
								aAdd( uVetor, {"VAR_DSCLID",cDsclid					 ,""				,"Descricao Cliente Destin" })
								aAdd( uVetor, {"VAR_RGCLID",cRgclid					 ,""				,"Rg Cliente Destin" 		})
								aAdd( uVetor, {"VAR_CGCLID",cCgclid					 ,""				,"Cnpj/Cpf Cliente Destin" 	})
								aAdd( uVetor, {"VAR_INCLID",cInclid					 ,""				,"Inscricao Cliente Destin"	})
								aAdd( uVetor, {"VAR_ENCLID",cEnclid					 ,""				,"Endereco Cliente Destin" 	})
								aAdd( uVetor, {"VAR_MUCLID",cMuclid					 ,""				,"Municipio Cliente Destin"	})
								aAdd( uVetor, {"VAR_UFCLID",cUfclid					 ,""				,"Estado Cliente Destin"  	})
								aAdd( uVetor, {"VAR_OBSERV",Alltrim(npi->npi_obs)   ,"NPI->NPI_OBS"		,"Observacao"               })
							Else							
								Aviso('ATENCAO!',Alltrim(cUsername)+', nao existe informacoes da safra, favor verifique!',{'Ok'})	  																		
							Endif
						Else
							Aviso('ATENCAO!',Alltrim(cUsername)+', nao existe informacoes do cliente relacionado ao armazem, favor verifique!',{'Ok'})	  																		
						Endif
					Else
						Aviso('ATENCAO!',Alltrim(cUsername)+', nao existe informacoes do armazem, favor verifique!',{'Ok'})	  												
						Endif
				Else
					Aviso('ATENCAO!',Alltrim(cUsername)+', nao existe informacoes do cliente origem, favor verifique!',{'Ok'})	  			
				Endif		
	  		Else
				Aviso('ATENCAO!',Alltrim(cUsername)+', nao existe informacoes do produto da Safra, favor verifique!',{'Ok'})	  				  		
	  		Endif
	  	Else
			Aviso('ATENCAO!',Alltrim(cUsername)+', nao existe informacoes da transferencia para o relatorio, favor verifique!',{'Ok'})	  
	  	Endif	
                                                                                                         
Return(uVetor)
