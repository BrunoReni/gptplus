#Include "Protheus.Ch"
#Include "PLSA116.Ch"  
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PLSA116   �Autor  �Diogo Ximenes       � Data � 10/02/2010  ���
�������������������������������������������������������������������������͹��
���Desc.     �Fixa o prazo para Liquidar a divida do usuario.			  ���
�������������������������������������������������������������������������͹��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function PLSA116()  
Private cPerg 		:= "PLSA116"


If Pergunte(cPerg,.T.)
	//������������������������������������������Ŀ
	//�Chama a rotina para estorno d status...   �
	//��������������������������������������������
	MsAguarde({|| FixPrzUsr() }, STR0001, "", .T.) //"Prazo Liquida��o"
Else
	Return(.T.)
Endif  

Return(.T.)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �EstUsr    �Autor  �Diogo Ximenes       � Data � 10/12/2010  ���
�������������������������������������������������������������������������͹��
���Descri��o � Fixa o prazo para liquidar a divida do usuario.			  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FixPrzUsr()
                     
Local nMesAux	:= 0
Local nMes 		:= 0
Local nAno 		:= 0
Local nTotal	:= 0

//��������������������������Ŀ
//�Posiciona nos subcontratos�
//����������������������������
DbSelectArea("B81")
B81->(DbSetOrder(1))
If B81->(MsSeek(xFilial("B81")+MV_PAR01+MV_PAR02))
	If B81->B81_PACOOK == "0"
		While 	!B81->(Eof()) .And.; 
				B81->(B81_FILIAL+B81_CODINT+B81_CODEMP) == xFilial("B81")+MV_PAR01+MV_PAR02 
			
			If dDataBase >= B81->B81_VIGPA .And. (dDataBase <= B81_VIGFIM .Or. Empty(B81_VIGFIM))
  	        	B81->(DbSkip())
  	        	Loop
  	    	EndIf
			
			//���������������������������������������Ŀ
			//�Posiciona nas familias dos usu�rios.   �
			//�����������������������������������������
			DbSelectArea("BA3")
			BA3->(DbSetOrder(1))
		 	If BA3->(MsSeek(xFilial("BA3")+MV_PAR01+MV_PAR02))	
		 		While 	!BA3->(Eof()) .And.; 
						BA3->(BA3_FILIAL+BA3_CODINT+BA3_CODEMP) == xFilial("BA3")+MV_PAR01+MV_PAR02
					If BA3->BA3_PACOOK == "0" 	   		
						//��������������������Ŀ
						//�Posiciona nas vidas.�
						//����������������������
						DBSelectArea("BA1")  
						BA1->(DbSetOrder(13)) //BA1_FILIAL, BA1_CODINT, BA1_CODEMP, BA1_CONEMP, BA1_VERCON, BA1_SUBCON, BA1_VERSUB, BA1_MATRIC, BA1_TIPREG
						If BA1->(MsSeek(xFilial("BA1")+MV_PAR01+MV_PAR02))
							While 	!BA1->(Eof()) .And.; 
								BA1->(BA1_FILIAL+BA1_CODINT+BA1_CODEMP) == xFilial("BA1")+MV_PAR01+MV_PAR02 
								If BA1->BA1_PACOOK == "0"
									nMesAux	:= B81->B81_MESCAN + Month(dDataBase)
									nMes 	:= Iif(NOROUND(nMesAux/12,0) > 0,nMesAux-NOROUND(nMesAux/12,0)*12,nMesAux)
									nAno 	:= Iif(NOROUND(nMesAux/12,0) > 0,Year(dDataBase)+NOROUND(nMesAux/12,0),Year(dDataBase))					   	
								   	If 	!Empty(BA1->BA1_DATBLO) .And. ;
								   		Month(BA1->BA1_DATBLO) == nMes .And. ;
								   		Year(BA1->BA1_DATBLO) == nAno
										//��������������������������Ŀ
										//�Faz a alteracao dos dados.�
										//����������������������������
								   		BA1->(RecLock("BA1",.F.))
								   			BA1->BA1_TREGRA	:= "1"
								   			BA1->BA1_MESLIQ	:=AllTrim(Str(nMes))
								   			BA1->BA1_ANOLIQ	:= AllTrim(Str(nAno))
								   		BA1->(MsUnLock())
										nTotal ++	
									EndIf 		 
								EndIf	
								BA1->(DbSkip())					
							EndDo	  
						EndIf 
					EndIf
					BA3->(DbSkip())
				EndDo
			EndIf
   			B81->(DbSkip())				 
		EndDo
	EndIf
EndIf
//����������������������������������Ŀ
//�Exibe a mensagem para o usuario...�
//������������������������������������
If nTotal <= 0
	MsgAlert(STR0002) //"Nenhum Usu�rio foi Alterado!"
ElseIf nTotal == 1
	MsgAlert(STR0003) //"Foi Alterado um Usu�rio!"
ElseIf nTotal > 1
	MsgAlert(STR0004+AllTrim(str(nTotal))+STR0005) //"Foram Alterados "###" Usu�rios!"
EndIf                       

Return(.T.)