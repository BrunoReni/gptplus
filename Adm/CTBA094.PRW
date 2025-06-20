#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'CTBA094.CH'

 /*
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
�����������������������������������������������������������������������������Ŀ��
���Programa  �CTBA094   �  Autor �Miguel Angel Rojas G.     � Data � 14.12.13 ���
�����������������������������������������������������������������������������Ĵ��
���Descri��o � TABLAS POR PUNTOS DE ASIENTO                                   ���
�����������������������������������������������������������������������������Ĵ��
���Sintaxe   � CTBA094()                                                      ���
�����������������������������������������������������������������������������Ĵ��
���Parametros�                                                                ���
�����������������������������������������������������������������������������Ĵ��
��� Uso      � GENERAL                                                        ���
�����������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.                 ���
�����������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS     �  Motivo da Alteracao                     ���
�����������������������������������������������������������������������������Ĵ��
���Miguel Rojas�07/02/14�          �Agregar campo CWO_INDVAL y los valores    ���
���            �        �          �admitidos en CWO_LLAVE                    ���
�����������������������������������������������������������������������������Ĵ��
���Miguel Rojas�10/02/14�          �Indices utilizados en DbSetOrder          ��� 
�����������������������������������������������������������������������������Ĵ��
���Miguel Rojas�12/02/14�          �Validacion campo CWO_LLAVE                ��� 
�����������������������������������������������������������������������������Ĵ��
���Miguel Rojas�25/02/14�          �Llama a la funcion CTB94CARGA             ���
�����������������������������������������������������������������������������Ĵ��
���Miguel Rojas�26/02/14�          �Cambio a tipo caracter CWO_INDVAL.        ���
������������������������������������������������������������������������������ٱ�
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
*/

Function CTBA094()
Private cTabla  := ""
Private cRetSix := ""
Private lBorrar := .T.
Private lNuevo  := .F.

CTB94CARGA()
oBrowse := FWMBrowse():New()
oBrowse:SetAlias("CVA")
oBrowse:SetDescription(STR0001)  // Asientos
oBrowse:SetMenuDef("CTBA094")
oBrowse:DisableDetails()
oBrowse:Activate()
Return NIL
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �MenuDef   � Autor � Miguel Angel Rojas G. � Data �23.12.2013���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Crea un Menu Estandar deshabilita Incluir y Excluir        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � MenuDef()                                                  ���   
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Menu Estandar                                               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CTBA094                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function MenuDef()
Local aRotina := {}
ADD OPTION aRotina	Title STR0003	Action "VIEWDEF.CTBA094" 	OPERATION 2 ACCESS 0   // Visualizar
ADD OPTION aRotina 	Title STR0004 Action "VIEWDEF.CTBA094" 	OPERATION 4 ACCESS 0   // Modificar 
ADD OPTION aRotina 	Title STR0005	Action "VIEWDEF.CTBA094"		OPERATION 5 ACCESS 0   // Borrar
ADD OPTION aRotina 	Title STR0006	Action "VIEWDEF.CTBA094" 	OPERATION 8 ACCESS 0   // Imprimir
ADD OPTION aRotina	Title STR0007	Action "VIEWDEF.CTBA094"		OPERATION 9 ACCESS 0   // Copiar
Return  aRotina

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcion   �ModelDef  � Autor �Miguel Angel. Rojas G. � Data �03/12/2013���
�������������������������������������������������������������������������Ĵ��
���Desc.     �Crea la estructura del modelo de datos llama                ���
���          �funciones para validar antes de guardar y al modificar      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ModelDef()                                                 ���   
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �ExpO1: Modelo de datos                                      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CTBA094                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
 
Static Function ModelDef()
Local oStruCVA := FWFormStruct( 1, "CVA" )
Local oStruCWO := FWFormStruct( 1, "CWO" )
Local oModel



//--- Objeto Constructor del Modelo de Datos
oModel := MPFormModel():New("CTBA094",/* { | oMdl | CTBA094PRE( oMdl ) } */, { | oMdl | CTBA094POS( oMdl ) }, { | oMdl | CTBA094COMM( oMdl ) },/*bCancel*/ )
//--- Agrega un Modelo para la captura de datos
oModel:AddFields( "CVAMASTER", /*es el encabezado*/, oStruCVA )

//--- Agrega Modelo de datos para el detalle
oModel:AddGrid( "CWODETAIL", "CVAMASTER", oStruCWO ,{|oModelGrid, nLine ,cAction,cField| CTB94LPRE(oModelGrid, nLine, cAction, cField) }, {|oModelGrid,cField| CBT94LPOS(oModelGrid, cField) })


//--- Establece la relaci�n entre las tablas
oModel:SetRelation( "CWODETAIL", { { "CWO_FILIAL", "xFilial( 'CWO' )" }, { "CWO_CODPTO" , "CVA_CODIGO"  } } , CWO->( IndexKey( 1 ) )  )

//--- No permite la duplicidad de registros con SetUniqueLine  
oModel:GetModel( "CWODETAIL" ):SetUniqueLine( { "CWO_CODPTO","CWO_TABLA" } )

//--- Descripci�n del Modelo de Datos
oModel:SetDescription( STR0011 )       // Puntos de Asiento
//----El modelo CVA solo sera de lectura.
oModel:GetModel( "CVAMASTER" ):SetOnlyQuery ( .T. )
//--- Valida que un Grid pueda quedar Vacio
oModel:GetModel( "CWODETAIL" ):SetOptional( .T. )

//--- Descripci�n de los componente del Modelo de Datos
oModel:GetModel( "CVAMASTER" ):SetDescription( STR0001 )  		// Asientos
oModel:GetModel( "CWODETAIL" ):SetDescription( STR0002 )		// Tablas Relacionadas
Return oModel

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcion   �ViewDef   � Autor �Miguel Angel. Rojas G. � Data �03/12/2013���
�������������������������������������������������������������������������Ĵ��
���Desc.     � Genera la vista de los datos de acuerdo al  modelo         ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ViewDef()                                                  ���   
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �EprO1: Objeto Vista                                         ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CTBA094                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function ViewDef()
Local oStruCVA := FWFormStruct( 2, "CVA" )
Local oStruCWO := FWFormStruct( 2, "CWO" )
Local oModel   := FWLoadModel( "CTBA094" )
Local oView

//--- Quita los campos de la estrutura para evitar duplicidad en pantalla
oStruCVA:RemoveField( "CVA_CFGLAN" )
oStruCWO:RemoveField( "CWO_CODPTO" )

//--- Hace de Solo Lectura el registro Descripcion
oStruCVA:SetProperty( "CVA_DESCRI", MVC_VIEW_CANCHANGE   , .F. )

oView := FWFormView():New()
oView:SetModel( oModel )    // el oView toma como base el objeto oModel para su construcci�n
oView:AddField( "VIEW_CVA", oStruCVA, "CVAMASTER" )
//--- Agrega los Grids para consulta 
oView:AddGrid(  "VIEW_CWO", oStruCWO, "CWODETAIL" )
//--- Hace un "box" horizontal para recibir elementos de la Vista
oView:CreateHorizontalBox( "SUPERIOR", 15 )
oView:CreateHorizontalBox( "INFERIOR", 85 )


//--- Relaciona EL ID del View con el "box" para mostrar
oView:SetOwnerView( "VIEW_CVA", "SUPERIOR" )
oView:SetOwnerView( "VIEW_CWO", "INFERIOR" )
Return oView

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcion   �CTB94CARGA� Autor �Miguel Angel. Rojas G. � Data �03/12/2013���
�������������������������������������������������������������������������Ĵ��
���Desc.     � Carga las tablas de sistema. Llama a la funcion            ���
���          � CTBA095()                                                  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �CTB94CARGA                                                  ���   
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CTBA094                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
 Function CTB94CARGA
 	 CTBA095()   // Llama al fuente para la carga automatica de tablas de sistema
 Return nil 


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcion   �CTB94VLDT � Autor �Miguel Angel. Rojas G. � Data �03/12/2013���
�������������������������������������������������������������������������Ĵ��
���Desc.     �Busca la descripcion de la tabla indicada                   ���
���          �y valida que exista la tabla                                ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CTB94VLDT()                                                ���   
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � ExpL1 = .t. Valida si no, manda un mensaje de error        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � X3_VALID CAMPO CWO_TABLA                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function CTB94VLDT()
Local lRet := .T.
Local cDesc:= ""

Local cAsiento 	:= rTrim(CVA->CVA_CODIGO)
Local oModel 		:= FWModelActive()
Local oModelCWO 	:= oModel:GetModel( "CWODETAIL" ) 

cTabla 	 			:= rTrim(oModel:GetValue( "CWODETAIL","CWO_TABLA" ))
If oModelCWO:IsInserted()
	lNuevo := .T.
Else 
	lNuevo := .F.
	lRet := CTB094SEEK(cTabla,cAsiento)
EndIF
	 
If lRet
	DbSelectArea("SX2")
	SX2 ->(DBSETORDER(1))	  //SX2_CHAVE	
	If SX2 ->(DbSeek(cTabla))
		cDesc := X2NOME()			
	Else
		cDesc := ""
		lRet :=.F.
		Help( ,, STR0010,, STR0008+cTabla, 1, 0 )   //Aviso , La Tabla No Existe en el diccionario de datos:
	EndIf
	If Empty(cTabla)
	   cDesc :=""
	endIF   
	oModelCWO:LoadValue("CWO_DESCRI", cDesc )
	oModelCWO:LoadValue("CWO_INDICE", " " )
	oModelCWO:LoadValue("CWO_LLAVE", " " )
Endif
		
Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcion   �CTB94KEY  � Autor �Miguel Angel. Rojas G. � Data �03/12/2013���
�������������������������������������������������������������������������Ĵ��
���Desc.     �Busca los indices realacionadas a la tabla indicada         ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CTB94KEY()                                                 ���   
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �.T.                                                         ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CTBA094                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function CTB94KEY()
Local cLlave	:= ""
Local cIndice	:= ""
Local cIndex	:= ""
Local cVar 	:= &(ReadVar())
Local oModel	:= FWModelActive()
Local oModelCWO := oModel:GetModel( "CWODETAIL" ) 
Local nTam		:= TamSX3("CWO_LLAVE")[1]
cTabla 		:= rTrim(oModel:GetValue( "CWODETAIL","CWO_TABLA" ))

IF !EMPTY(cTabla)
	cIndice := cTabla+cVAr
	DbSelectArea("SIX")
	SIX ->(DBSETORDER(1))	// INDICE+ORDEM
	If SIX ->(DbSeek(cIndice))
		 cIndex:= RetAsc(cVar,2,.f.)
		 oModelCWO:LoadValue("CWO_INDVAL", cIndex )  //Obtiene el numero del indice.		 
	EndIf
Else
     &(ReadVar()):=""
     oModelCWO:LoadValue("CWO_LLAVE", " " )
EndIF
	
Return .T.


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcion   �CTB94LPRE  � Autor �Miguel Angel. Rojas G.� Data �03/12/2013���
�������������������������������������������������������������������������Ĵ��
���Desc.     �Valida los datos ingresados en las celdas del ModelGrid     ���
���          �indicados                                                   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �CTB94LPRE(ExpO1,ExpN1,ExprC1,ExpC2)                         ���   
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpO1: Objeto Modelo Grid                                   ���
���          �ExpN1: Numerico indica en que linea del Grid se encuentra   ���
���          �ExpC1: Caracter tipo de accion realizada                    ���
���          �ExpC2: Caracter Campo de la tabla relacionado               ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �ExprL1  Si son correctas la validaciones devuelve .T.       ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CTBA094                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function CTB94LPRE( oModelGrid, nLinha, cAccion, cCampo )
Local oModel 		:= oModelGrid:GetModel()
Local nOperation 	:= oModel:GetOperation()
Local oModelCWO	:= oModel:GetModel( "CWODETAIL" )
Local cFuncion	:= rTrim(oModel:GetValue( "CWODETAIL","CWO_TIPO" ))
Local cAsiento 	:= rTrim(CVA->CVA_CODIGO)
Local lRet			:= .T.

cTabla 		:= rTrim(oModel:GetValue( "CWODETAIL","CWO_TABLA" ))
  
oModelCWO:SetNoDeleteLine( .f. )
   
If  (cAccion == "SETVALUE" .OR. cAccion == "DELETE") .AND. nOperation==MODEL_OPERATION_UPDATE
	If cFuncion == "S" .AND.(cAccion == "SETVALUE" .OR. cAccion == "DELETE")
		lRet := .F.
		Help( ,, STR0010,, STR0017, 1, 0 )    //Aviso, Registro de Sistema no Admite cambios
	Else
		IF oModelCWO:IsInserted()
			lNuevo := .t.
		Else		
	   		lRet := CTB094SEEK(cTabla,cAsiento)
			if !lRet
		   		Help( ,, STR0010,,STR0012+cTabla+STR0013, 1, 0 )	//Aviso, No se puede eliminar o modificar el registro, Esta siendo utilizada
			Endif
		EndIF
			
	EndIF						
EndIf

Return lRet



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcion   �CTBA094COMM� Autor �Miguel Angel. Rojas G.� Data �03/12/2013���
�������������������������������������������������������������������������Ĵ��
���Desc.     �Elimina o Guarda los cambios despues presionar              ���
���          �Confirmar                                                   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �CTBA094COMM(EprO1)                                          ���   
�������������������������������������������������������������������������Ĵ��
���Parametros�ExprO1: Objeto que contiene el modelo de datos              ���
���          �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CTBA094                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/


Function CTBA094COMM(oModel)
Local nOperation 	:= oModel:GetOperation()
Local cAsiento 	:= CVA->CVA_CODIGO
Local lRet			:= .T.

If nOperation ==	MODEL_OPERATION_DELETE
    If lBorrar 
 		DbSelectArea("CWO")
   		CWO->(DbSetOrder(1))		// CWO_FILIAL+CWO_TIPO+CWO_CODPTO
   		CWO->(DbSeek(xFilial("CWO")+"U"+cAsiento))   
   		While !Eof() .AND. CWO->(CWO_CODPTO)==cAsiento
   		    cTabla := CWO->CWO_TABLA
   	        lRet := CTB094SEEK(cTabla,cAsiento)
   	        DbSelectArea("CWO")
   			If  CWO->(CWO_TIPO=="U") .AND. lRet 		
   				RECLOCK("CWO",.F.)   				
   				CWO->(DbDelete())
   				CWO->(MsUnlock())
   			EndIf
   			CWO->(DbSkip())
   		EndDo
	EndIF	
ELSE
	FWFormCommit( oModel )
EndIF
Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcion   �CTBA094POS � Autor �Miguel Angel. Rojas G.� Data �03/12/2013���
�������������������������������������������������������������������������Ĵ��
���Desc.     �Valida que se eliminen las funciones de tipo sistema al     ���
���          �presionar Confirmar cuanto estamos en Borrar                ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �CTBA094POS(EprO1)                                           ���   
�������������������������������������������������������������������������Ĵ��
���Parametros�ExprO1: Objeto que contiene el modelo de datos              ���
���          �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CTBA094                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
          
Function CTBA094POS( oModel )
Local nOperation 	:= oModel:GetOperation()
Local oModelCWO	:= oModel:GetModel( "CWODETAIL" )


If nOperation == MODEL_OPERATION_DELETE   	
	lBorrar := IIf (IsBlind(),.T., MsgNoYes(STR0015))	           //Eliminar las tablas de este punto de asiento?
	oModelCWO:SetNoDeleteLine( .T. )
Else
   	oModelCWO:SetNoDeleteLine( .f. )				
EndIF

Return .t. 	


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcion   �CTBA94VLDI� Autor �Miguel Angel Rojas G.  � Data �11/12/2013���
�������������������������������������������������������������������������Ĵ��
���Desc.     �Valida que exista el Indice en la Tabla SIX                 ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CTBA94VLDI                                                 ���   
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � ExpL1 = .t. Valida si no, manda un mensaje de error        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �X3_VALID DE CAMPO: CWO_INDICE                               ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function CTBA94VLDI()
Local oModel   	:= FWModelActive()
Local oModelCWO	:= oModel:GetModel( "CWODETAIL" )
Local lRet			:= .F.
Local cVar			:= oModel:GetValue( "CWODETAIL","CWO_INDICE" )

//---Seleccionamos la tabla SIX para buscar los �ndices de las tablas.
cTabla 	:= oModel:GetValue( "CWODETAIL","CWO_TABLA" )
If !Empty(cTabla)
	DbSelectArea("SIX")
	SIX->(DbSeek(cTabla))
	While !Eof() .And. (SIX->INDICE == cTabla)
		If cVar == Alltrim(SIX->ORDEM)
	  	    lRet := .T.
	  	EndIf    
	  	SIX->(DbSkip())
	Enddo
	If !lRet 		
		Help( ,, STR0010,,STR0018,1, 0 )        //Aviso, El Indice no Existe en la Tabla SIX
	Else
		CTB94KEY()
	EndIF
Else
  lRet := .T.	
  If !Empty(&(ReadVar()))	
	Help( ,, STR0010,,STR0019,1, 0 )          //Aviso, No existe la tabla, indice invalido
	lRet := .F.
  endif	
EndIF

Return lRet	

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcion   �CTBA94DESC� Autor �Miguel Angel Rojas G.  � Data �06/01/2014���
�������������������������������������������������������������������������Ĵ��
���Desc.     � Regresa la descripcion de la tabla guardada                ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CTBA94DESC                                                 ���   
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � ExpC1 = Descripcion de la tabla guardada en CWO_TABLA      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � TABLA CWO_DESCRI  Inicializador estandar                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function CTBA94DESC
Local cDesc 	:= ""
Local cIdioma	:= Upper( Left( FWRetIdiom(), 2 ) )

cTabla	:= CWO->CWO_TABLA

If !Empty(cTabla)
   IF cTabla <>"SM0" 
		cDesc := 'POSICIONE("SX2",1,CWO->CWO_TABLA,"X2_NOME")'
	Else
	   Do Case
			Case cIdioma == "ES" //"SPANISH"  
				cDesc:= "EMPRESAS"
			Case cIdioma == "EN" //"ENGLISH"
				cDesc:= "COMPANY" 
			OTHERWISE			
				cDesc:= "FILIAL"
		EndCase
	Endif	
Else
    cDesc :='POSICIONE("SX2",1,cTabla,"X2_NOME")'
EndIF

Return (cDesc)



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcion   �CTB094SEEK� Autor �Miguel Angel Rojas G.  � Data �14/01/2014���
�������������������������������������������������������������������������Ĵ��
���Desc.     � Verifica que no este en uso la tabla o el asiento          ���
���          � en alguna formula                                          ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CTB094SEEK(ExpC1,ExpC2)                                    ���   
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpC1 = Tabla a buscar                                      ���
���          �ExpC2 = Asiento a buscar                                    ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � ExpL1 = .T. No encontro datos .F. encontro datos           ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CTBA094                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function CTB094SEEK(cVar,cBusca)
Local nLineas := 0
Local cFilCWQ 	:= FWCodFil("CWQ")
Local cFilCWM 	:= FWCodFil("CWM")
Local lRet		:=.T.
Local cQuery  	:=""
Local cTmpPer	:= CriaTrab(Nil,.F.)

//--- Armado de Query 
cQuery := " SELECT CWQ_CODFOR,CWQ_TABLA,CWM_LANPAD FROM "
cQuery += RetSQLName("CWQ")+" CWQ,       "
cQuery += RetSQLName("CWM")+" CWM  WHERE "
cQuery += " CWM_FILIAL='"+cFilCWM+"' AND "
cQuery += " CWM_LANPAD='"+cBusca+"'  AND "
cQuery += " CWM_CODFOR = CWQ_CODFOR  AND "
cQuery += " CWM.D_E_L_E_T_ = ' '     AND "
cQuery += " CWQ_FILIAL='"+cFilCWQ+"' AND "
cQuery += " CWQ_TABLA="+"'"+cVar+"'      "
cQuery += " AND CWQ.D_E_L_E_T_ = ' '     "

cQuery := ChangeQuery(cQuery)   
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTmpPer,.T.,.T.) 
Count to nLineas

//--- Si encuentra datos no se puede borrar o modificar
If nLineas > 0
    lRet := .F.
EndIf
	
Return lRet


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcion   �CTB94LPOS  � Autor �Miguel Angel. Rojas G.� Data �14/01/2014���
�������������������������������������������������������������������������Ĵ��
���Desc.     �Valida los datos ingresados en las celdas del ModelGrid     ���
���          �indicados                                                   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �CTB94LPOS(ExpO1,ExprC1)                                     ���   
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpO1: Objeto Modelo Grid                                   ���
���          �ExpC1: Caracter Campo de la tabla relacionado               ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �ExprL1  Si son correctas la validaciones devuelve .T.       ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CTBA094                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/                
Static Function CBT94LPOS( oModelGrid,cCampo )
Local oModel 		:= oModelGrid:GetModel()
Local cFuncion	:= rTrim(oModel:GetValue( "CWODETAIL","CWO_TIPO" ))
Local cIndice		:= oModel:GetValue( "CWODETAIL","CWO_INDICE")
Local cLlave		:= oModel:GetValue( "CWODETAIL","CWO_LLAVE")
Local lRet			:= .t.

IF (Empty(cIndice) .OR. Empty(cLlave)) .AND. (cFuncion =="U") 
	lRet := .F.     	
	Help( ,, STR0010,,STR0020, 1, 0 )	//Aviso, Los campos �ndice o llave no pueden estar vac�os en un registro de usuario	
EndIF
Return lRet

