#INCLUDE "FDPD101.ch"
#include "eADVPL.ch"
/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � GetProduto()        �Autor: Paulo Amaral  � Data �         ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Trata qual tela de Produto sera utilizada (basica/Avancada)���
�������������������������������������������������������������������������Ĵ��
���Parametros� cProduto - Codigo do Produto								  ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
*/
Function GetProduto(cProduto, aPrdPrefix)
Local lRet:= .F.
HCF->(dbSetOrder(1))
HCF->(dbSeek(RetFilial("HCF")+"MV_SFATPRO"))
if HCF->(Found()) 
	if AllTrim(HCF->HCF_VALOR) == "2" 
		//Basico
		GetPD2(@cProduto,@lRet, aPrdPrefix)
//    Elseif AllTrim(HCF->HCF_VALOR) == "3" 
    	// Especifico (Ponto de entrada)
	Else
    	 //Avancado (Tela Padrao de Produto)
		GetPD1(@cProduto,@lRet, aPrdPrefix)
	Endif
Else  
   	 //Avancado (Tela Padrao de Produto)
	GetPD1(@cProduto,@lRet, aPrdPrefix)
Endif
Return lRet

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � PD1Load()           �Autor: Paulo Amaral  � Data �         ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Carrega List de Produto para a consulta avancada           ���
�������������������������������������������������������������������������Ĵ��
���Parametros� nTop      - Posicao do registro							  ���
���          � cGrupo    - Codigo do grupo  							  ���
���          � oLbx      - Listbox de produto							  ���
���          � lPaginacao- Indica se a funcao foi chamada a partir dos	  ���
���          � 			   botoes de paginacao (Up ou Down)				  ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
*/
//Function PD1Load(nTop,cGrupo,aProduto,oLbx)
Function PD1Load(nTop,cGrupo,oLbx,lPaginacao)
Local i       
Local nCargMax:=GetListRows(oLbx)

if nTop == 0 
  HB1->(dbSetOrder(3))
  HB1->(dbSeek(RetFilial("HB1")+cGrupo))
  if !HB1->(Eof())
    nTop := HB1->(Recno())
  endif
else
  HB1->(dbGoTo(nTop))
endif        

//Alert(nTop)
If (Empty(cGrupo) .Or. cGrupo <> cUltGrupo) .Or. (lPaginacao == .T.)
	aSize(aProduto,0)
	For i := 1 to nCargMax
	   if !HB1->(Eof()) .and. (HB1->HB1_GRUPO == cGrupo .Or. Empty(cGrupo))
		  AADD(aProduto,AllTrim(HB1->HB1_DESC))
	   else
		  break
	   endif
	   HB1->(dbSkip())
	Next                   
	cUltGrupo := cGrupo 	//atualiza ult. grupo selecionado
	SetArray(oLbx,aProduto)
Endif

Return nil

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � PD1Down()           �Autor: Paulo Amaral  � Data �         ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Tratamento da navegacao do List de Produto                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros� aProduto - Array de Produtos								  ���
���          � cGrupo   - Codigo do grupo  								  ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
*/
//Function PD1Down(nTop,cGrupo,aProduto,oLbx,nOrder)
Function PD1Down(nTop,cGrupo,oLbx,nOrder)

HB1->(dbGoTo(nTop))
HB1->(dbSkip(GetListRows(oLbx)))
if ( !HB1->(Eof()) .and. ( nOrder != 3 .OR. HB1->HB1_GRUPO == cGrupo) )
   nTop := HB1->(Recno())
else
   return nil
endif
//Return PD1Load(@nTop,cGrupo,aProduto,oLbx)
Return PD1Load(@nTop,cGrupo,oLbx,.T.)

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � PD1Up()             �Autor: Paulo Amaral  � Data �         ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Tratamento da navegacao do List de Produto                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros� aProduto - Array de Produtos								  ���
���          � cGrupo   - Codigo do grupo  								  ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
*/
//Function PD1Up(nTop,cGrupo,aProduto,oLbx,nOrder)
Function PD1Up(nTop,cGrupo,oLbx,nOrder)

HB1->(dbGoTo(nTop))
HB1->(dbSkip(-GetListRows(oLbx)))
if ( !HB1->(Bof()) .And. (nOrder != 3 .OR. HB1->HB1_GRUPO == cGrupo) )
   nTop := HB1->(Recno())
else 
	If Empty(cGrupo)	
		HB1->(dbGoTop())
   		nTop := HB1->(Recno())
  	Else
  		nTop := 0	//return nil
  	Endif
endif
//Return PD1Load(@nTop,cGrupo,aProduto,oLbx)
Return PD1Load(@nTop,cGrupo,oLbx,.T.)

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � PD1Find()           �Autor: Paulo Amaral  � Data �         ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Busca do Produto								              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� cProduto - Codigo do Produto								  ���
���          � aGrupo, nGrupo - Array e Posicao do grupo				  ���
���          � aControls - Array de Controles							  ���
���          � lCodigo - Busca por Codigo (T ou F) 						  ���
���          � aPrecos - Array de Precos								  ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
*/
Function PD1Find(cPesq,lCodigo,aGrupo,nGrupo,cProduto,aControls,oProd,aPrecos,oBox, aPrdPrefix)
Local nOrder := if(lCodigo,1,2)
Local cPrefixo := ""

cPesq := Upper(cPesq)    
If !Empty(aPrdPrefix[1,1]) .And. nOrder = 1
	If Empty(aPrdPrefix[1,3])
		cPrefixo := Replicate(aPrdPrefix[1,1], aPrdPrefix[1,2])
	Else
		cPrefixo := Replicate(aPrdPrefix[1,1], Val(aPrdPrefix[1,3]) - Len(cPesq))		
	EndIf
	If At(cPrefixo, cPesq) = 0
		cPesq := cPrefixo + cPesq
	EndIf
EndIf

dbSelectArea("HB1")
HB1->(dbSetOrder(nOrder)) 
HB1->(dbSeek(RetFilial("HB1")+cPesq))
if HB1->(Found())      
	//Alert(cPesq)
	//Alert(HB1->(Recno()))
	PD1Browse(aGrupo,nGrupo,@cProduto,aControls,oProd,aPrecos,oBox,HB1->(Recno()),nOrder)
else
    MsgStop(STR0001,STR0002) //"Produto n�o localizado!"###"Pesquisa Produto"
endif
Return nil

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � PD1End()            �Autor: Paulo Amaral  � Data �         ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Atualiza o Codigo do Produto                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros� cProduto - Codigo do Produtos							  ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
*/
Function PD1End(lRet,cProduto)

lRet := if ( Len(cProduto) > 0 , .t., .f.)
CloseDialog()

Return nil