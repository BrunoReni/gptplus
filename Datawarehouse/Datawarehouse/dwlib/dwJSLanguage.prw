// ######################################################################################
// Projeto: DATA WAREHOUSE
// Modulo : Actions
// Fonte  : dwJSLanguage - Internacionaliza��o de arquivos do .js
// ---------+---------------------+------------------------------------------------------
// Data     | Autor               | Descricao
// ---------+---------------------+------------------------------------------------------
// 22.10.08 |3174-Valdiney V GOMES| Vers�o 3
// 25.11.08 |0548-Alan Candido    | FNC 00000007374/2008 (10) e 00000007385/2008 (8.11)
//          |                     | Implementa��o de fun��o para valida��o do arquivo JS (tradu��o)
// --------------------------------------------------------------------------------------
    
#include "dwincs.ch"
#include "dwJSLanguage.ch"

/*   
-------------------------------------------------------------------------
Valida a existencia ou necessidade de atualiza��o do arquivo js de idioma
-------------------------------------------------------------------------
*/
function validJSLanguage()
	local oFile	:= TDWFileIO():New(dwWebSitePath() + "\sigadw_" + IDIOMA2 + ".js")

return oFile:exists() .and. dtos(oFile:lastUpd()) < '20'+BUILD_WEB

/*   
-------------------------------------------------------------------------
Cria um arquivo .js com constantes de acordo com o idioma do Protheus. 
-------------------------------------------------------------------------
*/
function makeJsLanguage()   	
	Local oFile    		:= TDWFileIO():New(DWWebSitePath() + "\sigadw_" + IDIOMA2 + ".js")
  Local aMeses := {} , aStrs	:= getChString()  		
  Local nCount, nMes
    
 	if oFile:Exists()
    oFile:Erase()
	Endif 
	   
	oFile:Create(FO_EXCLUSIVE + FO_WRITE)  	
   
	//In�cio do corpo do arquivo sigadw_(IDIOMA2).js   
	For nCount := 1 to Len( aStrs )		
		oFile:writeLn('var ' + aStrs[nCount][1] + ' = "' + aStrs[nCount][2] + '";')
	Next nCount                  
 	For nMes := 1 to 12
		aAdd(aMeses, Substr(MesExtenso( nMes ),1,3) )
	Next	
 	oFile:writeLn('var MONTHS_ABR = [' + DWConcatMacro( "," , aMeses ) + '];')
	//Fim do corpo do arquivo sigadw_(IDIOMA2).js 	
	
	oFile:Close()
	oFile:Free() 
return   
   
/*   
-------------------------------------------------------------------------
Popula um array com as constantes do arquivo dwJSLanguage.ch
Ret: aRet -> Array, Array no formato {{cChave, xValor}}
-------------------------------------------------------------------------
*/
static function getChString()
	Local aStrs := {}
	
	//SigaDw3.js
  //Importante - Ao efetuar modifica��es neste arquivo, alterar a constante
  //             BUILD_WEB definida no arquivo dwVer.ch
	aAdd(aStrs, {"STR0001", STR0001} ) //"Verifique os caracteres "
	aAdd(aStrs, {"STR0002", STR0002} ) //"O nome do usu�rio cont�m caracteres inv�lidos."
	aAdd(aStrs, {"STR0003", STR0003} ) //"O nome do dom�nio cont�m caracteres inv�lidos."
	aAdd(aStrs, {"STR0003", STR0004} ) //"Nome do usu�rio n�o informado ou � inv�lido."
	aAdd(aStrs, {"STR0005", STR0005} ) //"Ender�o IP do destino � inv�lido."
	aAdd(aStrs, {"STR0006", STR0006} ) //"O nome do dom�nio cont�m informa��es inv�lidas."
	aAdd(aStrs, {"STR0007", STR0007} ) //"O endere�o deve terminar com tipo de dom�nio conhecido ou com o c�digo do pa�s (2 letras)."
	aAdd(aStrs, {"STR0008", STR0008} ) //"Este dom�nio n�o � um hostname v�lido"
	aAdd(aStrs, {"STR0009", STR0009} ) //"O preenchimento � obrigat�rio."
	aAdd(aStrs, {"STR0010", STR0010} ) //"O valor informado � inv�lido.<br>Caracteres v�lidos para este campo:<br>"
	aAdd(aStrs, {"STR0011", STR0011} ) //"O valor informado inv�lido. Ele deve come�ar com uma letra."
	aAdd(aStrs, {"STR0012", STR0012} ) //"O valor informado n�o � um endere�o de e-Mail v�lido.<br>Use o formato: nome@dominio.xxx[.yy]"
	aAdd(aStrs, {"STR0013", STR0013} ) //"O valor informado possue mais de uma ocorr�ncia do sinal"
	aAdd(aStrs, {"STR0014", STR0014} ) //"O valor informado possue mais de uma ocorr�ncia do ponto decimal."
	aAdd(aStrs, {"STR0015", STR0015} ) //"O n�mero de decimais informado ultrapassa o limite de "
	aAdd(aStrs, {"STR0016", STR0016} ) //" casas decimais."
	aAdd(aStrs, {"STR0017", STR0017} ) //"O valor informado n�o � um formato v�lido.<br>Use o formato DD/MM/YYYY."
	aAdd(aStrs, {"STR0018", STR0018} ) //"O m�s informado n�o � um m�s v�lido."
	aAdd(aStrs, {"STR0019", STR0019} ) //"O dia informado n�o � um dia v�lido."
	aAdd(aStrs, {"STR0020", STR0020} ) //"A primeira op��o n�o � v�lida. Escolha outra."
	aAdd(aStrs, {"STR0021", STR0021} ) //"O valor informado n�o � um formato v�lido.<br>Use o formato HH:MM:SS ou HH:MM, com rel�gio de 24h, <BR>pode-se colocar a hora (HH), minutos (MM) ou segundos (SS) com um ou dois d�gitos."
	aAdd(aStrs, {"STR0022", STR0022} ) //"A hora informada, n�o � uma hora v�lida."
	aAdd(aStrs, {"STR0023", STR0023} ) //"O minuto informado n�o � um minuto v�lido."
	aAdd(aStrs, {"STR0024", STR0024} ) //"O segundo informado n�o � um segundo v�lido."
	aAdd(aStrs, {"STR0025", STR0025} ) //"O valor informado � inferior a "
	aAdd(aStrs, {"STR0026", STR0026} ) //"O valor informado � superior a "
	aAdd(aStrs, {"STR0027", STR0027} ) //"Aten��o: Todas as ABAS ter�o seus dados restaurados para os valores inicias.\n\nConfirma desfazer?"
	aAdd(aStrs, {"STR0028", STR0028} ) //"A execu��o deste procedimento pode levar algum tempo,\nem fun��o do volume de dados ou mesmo outros fatores.\n\nConfirma o processamento?"
	aAdd(aStrs, {"STR0029", STR0029} ) //"Informe c�digo de confirma��o"
	aAdd(aStrs, {"STR0030", STR0030} ) //"C�digo de confirma��o n�o confere.\nVerifique qual �, no �nicio ou no final desta p�gina."
	aAdd(aStrs, {"STR0031", STR0031} ) //"Favor aguardar. Transferindo dados... "
	aAdd(aStrs, {"STR0032", STR0032} ) //"N�o foi possivel inicializar o elemento de comunica��o com o servidor (Http Request)"
	aAdd(aStrs, {"STR0033", STR0033} ) //"Ocorreu um erro de comunica��o com o servidor. Erro= "
	aAdd(aStrs, {"STR0034", STR0034} ) //"Favor selecionar um campo primeiro"
	aAdd(aStrs, {"STR0035", STR0035} ) //"Selecione uma op��o ou acione fechar."
	//calendar.js	
	aAdd(aStrs, {"STR0036", STR0036} ) //"Em branco"
	aAdd(aStrs, {"STR0037", STR0037} ) //"Fechar"
	aAdd(aStrs, {"STR0038", STR0038} ) //"Ajusta a data para"
	aAdd(aStrs, {"STR0039", STR0039} ) //"Selecione uma data"
	aAdd(aStrs, {"STR0040", STR0040} ) //"Selecione os minutos"
	aAdd(aStrs, {"STR0041", STR0041} ) //"Selecione a hora"
	aAdd(aStrs, {"STR0042", STR0042} ) //"Domingo"
	aAdd(aStrs, {"STR0043", STR0043} ) //"Segunda"
	aAdd(aStrs, {"STR0044", STR0044} ) //"Ter�a"
	aAdd(aStrs, {"STR0045", STR0045} ) //"Quarta"
	aAdd(aStrs, {"STR0046", STR0046} ) //"Quinta"
	aAdd(aStrs, {"STR0047", STR0047} ) //"Sexta"
	aAdd(aStrs, {"STR0048", STR0048} ) //"S�bado"
	aAdd(aStrs, {"STR0049", STR0049} ) //"Selecione os dias da semana"
	aAdd(aStrs, {"STR0050", STR0050} ) //"Selecione os dias"

return aStrs    
