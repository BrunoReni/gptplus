#INCLUDE "MSOBJECT.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "LOJA7009.CH"

Function LOJA7009 ; Return  // "dummy" function - Internal Use

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Classe    |LJCFrmCupom      �Autor  �Fabiana Cristina    � Data �  19/11/2010 ���
��������������������������������������������������������������������������������͹��
���Desc.     �Janela para capturar as informacoes da venda a ser estornada       ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
Class LJCFrmCupom  	
   	Data oDlgVen														//Objeto Dialog da Venda
	Data oFontText                                                      //Objeto Fonte
	Data oBtnConf                                                       //Objeto Button Confirma
	Data oBtnCanc                                                       //Objeto Button Cancela
	Data oEstVenda														//Objeto do tipo Estorno
	Data cCupom															//C�digo do Cupom   
	Data oCupom															//Objeto para digitar o cupom 
	Data oSerie															//Objeto para digitar a s�rie						     
	Data cSerie														    //Numero da Serie 		   	   			
	Method New()								
	Method Show()														
									
EndClass

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Metodo    �New   	       �Autor  �Fabiana Cristina    � Data �  22/02/10   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Metodo construtor da classe LJCFrmCupom   			    	     ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������͹��
���Parametros�EXPO1 (1 - oEstVenda) - Objeto do tipo LjClEstVen     			 ���
��������������������������������������������������������������������������������͹��
���Retorno   �Objeto														     ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
Method New(oEstVenda) Class LJCFrmCupom
   
    Self:oDlgVen 	:= nil														//Objeto Dialog da Venda
	Self:oFontText 	:= nil                                                     //Objeto Fonte
	Self:oBtnConf  	:= nil                                                     //Objeto Button Confirma
	Self:oBtnCanc 	:= nil                                                      //Objeto Button Cancela
	Self:oEstVenda 	:= oEstVenda   											   //Objeto do tipo Lj600ClEst
	Self:cCupom 		:= ""													//C�digo do Cupom   
	Self:oCupom		:= nil														//Objeto para digitar o cupom 
	Self:oSerie		:= nil														//Objeto para digitar a s�rie						     
	Self:cSerie		:= ""													    //Numero da Serie 

Return Self

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Metodo    �Show  	       �Autor  �Vendas Clientes     � Data �  22/02/10   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Responsavel em exibir a tela.							    	     ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������͹��
���Parametros�																	 ���
��������������������������������������������������������������������������������͹��
���Retorno   �String														     ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
Method Show() Class LJCFrmCupom
	
Local oObj	 		:= Self						//Objeto criado para ser executado no ON INIT do Dialog. 			
Local cDesCup		:= ""						//Descri��o do label cupom ou Nota Fiscal
Local cPicDescCup	:= ""						//Picture da descri��o do label de cupom ou Nota Fiscal
Local lEmitNFCe		:= FindFunction("LjEmitNFCe") .AND. LjEmitNFCe()				//Indica a utilizacao da NFC-e
 
//����������������������Ŀ
//�Abre tela para digitar�
//������������������������ 
If SuperGetMv("MV_LJVFNFS", Nil, .F.) .Or. lEmitNFCe	//Verifica se a Nota de Simples Faturamento (Venda Futura) esta habilitada ou NFC-e
	Self:cCupom :=  space(Max(TamSx3("L1_DOCPED")[1],TamSx3("L1_DOCPED")[1]))
	cDesCup		:=	"Cupom / NF" //"Cupom / NF"
Else
	Self:cCupom :=  space(TamSx3("LG_TAMSER")[1])
	cDesCup		:=	STR0003 //"Cupom"
EndIf

cPicDescCup	:= Replic("9", Len(Self:cCupom))

Self:cSerie := space(TamSx3("LG_SERIE")[1])   

Self:cSerie := Self:oEstVenda:cSerie    

DEFINE FONT Self:oFontText NAME "Courier New" SIZE 07,15    

//"Estornar"   
DEFINE MSDIALOG Self:oDlgVen TITLE STR0001 FROM 323,112 TO 440,398 PIXEL STYLE DS_MODALFRAME STATUS
	
	//"Digite os dados da venda"
	@ 005,007 SAY   STR0002              SIZE 100,10 FONT Self:oFontText OF Self:oDlgVen PIXEL 
	//"Cupom"
	@ 020,007 SAY  cDesCup	             SIZE 40,08 FONT Self:oFontText OF Self:oDlgVen PIXEL             
	@ 020,045 MSGET Self:oCupom  VAR Self:cCupom  picture cPicDescCup SIZE 38,08 FONT Self:oFontText OF Self:oDlgVen PIXEL
	//"S�rie"
	@ 020,090 SAY   STR0004              SIZE 18,08 FONT Self:oFontText OF Self:oDlgVen PIXEL             
	@ 020,110 MSGET Self:oSerie  VAR Self:cSerie  picture "@!" SIZE 09,08 FONT Self:oFontText OF Self:oDlgVen PIXEL   
	
	// "C&onfirma"
	@ 040,030 BUTTON Self:oBtnConf PROMPT STR0005 SIZE 40,10 OF Self:oDlgVen PIXEL ACTION (Self:oEstVenda:BuscaOrcamento(Self:cCupom, Self:cSerie) , Self:oDlgVen:End() ) //"&Continuar"
	// "&Cancela"
	@ 040,073 BUTTON Self:oBtnCanc PROMPT STR0006 SIZE 40,10 OF Self:oDlgVen PIXEL ACTION Self:oDlgVen:End()  


ACTIVATE MSDIALOG Self:oDlgVen CENTERED
 
Return Nil
