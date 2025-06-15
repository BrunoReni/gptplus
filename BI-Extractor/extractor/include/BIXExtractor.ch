#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "AP5MAIL.CH" 
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "SHELL.CH"
#include "FILEIO.CH"
#INCLUDE "FWMVCDEF.CH"  
#INCLUDE "FWEDITPANEL.CH"
#INCLUDE "FWCOMMAND.CH"

//-------------------------------------------------------------------
// XCOMMANDS. 
//-------------------------------------------------------------------
#XCOMMAND REGISTER EXTRACTOR <entity>;
	=>;
   Function <entity>_BI_();;
   Return nil
   
//-------------------------------------------------------------------
// APPS.
//-------------------------------------------------------------------
#DEFINE WITHOUT 		"0"
#DEFINE COMERCIAL 	 	"1" 
#DEFINE CONTROLADORIA 	"2"                      	
#DEFINE FINANCEIRO 	 	"3" 
#DEFINE MATERIAIS 	 	"4" 
#DEFINE PRODUCAO 	 	"5" 
#DEFINE RH		 	 	"6"
#DEFINE PCO     		"7"
#DEFINE DL 	 			"8"
#DEFINE SERVICO 		"9" 
#DEFINE VAREJO  		"10"
#DEFINE CRM  	 		"11"
#DEFINE JURIDICO 		"12"
#DEFINE DEVELOPER 		"99"   
  
//-------------------------------------------------------------------
// ENTITIES.
//-------------------------------------------------------------------
#DEFINE APP		 	1
#DEFINE FACT		2
#DEFINE DIMENSION 	3

//-------------------------------------------------------------------
// RECORDS.
//-------------------------------------------------------------------
#DEFINE UNDEFINED 	"_"
#DEFINE FORMULA		"-"
#DEFINE DATE_EMPTY	STOD('18000101')

//-------------------------------------------------------------------
// PERIODS.
//-------------------------------------------------------------------
#DEFINE PERIOD_RANGE			0
#DEFINE PERIOD_MONTH_RANGE		1
#DEFINE PERIOD_MONTH_CURRENT 	2
#DEFINE PERIOD_MONTH_FINAL		3
#DEFINE PERIOD_MONTH_HIST_INC   4

//-------------------------------------------------------------------
// LOGS.
//-------------------------------------------------------------------
#DEFINE LOG_RUNNING		1
#DEFINE LOG_ERROR		2
#DEFINE LOG_FINISH		3
#DEFINE LOG_CANCEL		4
#DEFINE LOG_UPDATED		5
#DEFINE LOG_LICENSE		5
#DEFINE LOG_DEBUG		6
#DEFINE LOG_LINK		7
//-------------------------------------------------------------------
// MESSAGE.
//-------------------------------------------------------------------
#DEFINE MSG_INFO		0 
#DEFINE MSG_EXCEPTION	1 
#DEFINE MSG_ERROR		2 
#DEFINE MSG_FATAL		3 
#DEFINE MSG_WARNING		4