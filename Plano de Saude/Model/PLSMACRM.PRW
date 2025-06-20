#INCLUDE "PLSMACRM.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "MSOLE.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} PLSMACRM
Classe modelo de criacao do documento word para o processo de demanda

@author Alexander Santos                    
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
Class PLSMACRM From PLSCONTR

DATA oWord AS OBJECT
DATA cErro AS STRING

METHOD New(nLinhas,nColunas,nLabelHeight,nLeftMargin,nRightMargin,nBottomMargin,nTopMargin,aDad) Constructor
METHOD Destroy()

EndClass     
//-------------------------------------------------------------------
/*/{Protheus.doc} New
Construtor da Class

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD New(nLinhas,nColunas,nLabelHeight,nLeftMargin,nRightMargin,nBottomMargin,nTopMargin,aDad) Class PLSMACRM
LOCAL nI				:= 1
LOCAL nHoraBase 		:= Seconds()
LOCAL cRootPath 		:= "\DOT\" //MsDocRmvBar( Upper(AllTrim(GetPvProfString( GetEnvServer(), "RootPath", "", GetADV97() ))) )+"\DOT\"
LOCAL cTempPath 		:= GetTempPath()
LOCAL cFile				:= "PLSPROCESSO.DOT"
LOCAL cMacro			:= "PLSPROCESSO"
LOCAL cDefault			:= STR0001 //"Valor n�o definido"
LOCAL aConf				:= {}         

DEFAULT ::oWord			:= NIL
DEFAULT nLinhas 		:= 1		// Numero de Linhas
DEFAULT nColunas 		:= 2		// Numero de colunas da tabela
DEFAULT nLabelHeight	:= 3		// Altura (em centimetros) da celula
DEFAULT nLeftMargin 	:= 1		// Margem esquerda da pagina
DEFAULT nRightMargin	:= 0.45		// Margem direita da pagina
DEFAULT nBottomMargin	:= 0		// Margem inferior da pagina
DEFAULT nTopMargin 		:= 1		// Margem do topo da pagina
DEFAULT aDad			:= {{"Adv_MatricNome"	,cDefault},;
							{"Adv_ParTit"		,cDefault},;
							{"Adv_Plano"		,cDefault},;
							{"Adv_Telefone"		,cDefault},;
							{"Adv_Uf"			,cDefault},;
							{"Adv_DtNascimento"	,cDefault},;
							{"Adv_DtAdesao"		,cDefault},;
							{"Adv_Idade"		,cDefault},;
							{"Adv_Acomod"		,cDefault},;
							{"Adv_TpProc"		,cDefault},;
							{"Adv_VlrUtl"		,cDefault},;
							{"Adv_VlrCtr"		,cDefault},;
							{"Adv_VlrApr"		,cDefault},;
							{"Adv_QtdApr"		,cDefault},;
							{"Adv_VlrAut"		,cDefault},;
							{"Adv_QtdAut"		,cDefault} }`
//������������������������������������������������������������������������
//� Verifica se o arquivo existe
//������������������������������������������������������������������������
If !File(cRootPath + cFile)
	::cErro := STR0002 //"Arquivo PLSPROCESSO.DOT n�o encontrado"
	Return
EndIf
//������������������������������������������������������������������������
//� Caminho temp
//������������������������������������������������������������������������
__CopyFile( cRootPath + cFile , cTempPath + cFile )

cRootPath := cTempPath
//������������������������������������������������������������������������
//� Preparando o documento padrao
//������������������������������������������������������������������������
::oWord := OLE_CreateLink()
//������������������������������������������������������������������������
//� Visualizacao do doc
//������������������������������������������������������������������������
OLE_SetProperty ( ::oWord, oleWdVisible, .T.)
//������������������������������������������������������������������������
//� Abrindo o novo arquivo
//������������������������������������������������������������������������
OLE_NewFile( ::oWord, cRootPath + cFile)
//������������������������������������������������������������������������
//� Preparando o arquivo
//������������������������������������������������������������������������
OLE_SetProperty( ::oWord, oleWdVisible, .F. )
OLE_SetProperty( ::oWord, oleWdPrintBack, .F. )
//������������������������������������������������������������������������
//� Matriz de configuracao
//������������������������������������������������������������������������
AaDD(aConf,{"nLinhas"		,Str(nLinhas) } )
AaDD(aConf,{"nColunas"		,Str(nColunas) } )
AaDD(aConf,{"nLabelHeight"	,Str(nLabelHeight) } )
AaDD(aConf,{"nLeftMargin"	,Str(nLeftMargin) } )
AaDD(aConf,{"nRightMargin"	,Str(nRightMargin) } )
AaDD(aConf,{"nBottomMargin"	,Str(nBottomMargin) } )
AaDD(aConf,{"nTopMargin"	,Str(nTopMargin) } )
//������������������������������������������������������������������������
//� Definicoes do doc
//������������������������������������������������������������������������
For nI:=1 To Len(aConf)
	OLE_SetDocumentVar( ::oWord, aConf[nI,1], aConf[nI,2] )
Next
//������������������������������������������������������������������������
//� Matriz de campos
//������������������������������������������������������������������������
For nI:=1 To Len(aDad)
	OLE_SetDocumentVar( ::oWord, aDad[nI,1], aDad[nI,2] )
Next
//������������������������������������������������������������������������
//� Executa a macro
//������������������������������������������������������������������������
OLE_ExecuteMacro( ::oWord, cMacro )
OLE_UpdateFields( ::oWord )
//������������������������������������������������������������������������
//� Definicao do doc
//������������������������������������������������������������������������
OLE_SetProperty( ::oWord, oleWdVisible, .T. )	
OLE_SetProperty( ::oWord, oleWdWindowState, "MAX" )
//���������������������������������������������������������������������������������������
//� Dura��o
//���������������������������������������������������������������������������������������
_Super:SetLog(nHoraBase)
//������������������������������������������������������������������������
//� Fim da rotina
//������������������������������������������������������������������������
Return(Self)
//-------------------------------------------------------------------
/*/{Protheus.doc} Destroy
Destroy o obj link e fecha o arquivo

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD Destroy() Class PLSMACRM
	FreeObj(Self:self)
Return
/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    �PLSMACRM  � Autor � Totvs				    � Data � 30/03/10 ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Somente para compilar a class							  ����
��������������������������������������������������������������������������ٱ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Function PLSMACRM
Return
