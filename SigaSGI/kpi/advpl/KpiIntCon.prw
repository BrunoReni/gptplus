// ######################################################################################
// Projeto: KPI
// Modulo : Core
// Fonte  : KPIInternational - Contem a tradução do applet Java.
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 28.12.11 | 4003-Alexandre Alves da Silva String para Internacionalização do sistema.
// --------------------------------------------------------------------------------------
#include "KPIDefs.ch"
#include "KpiIntCon.ch"

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} cKPIIntContinue
Gera arquivos de internacionalização para o client

@author     0000 - BI Team
@version    P11
@since      28.12.12
/*/
//-------------------------------------------------------------------------------------
function cKPIIntContinue()
	local cTexto := ""
	
	//KpiJustificativaMeta
	cTexto += 'KpiJustificativaMeta_00005='+STR0001+CRLF/*//'"Período Até:"'*/
	cTexto += 'KpiJustificativaMeta_00006='+STR0002+CRLF/*//'"Meta Anterior:"'*/
	cTexto += 'KpiJustificativaMeta_00007='+STR0003+CRLF/*//'"Meta Informada:"'*/
	cTexto += 'KpiJustificativaMeta_00008='+STR0004+CRLF/*//'"Justificativa:"'*/         
	cTexto += 'KpiJustificativaMeta_00009='+STR0008+CRLF/*//' "Operação Inválida"'*/ 
	cTexto += 'KpiJustificativaMeta_00010='+STR0009+CRLF/*//' "A gravação da justificativa é obrigatória."'*/ 
	cTexto += 'KpiJustificativaMeta_00011='+STR0010+CRLF/*//' "Campo Obrigatório"'*/ 
	cTexto += 'KpiJustificativaMeta_00012='+STR0011+CRLF/*//' "A Justificativa não pode ficar em branco."'*/ 
	cTexto += 'KpiJustificativaMeta_00013='+STR0012+CRLF/*//' "Alteração - Meta em Lote"'*/ 
	cTexto += 'KpiJustificativaMeta_00014='+STR0013+CRLF/*//' "Alteração - Alvo"'*/ 
	cTexto += 'KpiJustificativaMeta_00015='+STR0014+CRLF/*//' "Alteração - Planilha de Valores"'*/ 
	cTexto += 'KpiJustificativaMeta_00016='+STR0015+CRLF/*//' "Exclusão - Planilha de Valores"'*/ 
	cTexto += 'KpiJustificativaMeta_00017='+STR0016+CRLF/*//' "Inclusão - Planilha de Valores"'*/   
	cTexto += 'KpiJustificativaMeta_00018='+STR0053+CRLF/*//' "Periodo:"'*/   

	//KpiParametrosSistema
	cTexto += 'KpiParametrosSistema_00055='+STR0005+CRLF/*//'Na inclusão'*/
	cTexto += 'KpiParametrosSistema_00056='+STR0006+CRLF/*//'Na alteração'*/
	cTexto += 'KpiParametrosSistema_00057='+STR0007+CRLF/*//'Na exclusão'*/
	cTexto += 'KpiParametrosSistema_00058='+STR0035+CRLF/*//'Somente os responsáveis pelo indicador, pela coleta ou pelo objetivo incluem anotações.'*/
	cTexto += 'KpiParametrosSistema_00059='+STR0055+CRLF/*//'Filtrar plano de ação e ação pelo usuário responsável'*/
	cTexto += 'KpiParametrosSistema_00060='+STR0056+CRLF/*//'Habilitar controle de aprovação do plano de ação'*/
	cTexto += 'KpiParametrosSistema_00061='+STR0065+CRLF/*//'O responsável por um scorecard pode acessar todos os filhos do scorecard. (não recomendado)'*/
	cTexto += 'KpiParametrosSistema_00062='+STR0066+CRLF/*//'O responsável por um Objetivo pode acessar todos os filhos do Objetivo. (não recomendado)'*/
	cTexto += 'KpiParametrosSistema_00063='+STR0067+CRLF/*//'Somente responsáveis pelo Objetivo, Indicador e Coleta alteram planilha de valores'*/
	cTexto += 'KpiParametrosSistema_00064='+STR0069+CRLF/*//'Personalizar título dos campos:'*/
	cTexto += 'KpiParametrosSistema_00065='+STR0070+CRLF/*//'Tendência'*/      


	//KpiListaNota 
	cTexto += 'KpiListaNota_00001='+STR0017+CRLF/*//' "Descrição"'*/
	cTexto += 'KpiListaNota_00002='+STR0018+CRLF/*//' "Anotações do "'*/
	cTexto += 'KpiListaNota_00003='+STR0019+CRLF/*//' "Por favor, selecione uma linha para edição."'*/
	cTexto += 'KpiListaNota_00004='+STR0020+CRLF/*//' "O campo Assunto deve ser preenchido.\n"'*/
	cTexto += 'KpiListaNota_00005='+STR0021+CRLF/*//' "O campo Nota deve ser preenchido.\n"'*/
	cTexto += 'KpiListaNota_00006='+STR0022+CRLF/*//' "Notas"'*/
	cTexto += 'KpiListaNota_00007='+STR0023+CRLF/*//' "Indicador:"'*/
	cTexto += 'KpiListaNota_00008='+STR0024+CRLF/*//' "Indicador Nome:"'*/
	cTexto += 'KpiListaNota_00009='+STR0025+CRLF/*//' "Período:"'*/
	cTexto += 'KpiListaNota_00010='+STR0026+CRLF/*//' "Meta:"'*/
	cTexto += 'KpiListaNota_00011='+STR0027+CRLF/*//' "Realizado:"'*/
	cTexto += 'KpiListaNota_00012='+STR0028+CRLF/*//' "Desempenho:"'*/
	cTexto += 'KpiListaNota_00013='+STR0029+CRLF/*//' "Assunto:"'*/
	cTexto += 'KpiListaNota_00014='+STR0030+CRLF/*//' "Observação:"'*/
	cTexto += 'KpiListaNota_00015='+STR0031+CRLF/*//' "Edição permitida, usuário é o proprietário da anotação."'*/
	cTexto += 'KpiListaNota_00016='+STR0032+CRLF/*//' "Edição bloqueada, usuário não é o proprietário da anotação."'*/
	cTexto += 'KpiListaNota_00017='+STR0033+CRLF/*//' "Data da Publicação de"'*/
	cTexto += 'KpiListaNota_00018='+STR0034+CRLF/*//' "Até"	'*/

    //
	cTexto += 'KpiUsuarioFrame_00041='+STR0036+CRLF/*//'Incluir'*/
	cTexto += 'KpiUsuarioFrame_00042='+STR0037+CRLF/*//'Alterar'*/
	cTexto += 'KpiUsuarioFrame_00043='+STR0038+CRLF/*//'Excluir'*/

	//
	cTexto += 'KpiGrupoPessoaFrame_00017='+STR0036+CRLF/*//''*/	
	cTexto += 'KpiGrupoPessoaFrame_00018='+STR0037+CRLF/*//''*/	
	cTexto += 'KpiGrupoPessoaFrame_00019='+STR0038+CRLF/*//''*/	

	//	
	cTexto += 'KpiMapaDrillObjetivo_00001='+STR0039+CRLF/*Organização:*/	
	cTexto += 'KpiMapaDrillObjetivo_00002='+STR0040+CRLF/*Estratégia:*/	
	cTexto += 'KpiMapaDrillObjetivo_00003='+STR0041+CRLF/*Perspectiva:*/	
	cTexto += 'KpiMapaDrillObjetivo_00004='+STR0042+CRLF/*Data Alvo:*/	
	cTexto += 'KpiMapaDrillObjetivo_00005='+STR0043+CRLF/*Acumulado De:*/	
	cTexto += 'KpiMapaDrillObjetivo_00006='+STR0044+CRLF/*Acumulado Até:*/	
	cTexto += 'KpiMapaDrillObjetivo_00007='+STR0045+CRLF/*Atualizar*/	
	cTexto += 'KpiMapaDrillObjetivo_00008='+STR0046+CRLF/*Causa*/	
	cTexto += 'KpiMapaDrillObjetivo_00009='+STR0047+CRLF/*Objetivo*/	
	cTexto += 'KpiMapaDrillObjetivo_00010='+STR0048+CRLF/*Efeito*/	
	cTexto += 'KpiMapaDrillObjetivo_00011='+STR0049+CRLF/*Indicador*/	

	//KpiRestricaoPlanValor
	cTexto += 'KpiRestricaoPlanValor_00001='+STR0050+CRLF/*"O bloqueio da Planilha de Valores é válido somente para \nindicadores cuja frequência: Mensal, Bimestral, Trimestral, \nQuadrimestral, Semestral e Anual."*/
	cTexto += 'KpiRestricaoPlanValor_00002='+STR0051+CRLF/*"Bloquear a atualização da Planilha de Valores pelo campo Dia Limite do Indicador."*/
	cTexto += 'KpiRestricaoPlanValor_00003='+STR0052+CRLF/*"Manutenção bloqueada para esse período por dia limite"*/
	cTexto += 'KpiRestricaoPlanValor_00004='+STR0054+CRLF/*"Mensagem no corpo do e-mail de notificação de finalização do prazo para atualização da Planilha de Valores"*/
	                                
	//KpiGrupoAcao
	cTexto += 'KpiGrupoAcao_00007='+STR0057+CRLF/*//'Este Plano de Ação já está aprovado e em execução.\nA alteração de status pode permitir que um Plano de Ação que já esteja em execução seja alterado.\nConfirma a alteração de status de 'Aprovado' para '#XXX#'?'*/
	cTexto += 'KpiGrupoAcao_00008='+STR0058+CRLF/*//'Status:'*/
	cTexto += 'KpiGrupoAcao_00009='+STR0059+CRLF/*//'Observação:'*/
	cTexto += 'KpiGrupoAcao_00010='+STR0060+CRLF/*//'Ações'*/

	//KpiPlanoDeAcao
	cTexto += 'KpiPlanoDeAcao_00066='+STR0061+CRLF/*//'O status da ação não pode ser alterado para ´Não Iniciado´.\n'*/
	cTexto += 'KpiPlanoDeAcao_00067='+STR0062+CRLF/*//'O plano de ação já está ´Aprovado´.'*/
	cTexto += 'KpiPlanoDeAcao_00068='+STR0063+CRLF/*//'Somente o responsável pelo plano de ação pode realizar esta operação.'*/
	cTexto += 'KpiPlanoDeAcao_00069='+STR0064+CRLF/*//'Somente os status ´Não Iniciado´ e ´Em Execução´ podem ser selecionados\n enquanto o Plano de Ação estiver ´Não Aprovado´'*/

	//MatrixFrameBehavior
	cTexto += 'MatrixFrameBehavior_00009='+STR0068+CRLF/*//'Selecione uma das opções para exclusão:\n\n'*/

	//KpiJBITree	
	cTexto += 'KpiJBITree_00001='+STR0071+CRLF //*//"Pesquisar Objetivo Estratégico+/
	cTexto += 'KpiJBITree_00002='+STR0072+CRLF //"Pesquisar Responsável"

	//KpiMapaFrame	
	cTexto += 'KpiMapaFrame_00036='+STR0073+CRLF //"Reexibir Texto"
	cTexto += 'KpiMapaFrame_00037='+STR0074+CRLF //"Reexibir Fundo"
	cTexto += 'KpiMapaFrame_00038='+STR0075+CRLF //"Retirar Imagem"

	//KpiGraphIndicador	
	cTexto += 'KpiGraphIndicador_00072='+STR0076+CRLF //"Faixa de valores entre "
	cTexto += 'KpiGraphIndicador_00073='+STR0077+CRLF //"Fora da faixa de valores"


	cTexto += 'KpiIndicador_00112='+STR0078+CRLF // "Melhor na Faixa"
	cTexto += 'KpiIndicador_00113='+STR0079+CRLF // 'Ao utilizar a orientação "Melhor na Faixa", o campo "Supera Em" necessita ser superior ao campo "Tolerância". Favor avaliar.'

	cTexto += 'KpiFormController_00008='+STR0080+CRLF // "Deseja excluir efetivamente esta imagem ?\n"
	cTexto += 'KpiFormController_00009='+STR0081+CRLF // "(Esta imagem será excluída fisicamente do diretório onde está contida)
	cTexto += 'KpiFormController_00010='+STR0082+CRLF // "Excluir imagem"    
	
	//KpiDataSourceFrame
	cTexto += 'KpiDataSourceFrame_00053='+STR0083+CRLF/*//' "Agregar valores automaticamente na planilha de valores"'*/   
return cTexto