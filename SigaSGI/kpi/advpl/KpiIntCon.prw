// ######################################################################################
// Projeto: KPI
// Modulo : Core
// Fonte  : KPIInternational - Contem a tradu��o do applet Java.
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 28.12.11 | 4003-Alexandre Alves da Silva String para Internacionaliza��o do sistema.
// --------------------------------------------------------------------------------------
#include "KPIDefs.ch"
#include "KpiIntCon.ch"

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} cKPIIntContinue
Gera arquivos de internacionaliza��o para o client

@author     0000 - BI Team
@version    P11
@since      28.12.12
/*/
//-------------------------------------------------------------------------------------
function cKPIIntContinue()
	local cTexto := ""
	
	//KpiJustificativaMeta
	cTexto += 'KpiJustificativaMeta_00005='+STR0001+CRLF/*//'"Per�odo At�:"'*/
	cTexto += 'KpiJustificativaMeta_00006='+STR0002+CRLF/*//'"Meta Anterior:"'*/
	cTexto += 'KpiJustificativaMeta_00007='+STR0003+CRLF/*//'"Meta Informada:"'*/
	cTexto += 'KpiJustificativaMeta_00008='+STR0004+CRLF/*//'"Justificativa:"'*/         
	cTexto += 'KpiJustificativaMeta_00009='+STR0008+CRLF/*//' "Opera��o Inv�lida"'*/ 
	cTexto += 'KpiJustificativaMeta_00010='+STR0009+CRLF/*//' "A grava��o da justificativa � obrigat�ria."'*/ 
	cTexto += 'KpiJustificativaMeta_00011='+STR0010+CRLF/*//' "Campo Obrigat�rio"'*/ 
	cTexto += 'KpiJustificativaMeta_00012='+STR0011+CRLF/*//' "A Justificativa n�o pode ficar em branco."'*/ 
	cTexto += 'KpiJustificativaMeta_00013='+STR0012+CRLF/*//' "Altera��o - Meta em Lote"'*/ 
	cTexto += 'KpiJustificativaMeta_00014='+STR0013+CRLF/*//' "Altera��o - Alvo"'*/ 
	cTexto += 'KpiJustificativaMeta_00015='+STR0014+CRLF/*//' "Altera��o - Planilha de Valores"'*/ 
	cTexto += 'KpiJustificativaMeta_00016='+STR0015+CRLF/*//' "Exclus�o - Planilha de Valores"'*/ 
	cTexto += 'KpiJustificativaMeta_00017='+STR0016+CRLF/*//' "Inclus�o - Planilha de Valores"'*/   
	cTexto += 'KpiJustificativaMeta_00018='+STR0053+CRLF/*//' "Periodo:"'*/   

	//KpiParametrosSistema
	cTexto += 'KpiParametrosSistema_00055='+STR0005+CRLF/*//'Na inclus�o'*/
	cTexto += 'KpiParametrosSistema_00056='+STR0006+CRLF/*//'Na altera��o'*/
	cTexto += 'KpiParametrosSistema_00057='+STR0007+CRLF/*//'Na exclus�o'*/
	cTexto += 'KpiParametrosSistema_00058='+STR0035+CRLF/*//'Somente os respons�veis pelo indicador, pela coleta ou pelo objetivo incluem anota��es.'*/
	cTexto += 'KpiParametrosSistema_00059='+STR0055+CRLF/*//'Filtrar plano de a��o e a��o pelo usu�rio respons�vel'*/
	cTexto += 'KpiParametrosSistema_00060='+STR0056+CRLF/*//'Habilitar controle de aprova��o do plano de a��o'*/
	cTexto += 'KpiParametrosSistema_00061='+STR0065+CRLF/*//'O respons�vel por um scorecard pode acessar todos os filhos do scorecard. (n�o recomendado)'*/
	cTexto += 'KpiParametrosSistema_00062='+STR0066+CRLF/*//'O respons�vel por um Objetivo pode acessar todos os filhos do Objetivo. (n�o recomendado)'*/
	cTexto += 'KpiParametrosSistema_00063='+STR0067+CRLF/*//'Somente respons�veis pelo Objetivo, Indicador e Coleta alteram planilha de valores'*/
	cTexto += 'KpiParametrosSistema_00064='+STR0069+CRLF/*//'Personalizar t�tulo dos campos:'*/
	cTexto += 'KpiParametrosSistema_00065='+STR0070+CRLF/*//'Tend�ncia'*/      


	//KpiListaNota 
	cTexto += 'KpiListaNota_00001='+STR0017+CRLF/*//' "Descri��o"'*/
	cTexto += 'KpiListaNota_00002='+STR0018+CRLF/*//' "Anota��es do "'*/
	cTexto += 'KpiListaNota_00003='+STR0019+CRLF/*//' "Por favor, selecione uma linha para edi��o."'*/
	cTexto += 'KpiListaNota_00004='+STR0020+CRLF/*//' "O campo Assunto deve ser preenchido.\n"'*/
	cTexto += 'KpiListaNota_00005='+STR0021+CRLF/*//' "O campo Nota deve ser preenchido.\n"'*/
	cTexto += 'KpiListaNota_00006='+STR0022+CRLF/*//' "Notas"'*/
	cTexto += 'KpiListaNota_00007='+STR0023+CRLF/*//' "Indicador:"'*/
	cTexto += 'KpiListaNota_00008='+STR0024+CRLF/*//' "Indicador Nome:"'*/
	cTexto += 'KpiListaNota_00009='+STR0025+CRLF/*//' "Per�odo:"'*/
	cTexto += 'KpiListaNota_00010='+STR0026+CRLF/*//' "Meta:"'*/
	cTexto += 'KpiListaNota_00011='+STR0027+CRLF/*//' "Realizado:"'*/
	cTexto += 'KpiListaNota_00012='+STR0028+CRLF/*//' "Desempenho:"'*/
	cTexto += 'KpiListaNota_00013='+STR0029+CRLF/*//' "Assunto:"'*/
	cTexto += 'KpiListaNota_00014='+STR0030+CRLF/*//' "Observa��o:"'*/
	cTexto += 'KpiListaNota_00015='+STR0031+CRLF/*//' "Edi��o permitida, usu�rio � o propriet�rio da anota��o."'*/
	cTexto += 'KpiListaNota_00016='+STR0032+CRLF/*//' "Edi��o bloqueada, usu�rio n�o � o propriet�rio da anota��o."'*/
	cTexto += 'KpiListaNota_00017='+STR0033+CRLF/*//' "Data da Publica��o de"'*/
	cTexto += 'KpiListaNota_00018='+STR0034+CRLF/*//' "At�"	'*/

    //
	cTexto += 'KpiUsuarioFrame_00041='+STR0036+CRLF/*//'Incluir'*/
	cTexto += 'KpiUsuarioFrame_00042='+STR0037+CRLF/*//'Alterar'*/
	cTexto += 'KpiUsuarioFrame_00043='+STR0038+CRLF/*//'Excluir'*/

	//
	cTexto += 'KpiGrupoPessoaFrame_00017='+STR0036+CRLF/*//''*/	
	cTexto += 'KpiGrupoPessoaFrame_00018='+STR0037+CRLF/*//''*/	
	cTexto += 'KpiGrupoPessoaFrame_00019='+STR0038+CRLF/*//''*/	

	//	
	cTexto += 'KpiMapaDrillObjetivo_00001='+STR0039+CRLF/*Organiza��o:*/	
	cTexto += 'KpiMapaDrillObjetivo_00002='+STR0040+CRLF/*Estrat�gia:*/	
	cTexto += 'KpiMapaDrillObjetivo_00003='+STR0041+CRLF/*Perspectiva:*/	
	cTexto += 'KpiMapaDrillObjetivo_00004='+STR0042+CRLF/*Data Alvo:*/	
	cTexto += 'KpiMapaDrillObjetivo_00005='+STR0043+CRLF/*Acumulado De:*/	
	cTexto += 'KpiMapaDrillObjetivo_00006='+STR0044+CRLF/*Acumulado At�:*/	
	cTexto += 'KpiMapaDrillObjetivo_00007='+STR0045+CRLF/*Atualizar*/	
	cTexto += 'KpiMapaDrillObjetivo_00008='+STR0046+CRLF/*Causa*/	
	cTexto += 'KpiMapaDrillObjetivo_00009='+STR0047+CRLF/*Objetivo*/	
	cTexto += 'KpiMapaDrillObjetivo_00010='+STR0048+CRLF/*Efeito*/	
	cTexto += 'KpiMapaDrillObjetivo_00011='+STR0049+CRLF/*Indicador*/	

	//KpiRestricaoPlanValor
	cTexto += 'KpiRestricaoPlanValor_00001='+STR0050+CRLF/*"O bloqueio da Planilha de Valores � v�lido somente para \nindicadores cuja frequ�ncia: Mensal, Bimestral, Trimestral, \nQuadrimestral, Semestral e Anual."*/
	cTexto += 'KpiRestricaoPlanValor_00002='+STR0051+CRLF/*"Bloquear a atualiza��o da Planilha de Valores pelo campo Dia Limite do Indicador."*/
	cTexto += 'KpiRestricaoPlanValor_00003='+STR0052+CRLF/*"Manuten��o bloqueada para esse per�odo por dia limite"*/
	cTexto += 'KpiRestricaoPlanValor_00004='+STR0054+CRLF/*"Mensagem no corpo do e-mail de notifica��o de finaliza��o do prazo para atualiza��o da Planilha de Valores"*/
	                                
	//KpiGrupoAcao
	cTexto += 'KpiGrupoAcao_00007='+STR0057+CRLF/*//'Este Plano de A��o j� est� aprovado e em execu��o.\nA altera��o de status pode permitir que um Plano de A��o que j� esteja em execu��o seja alterado.\nConfirma a altera��o de status de 'Aprovado' para '#XXX#'?'*/
	cTexto += 'KpiGrupoAcao_00008='+STR0058+CRLF/*//'Status:'*/
	cTexto += 'KpiGrupoAcao_00009='+STR0059+CRLF/*//'Observa��o:'*/
	cTexto += 'KpiGrupoAcao_00010='+STR0060+CRLF/*//'A��es'*/

	//KpiPlanoDeAcao
	cTexto += 'KpiPlanoDeAcao_00066='+STR0061+CRLF/*//'O status da a��o n�o pode ser alterado para �N�o Iniciado�.\n'*/
	cTexto += 'KpiPlanoDeAcao_00067='+STR0062+CRLF/*//'O plano de a��o j� est� �Aprovado�.'*/
	cTexto += 'KpiPlanoDeAcao_00068='+STR0063+CRLF/*//'Somente o respons�vel pelo plano de a��o pode realizar esta opera��o.'*/
	cTexto += 'KpiPlanoDeAcao_00069='+STR0064+CRLF/*//'Somente os status �N�o Iniciado� e �Em Execu��o� podem ser selecionados\n enquanto o Plano de A��o estiver �N�o Aprovado�'*/

	//MatrixFrameBehavior
	cTexto += 'MatrixFrameBehavior_00009='+STR0068+CRLF/*//'Selecione uma das op��es para exclus�o:\n\n'*/

	//KpiJBITree	
	cTexto += 'KpiJBITree_00001='+STR0071+CRLF //*//"Pesquisar Objetivo Estrat�gico+/
	cTexto += 'KpiJBITree_00002='+STR0072+CRLF //"Pesquisar Respons�vel"

	//KpiMapaFrame	
	cTexto += 'KpiMapaFrame_00036='+STR0073+CRLF //"Reexibir Texto"
	cTexto += 'KpiMapaFrame_00037='+STR0074+CRLF //"Reexibir Fundo"
	cTexto += 'KpiMapaFrame_00038='+STR0075+CRLF //"Retirar Imagem"

	//KpiGraphIndicador	
	cTexto += 'KpiGraphIndicador_00072='+STR0076+CRLF //"Faixa de valores entre "
	cTexto += 'KpiGraphIndicador_00073='+STR0077+CRLF //"Fora da faixa de valores"


	cTexto += 'KpiIndicador_00112='+STR0078+CRLF // "Melhor na Faixa"
	cTexto += 'KpiIndicador_00113='+STR0079+CRLF // 'Ao utilizar a orienta��o "Melhor na Faixa", o campo "Supera Em" necessita ser superior ao campo "Toler�ncia". Favor avaliar.'

	cTexto += 'KpiFormController_00008='+STR0080+CRLF // "Deseja excluir efetivamente esta imagem ?\n"
	cTexto += 'KpiFormController_00009='+STR0081+CRLF // "(Esta imagem ser� exclu�da fisicamente do diret�rio onde est� contida)
	cTexto += 'KpiFormController_00010='+STR0082+CRLF // "Excluir imagem"    
	
	//KpiDataSourceFrame
	cTexto += 'KpiDataSourceFrame_00053='+STR0083+CRLF/*//' "Agregar valores automaticamente na planilha de valores"'*/   
return cTexto