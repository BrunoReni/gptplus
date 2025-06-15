#INCLUDE "BADEFAPP.CH"

NEW APP Transporte

//-------------------------------------------------------------------
/*/{Protheus.doc} BAAppTMS
Modelagem da �rea de TMS.

@author  Angelo Lee
@since   03/12/2018
/*/
//-------------------------------------------------------------------
Class TmsAppFast
	Data cApp

	Method Init() CONSTRUCTOR
	Method ListEntities()
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} Init
Instancia a classe de App e gera um nome �nico para a �rea. 

@author  Angelo Lee
@since   03/12/2018
/*/
//-------------------------------------------------------------------
Method Init() Class TmsAppFast
	::cApp := "Transporte"
Return Self

//-------------------------------------------------------------------
/*/{Protheus.doc} ListEntities
Lista as entidades (fatos e dimens�es) dispon�veis da �rea, deve ser 
necessariamente o nome das classes das entidades.

@author  Angelo Lee
@since   03/12/2018
/*/
//-------------------------------------------------------------------
Method ListEntities() Class TmsAppFast
Return		{"EMPRESA"							, + ;
			"CLIENTE"							, + ;
			"FILIAL"							, + ;
			"REGIAO"							, + ;
			"ITEM"								, + ;
			"43TPDCT"							, + ;//--Tipo Documento de Transporte
			"43NEGTR"							, + ;//--Negocia��o de Transporte
			"43TTIPT"							, + ;//--Tipo de Transporte
			"43CMPFR"			 				, +	;//--Componente de Frete
			"43SRVNE"							, +	;//--Servi�o de Negocia��o
			"43STIND"							, + ;//--Status da Indeniza��o
			"43RmSeg"							, + ;//--Ramo de Seguro			
			"43Veicu"							, + ;//--Veiculos
			"43REGTR"							, + ;//--Regi�o de Transporte			
			"43TPOCO"							, +	;//--Tipo de Ocorr�ncia
			"43SrvTMS"							, + ;//--Servi�o TMS
			"43OcoTpt"							, +	;//--Ocorr�ncia de Transporte
			"43Ociosi"							, + ;//--Ociosidade do Ve�culo
			"43PFMENT"							, +	;//--Performance de Entrega						
			"43TABOCO"							, +	;//--Tabela de ocorr�ncia			
			"43MOVCAR"							, +	;//--Movimenta��o da Carga									
			"43INDTPT"							, + ;//--Indeniza��o e Transporte
			"43Viage"							, + ;//--Viagens
			"43RESOC"							, + ;//--Respons�vel Ocorr�ncia
			"43RECTPT"								}//--Receita de Transporte
	
			
