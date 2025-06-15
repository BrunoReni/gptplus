/*/  
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � DLGA080  � Autor � Renato ABPL           � Data � 05.12.00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastro de Tarefas x Atividades                           ���
���          �                                                            ���
���          � Sequencia de endereco de apanha dos produtos no armazem    ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �                                                            ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador    � Data   � BOPS �  Motivo da Alteracao                  ���
�������������������������������������������������������������������������Ĵ��
���Mauro Paladini �23/08/13�      �Conversao da rotina para o padrao MVC  ���
���Mauro Paladini �07/12/13�      �Ajustes para o funcionamento do Mile   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function DLGA080(cCodPro)
Return WMSA080()


//------------------------------------------------------------------------//
//--------- Retorna descri��o da atividade, do recurso humano e ----------//
//-------------------- do recurso f�sico para o Grid ---------------------//
//------------------------------------------------------------------------//
Function DLGA80DESC(nCampo)

Local oModel    := FWLoadModel("WMSA080")
Local oModelDC6 := oModel:GetModel( 'MdGridIDC6' )
Local nLinha    := oModelDC6:GetQtdLine()
Local cRetorno  := ''

//Impede que a descri��o apare�a na inclus�o de itens durante a altera��o
If nLinha > 0
   cRetorno := ''
Else
   If nCampo == 1
      cRetorno := Tabela('L3',DC6->DC6_ATIVID,.F.)
   ElseIf nCampo == 2
      cRetorno := Posicione('SRJ',1,xFilial('SRJ')+DC6->DC6_FUNCAO,'RJ_DESC')
   ElseIf nCampo == 3
      cRetorno := Tabela('L1',DC6->DC6_TPREC,.F.)
   EndIf
EndIf

Return cRetorno
