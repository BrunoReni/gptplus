// ######################################################################################
// Projeto: KPI
// Modulo : Core
// Fonte  : KPIDefs.ch     
// -----------+-------------------+------------------------------------------------------
// Data       | Autor             | Descricao
// -----------+-------------------+------------------------------------------------------
// 18.08.2005   1776. Alexandre Alves da Silva
// --------------------------------------------------------------------------------------
#include "BIDefs.ch" 

// Tipos de log(cTipo) ao executar TBIKPICore:Log(cTexto, cTipo)
#define KPI_LOG_SCR			1
#define KPI_LOG_FILE    	2
#define KPI_LOG_RAISE   	3
#define KPI_LOG_SCRFILE 	4

// Response Status
#define KPI_ST_OK				0
#define KPI_ST_BADID			1
#define KPI_ST_INUSE			2
#define KPI_ST_UNIQUE			3
#define KPI_ST_NOCMD			4
#define KPI_ST_NOTRANSACTION	5
#define KPI_ST_BADXML			6
#define KPI_ST_NORIGHTS			7
#define KPI_ST_HASCHILD			8
#define KPI_ST_EXPIREDSESSION	9
#define KPI_ST_GENERALERROR		10
#define KPI_ST_VALIDATION		11
#define KPI_ST_FORMULA_CHANGE	12
#define KPI_ST_NOEMAILACTION          13
#define KPI_ST_NOEMAILMESSAGE          14

// Tipos de dados trafegaveis
#define KPI_BOOLEAN			0
#define KPI_DATE			1
#define KPI_FLOAT			2
#define KPI_INT				3
#define KPI_STRING			4
#define KPI_PERCENT			5
#define KPI_IMAGEM			6

// Feedback do sistema KPI
#define KPI_FB_GRAY			0
#define KPI_FB_REDDN		1
#define KPI_FB_REDUP		2
#define KPI_FB_REDSM		3
#define KPI_FB_YELLOWDN		4
#define KPI_FB_YELLOWUP		5
#define KPI_FB_YELLOWSM		6
#define KPI_FB_GREENDN		7
#define KPI_FB_GREENUP		8
#define KPI_FB_GREENSM		9
#define KPI_FB_BLUEDN		10
#define KPI_FB_BLUEUP		11
#define KPI_FB_BLUESM		12

// Classe do Data Source
#define KPI_SRC_TOP				0
#define KPI_SRC_ADVPL			1
#define KPI_SRC_DW				2
#define KPI_SRC_FORMULA			3

// Configuracao do Data Source para TopConnect
#define KPI_SRC_ENVIRONMENT		1
#define KPI_SRC_CUSTOM			2

// Tipo de Planilha de Indicador
#define KPI_PLAN_INDICADOR		1     
#define KPI_PLAN_REFERENCIA		2

// Frequencias
#define KPI_FREQ_ANUAL			1
#define KPI_FREQ_SEMESTRAL		2
#define KPI_FREQ_TRIMESTRAL		3
#define KPI_FREQ_QUADRIMESTRAL	4
#define KPI_FREQ_BIMESTRAL		5
#define KPI_FREQ_MENSAL			6
#define KPI_FREQ_QUINZENAL		7
#define KPI_FREQ_SEMANAL		8
#define KPI_FREQ_DIARIA			9

// Montante
#define KPI_MT_SUM				0
#define KPI_MT_AVG				1
#define KPI_MT_EDT				2

// Segurança
#define  KPI_SEC_MANUTENCAO		1
#define  KPI_SEC_VISUALIZACAO	2
#define	 KPI_SEC_INCLUSAO		3
#define	 KPI_SEC_ALTERACAO		4
#define  KPI_SEC_EXCLUSAO		5

// Mensagens
#define KPI_MSG_ENVIADA			1
#define KPI_MSG_RECEBIDA		2
#define KPI_MSG_EXCLUIDA		3
#define KPI_MSG_DESCARTADA		4
#define KPI_MSG_BAIXA		    1
#define KPI_MSG_MEDIA			2
#define KPI_MSG_ALTA			3
#define KPI_MSG_REMETENTE		1
#define KPI_MSG_DESTINATARIO    2
#define KPI_MSG_PARA			1
#define KPI_MSG_CC				2

// Identificação de imagens, igual ao KpiImageResources.java
#define KPI_IMG_SCORECARD		0
#define KPI_IMG_INDICADOR		1
#define KPI_IMG_PROJETO			2
#define KPI_IMG_PLANOACAO		3
#define KPI_IMG_USUARIO			4
#define KPI_IMG_METAFORMULA		5
#define KPI_IMG_GRUPOINDICADOR	6
#define KPI_IMG_VAZIO			24
#define KPI_IMG_PLANO_OWNER		26
#define KPI_IMG_PLANO_RESP		27 
#define KPI_IMG_DIRUSUARIO		37
#define KPI_IMG_GRUPO_USUARIO	38
#define KPI_IMG_PLANO_LOCK		45
#define KPI_IMG_EXCLAMACAO		49
#define KPI_IMG_NOTA			61
#define KPI_IMG_ORGANIZACAO		62
#define KPI_IMG_ESTRATEGIA		63
#define KPI_IMG_PERSPECTIVA		64
#define KPI_IMG_OBJETIVO		65
#define KPI_IMG_PASTINHA		78
#define KPI_IMG_CAD_ABERTO		79
#define KPI_IMG_CAD_VERMELHO	80
#define KPI_IMG_NOTA_AZUL		81
#define KPI_IMG_NOTA_VERDE		82

//Constantes para os icones de status do indicador.
#define STATUS_GREEN		11
#define STATUS_RED			12
#define STATUS_YELLOW 		13
#define ESTAVEL_GREEN  		14
#define ESTAVEL_RED  		15
#define ESTAVEL_YELLOW		16
#define TEND_GREENDN  		17
#define TEND_GREENUP  		18
#define TEND_REDDN	   		19
#define TEND_REDUP	  		20
#define TEND_YELLOWDN		21
#define TEND_YELLOWUP 		22
#define SCORECARD_ACAO 		23
#define	 ESTAVEL_GRAY		25   

#define TEND_BLUEDN			72
#define TEND_BLUEUP			73
#define ESTAVEL_BLUE		74
#define STATUS_BLUE			75 

//Constantes para uso do ProgressBar
#define PROGRESS_BAR_ERROR		-1
#define PROGRESS_BAR_OK			0
#define PROGRESS_BAR_END		1

//Constantes que identificam a marca em que o SGI esta funcionado SGITRADE
#define MICROSIGA		1
#define LOGOCENTER		2
#define RM				3   

//Constantes de permissão para manutenção na planilha de dados
#define KPI_PLANIND_NORIGHTS   -1   //Sem permissão de visualização.
#define KPI_PLANIND_OK 			0	//Permitido.
#define KPI_PLANIND_NOUPDATE	1	//Usuário sem permissão para efetuar manutenção.
#define KPI_PLANIND_FORMULE		2   //Manutenção bloqueada para indicadores com fórmulas.
#define KPI_PLANIND_OWNER 		3	//Somente responsáveis podem alterar o indicador.
#define KPI_PLANIND_PERIOD 		4 	//Manutenção bloqueada para o período.
#define KPI_PLANIND_PERIODUSER  5   //Manutenção bloqueada por usuário para o período.
#define KPI_PLANIND_PERIODSCO   6	//Manutenção bloqueada por departamento para o período.
#define KPI_PLANIND_DIALIMITE	7	//Manutenção bloqueada por dia limite.

//Espinha de Peixe
#define KPI_ROOT	0
#define KPI_EFEITO	1
#define KPI_CAUSA	2   

//License Key
#define KPI_LICENSEKEY	"KPI_LK" 

// Valores no Grafico
#define GRAPH_VALUE			0
#define GRAPH_PERCENT		1

// Tipos de Análise
#define ANALISE_AMBAS		0
#define ANALISE_PARCELADA	1
#define ANALISE_ACUMULADA	2

//aValores
#define VAL_REAL			1
#define VAL_META			2
#define VAL_REAL_ACU		3
#define VAL_META_ACU		4
#define VAL_REAL_STATUS		5
#define VAL_ACUM_STATUS		6
#define VAL_PREVIA			7

//Modo de Analise.
#define ANALISE_PDCA "1"
#define ANALISE_BSC  "2"   

//Tipo de cadastros para o BSC
#define CAD_SCORECARD   ""
#define CAD_ORGANIZACAO "1"
#define CAD_ESTRATEGIA  "2"
#define CAD_PERSPECTIVA "3"
#define CAD_OBJETIVO    "4"


#define ELM_GRUPO		"1"
#define ELM_OBJETIVO	"2"

#define SHP_RECT		"1"
#define SHP_CIRCLE		"2"

#define LINE_RECT		"1"
#define LINE_CURVE		"2"

#define MAP_MODEL1		"1"
#define MAP_MODEL2		"2"                                          

//responsavel pelo indicador e pela coleta
#Define RESP_IND		"TP_RESP"
#Define RESP_COL		"TP_RESPCOL"     
                           
//Tipo de responsavel usado no indicador
#Define TIPO_USUARIO 	"U"
#Define TIPO_GRUPO		"G"                               

//status Grupo de Acao
#Define	GRUPOACAO_NAO_INICIADO	"1"
#Define GRUPOACAO_EM_APROVACAO	"2"
#Define GRUPOACAO_APROVADO		"3"                                                               

//status Acao
#Define	ACAO_NAO_INICIADA	"1"
#Define	ACAO_EM_EXECUCAO	"2"
#Define	ACAO_EXECUTADA		"3"
#Define	ACAO_PENDENTE		"4"
#Define	ACAO_ADIADA			"5"
#Define	ACAO_CANCELADA		"6"