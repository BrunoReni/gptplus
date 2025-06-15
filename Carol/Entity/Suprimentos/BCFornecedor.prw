#INCLUDE "BCDEFINITION.CH"

NEW DATAMODEL FORNECEDOR

//-------------------------------------------------------------------
/*/{Protheus.doc} BCProduto
Visualizacao das informações  dos  fornecedores.

@author  jose.delmondes
@since   16/01/2020

/*/
//-------------------------------------------------------------------
Class BCFornecedor from BCEntity
	Method Setup( ) CONSTRUCTOR
	Method BuildView( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} Setup
Construtor padrão.

@author  jose.delmondes
@since   16/01/2020

/*/
//-------------------------------------------------------------------
Method Setup( ) Class BCFornecedor
	_Super:Setup("BCFornecedor", DIMENSION, "SA2", , .F.)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constrói a query da entidade.

@return aQuery, array, Retorna as consultas da entidade por empresa.

@author  jose.delmondes
@since   16/01/2020

/*/
//-------------------------------------------------------------------
Method BuildView( ) Class BCFornecedor
	Local cView := ""
	Local cDatabase := Upper( TcGetDb() )

	cView := "SELECT <<CODE_LINE>> AS TOTVS_LINHA_PRODUTO, " + ;
			        "<<CODE_INSTANCE>> AS INSTANCIA, " + ;
		            "<<CODE_COMPANY>> AS EMPRESA, " + ;
		            "A2_FILIAL AS FILIAL, A2_COD AS COD, A2_LOJA AS LOJA, A2_NOME RAZAO_SOCIAL, A2_NATUREZ AS NATUREZA, " + ;
		            "A2_NREDUZ AS NOME_FANTASIA, A2_END AS ENDERECO, A2_NR_END AS END_NUMERO, " + ;
		            "A2_BAIRRO AS BAIRRO, A2_EST AS ESTADO_SIGLA, A2_ESTADO AS ESTADO_NOME, A2_COD_MUN AS CODIGO_MUNICIPIO, " + ;
		            "A2_MUN AS MUNICIPIO, A2_CEP AS CEP, A2_TIPO AS TIPO, A2_CGC AS CGC, A2_DDI AS DDI, " + ;
		            "A2_DDD AS DDD, A2_TEL AS TELEFONE, A2_FAX AS FAX, A2_INSCR AS INSCRICAO_ESTADUAL, " + ;
		            "A2_INSCRM AS INSCRICAO_MUNICIPAL, A2_COND AS COND_PAGAMENTO, A2_MATR MAIOR_ATRASO, " + ;
		            "A2_MCOMPRA AS MAIOR_COMPRA, A2_METR AS MEDIA_ATRASO, A2_NROCOM AS NRO_COMPRAS, " + ;
		            "A2_MSALDO AS MAIOR_SALDO_CREDOR, A2_PRICOM AS PRIMEIRA_COMPRA, A2_ULTCOM AS ULTIMA_COMPRA, " + ;
		            "A2_SALDUP AS SALDO_DUPLICATAS, A2_DESVIO AS DESVIO_PRZ_ENTREGA, " + ;
		            "A2_EMAIL AS EMAIL, A2_HPAGE AS HOME_PAGE, A2_CONTATO AS CONTATO, "
	Do Case
		Case ( "ORACLE" $ cDatabase )
				cView += " CASE WHEN ( SELECT count(*) FROM all_tab_columns WHERE TABLE_NAME LIKE '%<<SA2_COMPANY>>%' AND COLUMN_NAME like '%A2_MSBLQL%') > 0 THEN A2_MSBLQL ELSE ' ' END AS A2_MSBLQL, "
		Case ( "MSSQL" $ cDatabase )
				cView += " CASE WHEN COL_LENGTH('<<SA2_COMPANY>>', 'A2_MSBLQL') > 0 THEN A2_MSBLQL ELSE ' ' END AS A2_MSBLQL, "
	EndCase
	cView += "A2_LC AS LIMITE_CREDITO, E4_DESCRI AS COND_DESCRICAO " + ;
             	"FROM <<SA2_COMPANY>> SA2 " + ; 
             	"LEFT JOIN <<SE4_COMPANY>> SE4 " + ; 
             		"ON SE4.E4_FILIAL = <<SUBSTR_SE4_A2_FILIAL>> " +;
             		"AND SE4.E4_CODIGO = SA2.A2_COND " +;
             		"AND SE4.D_E_L_E_T_ = ' ' " + ;
             	"WHERE SA2.D_E_L_E_T_ = ' ' " 
             
Return cView	