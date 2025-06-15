// ######################################################################################
// Projeto: KPI
// Modulo : Core
// Fonte  : KPIInternational - Contem a tradu��o do applet Java.
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 08.04.03 | 1728 Fernando Patelli
// 18.08.05 | 1776 Alexandre Alves da Silva Importado para KPI
// --------------------------------------------------------------------------------------
#include "KPIDefs.ch"
#include "KPIInter.ch"
//-------------------------------------------------------------------------------------
/*/{Protheus.doc} cKPILanguage
Retorna a tradu��o do ambiente atual

@author     0000 - BI Team
@version    P11
@since      08.04.03
/*/
//-------------------------------------------------------------------------------------
function cKPILanguage()
	local cReturn
	Local cLang		:= FWRetIdiom()

	if cLang == "es"
		cReturn := "SPANISH"
	else
		if cLang == "en"
			cReturn := "ENGLISH"
		else
			cReturn := "PORTUGUESE"
		endif
	endif
return cReturn

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} cKPIInternational
Gera arquivos de internacionaliza��o para o client

@author     0000 - BI Team
@version    P11
@since      08.04.03
/*/
//-------------------------------------------------------------------------------------
function cKPIInternational()
	local cTexto := ""
	Local cTextScor	:= alltrim( getJobProfString("ScoreCardName", "ScoreCard") )	

cTexto += 'BIRequest_00001='+STR0001+CRLF/*//'N\u00E3o \u00E9 permitido utilizar um parametro com o nome COMANDO na requisi\u00E7\u00E3o para o servidor.'*/

cTexto += 'JBILayeredPane_00001='+STR0132+CRLF/*//'Estrat\u00E9gia:'*/

cTexto += 'JBIListPanel_00001='+STR0111+CRLF/*//'Novo'*/
cTexto += 'JBIListPanel_00002='+STR0112+CRLF/*//'Visualizar'*/
cTexto += 'JBIListPanel_00003='+STR0128+CRLF/*//'Atualizar'*/
cTexto += 'JBIListPanel_00004='+STR0779+CRLF/*//'Digite sua pesquisa'*/

cTexto += 'JBISelectionDialog_00001='+STR0002+CRLF/*//'Escolhidos:'*/
cTexto += 'JBISelectionDialog_00002='+STR0116+CRLF/*//'Cancelar'*/
cTexto += 'JBISelectionDialog_00003='+STR0038+CRLF/*//'Dispon\u00edveis:'*/

cTexto += 'JBISelectionPanel_00001='+STR0003+CRLF/*//'Remover'*/
cTexto += 'JBISelectionPanel_00002='+STR0004+CRLF/*//'Adicionar'*/
cTexto += 'JBISelectionPanel_00003='+STR0138+CRLF/*//'Usu�rios'*/

cTexto += 'JBIXMLTable_00001='+STR0005+CRLF/*//'Dados'*/
cTexto += 'JBIXMLTable_00002='+STR0006+CRLF/*//'Carregando...'*/

cTexto += 'KpiFormController_00001='+STR0007+CRLF/*//'N\u00E3o existe um formul\u00E1rio do tipo\ '*/
cTexto += 'KpiFormController_00002='+STR0008+CRLF/*//'Erro ao tentar selecionar um formul\u00E1rio do tipo\ '*/
cTexto += 'KpiFormController_00003='+STR0007+CRLF/*//'N\u00E3o existe um formul\u00E1rio do tipo\ '*/
cTexto += 'KpiFormController_00004='+STR0008+CRLF/*//'Erro ao tentar selecionar um formul\u00E1rio do tipo\ '*/
cTexto += 'KpiFormController_00005='+STR0008+CRLF/*//'Erro ao tentar selecionar um formul\u00E1rio do tipo\ '*/
cTexto += 'KpiFormController_00006='+STR0487+CRLF/*//'N�o foi poss�vel criar o formul�rio do tipo: '*/
cTexto += 'KpiFormController_00007='+STR0488+CRLF/*//'Erro na maximiza��o da tela'*/

cTexto += 'BIHttpClient_00001='+STR0009+CRLF/*//'Erro na conex\u00E3o. Mensagem:\ '*/

cTexto += 'KpiApplet_00001='+STR0014+CRLF/*//'Erro configurando LookAndFeel.'*/

cTexto += 'KpiBaseFrame_00001='+STR0117+CRLF/*//'Gravar'*/
cTexto += 'KpiBaseFrame_00002='+STR0116+CRLF/*//'Cancelar'*/
cTexto += 'KpiBaseFrame_00003='+STR0113+CRLF/*//'Editar'*/
cTexto += 'KpiBaseFrame_00004='+STR0114+CRLF/*//'Excluir'*/
cTexto += 'KpiBaseFrame_00005='+STR0128+CRLF/*//'Atualizar'*/
cTexto += 'KpiBaseFrame_00006='+STR0118+CRLF/*//'Nome:'*/ 
cTexto += 'KpiBaseFrame_00007='+STR0800+CRLF/*//'Transparente'*/ 

cTexto += 'KpiDefaultFrameBehavior_00001='+STR0015+CRLF/*//'Erro ao fechar o formul\u00E1rio:\ '*/
cTexto += 'KpiDefaultFrameBehavior_00002='+STR0015+CRLF/*//'Erro ao fechar o formul\u00E1rio:\ '*/
cTexto += 'KpiDefaultFrameBehavior_00003='+STR0016+CRLF/*//'Erro desconhecido ao fechar o formul\u00E1rio.'*/
cTexto += 'KpiDefaultFrameBehavior_00004='+STR0015+CRLF/*//'Erro ao fechar o formul\u00E1rio:\ '*/
cTexto += 'KpiDefaultFrameBehavior_00005='+STR0017+CRLF/*//'Erro ao tentar obter a estrutura do tipo\ '*/
cTexto += 'KpiDefaultFrameBehavior_00006='+STR0474+CRLF/*//'Selecione'*/


cTexto += 'KpiLoginPanel_00001='+STR0018+CRLF/*//'Erro carregando imagens!'*/
cTexto += 'KpiLoginPanel_00002='+STR0138+CRLF/*//'Usu\u00e1rio:'*/
cTexto += 'KpiLoginPanel_00003='+STR0088+CRLF/*//'Senha:'*/
cTexto += 'KpiLoginPanel_00004='+STR0019+CRLF/*//'resposta:'*/
cTexto += 'KpiLoginPanel_00005='+STR0831+CRLF/*//'Acesso negado!\ '*/
cTexto += 'KpiLoginPanel_00006='+STR0011+CRLF/*//'Erro'*/
cTexto += 'KpiLoginPanel_00007='+STR0825+CRLF/*//' "Seja bem-vindo"'*/
cTexto += 'KpiLoginPanel_00008='+STR0826+CRLF/*//' "Digite seu usu�rio e senha para efetuar login."'*/
cTexto += 'KpiLoginPanel_00009='+STR0827+CRLF/*//' "Usu�rio:"'*/
cTexto += 'KpiLoginPanel_00010='+STR0828+CRLF/*//' "Senha:"'*/
cTexto += 'KpiLoginPanel_00011='+STR0829+CRLF/*//' "Enviar"'*/
cTexto += 'KpiLoginPanel_00012='+STR0830+CRLF/*//' "Limpar"'*/ 
cTexto += 'KpiLoginPanel_00013='+STR0832+CRLF/*//' "Esqueci minha senha"'*/ 

cTexto += 'KpiMainPanel_00001='+STR0048+CRLF/*//'Erro!'*/
cTexto += 'KpiMainPanel_00002='+STR0006+CRLF/*//'Carregando...'*/
cTexto += 'KpiMainPanel_00003='+STR0048+CRLF/*//'Erro!'*/
cTexto += 'KpiMainPanel_00004='+STR0013+CRLF/*//'Cadastros'*/
cTexto += 'KpiMainPanel_00005='+STR0138+CRLF/*//'Usu\u00e1rios'*/
cTexto += 'KpiMainPanel_00006='+STR0049+CRLF/*//'O tempo ocioso de conex�o\ '*/
cTexto += 'KpiMainPanel_00007='+STR0027+CRLF/*//'Conectando ao servidor...'*/
cTexto += 'KpiMainPanel_00008='+STR0115+CRLF/*//'Ajuda'*/
cTexto += 'KpiMainPanel_00009='+STR0023+CRLF/*//'Voc\u00EA deseja realmente sair do sistema?'*/
cTexto += 'KpiMainPanel_00010='+STR0026+CRLF/*//'Conex�o ociosa.'*/
cTexto += 'KpiMainPanel_00011='+STR0036+CRLF/*//'Sobre'*/
cTexto += 'KpiMainPanel_00012='+STR0093+CRLF/*//'Janelas'*/
cTexto += 'KpiMainPanel_00013='+STR0014+CRLF/*//'Erro configurando LookAndFeel.'*/
cTexto += 'KpiMainPanel_00014='+STR0010+CRLF/*//'Consultas'*/
cTexto += 'KpiMainPanel_00015='+STR0422+CRLF/*//'Ferramentas'*/
cTexto += 'KpiMainPanel_00016='+STR0083+CRLF/*//'Exibir'*/
cTexto += 'KpiMainPanel_00017='+cTextScor+CRLF
cTexto += 'KpiMainPanel_00018='+STR0141+CRLF/*//'Grupo de Indicadores*/
cTexto += 'KpiMainPanel_00019='+STR0135+CRLF/*//'Indicadores'*/
cTexto += 'KpiMainPanel_00020='+STR0180+CRLF/*//'Projetos'*/
cTexto += 'KpiMainPanel_00021='+STR0193+CRLF/*//'Meta F�rmula*/
cTexto += 'KpiMainPanel_00022='+STR0161+CRLF/*//'A��o'*/
cTexto += 'KpiMainPanel_00023='+STR0031+CRLF/*//'Scorecarding'*/
cTexto += 'KpiMainPanel_00024='+STR0032+CRLF/*//'Pain�is'*/
cTexto += 'KpiMainPanel_00025='+STR0230+CRLF/*//'Lembrete'*/
cTexto += 'KpiMainPanel_00026='+STR0025+CRLF/*//'Em janelas'*/
cTexto += 'KpiMainPanel_00027='+STR0028+CRLF/*//'Em pastas'*/
cTexto += 'KpiMainPanel_00028='+STR0034+CRLF/*//'Conte�do'*/
cTexto += 'KpiMainPanel_00029='+STR0082+CRLF/*//'Pol�tica'*/
cTexto += 'KpiMainPanel_00030='+STR0344+CRLF/*//'Relatorio'*/
cTexto += 'KpiMainPanel_00031='+STR0345+CRLF/*//'Plano de ac�oes'*/
cTexto += 'KpiMainPanel_00032='+STR0421+CRLF/*//'Unidades de Medida'*/
cTexto += 'KpiMainPanel_00033='+STR0420+CRLF/*//'Scorecards e Indicadores'*/
cTexto += 'KpiMainPanel_00034='+STR0453+CRLF/*//'Status dos Planos de A��es'*/
cTexto += 'KpiMainPanel_00035='+STR0555+CRLF/*//'Grupo de A��es'*/
cTexto += 'KpiMainPanel_00036='+STR0575+CRLF/*//'Pain�is Comparativos'*/    
cTexto += 'KpiMainPanel_00037='+STR0676+CRLF/*//'Clique para alterar a imagem'*/
cTexto += 'KpiMainPanel_00038='+STR0744+CRLF/*//'Existem manuten��es sendo efetuadas no momento'*/
cTexto += 'KpiMainPanel_00039='+STR0745+CRLF/*//'Indicadores tiveram seus valores atualizados e o c�lculo n�o foi processado'*/
cTexto += 'KpiMainPanel_00040='+STR0746+CRLF/*//'N�o existem manuten��es sendo efetuadas no momento'*/
cTexto += 'KpiMainPanel_00041='+STR0904+CRLF/*//'Cadastro de Estruturas'*/
cTexto += 'KpiMainPanel_00042='+STR0926+CRLF/*//'Sair'*/

cTexto += 'KpiServerSubstitute_00001='+STR0039+CRLF/*//'XML Enviado:'*/
cTexto += 'KpiServerSubstitute_00002='+STR0040+CRLF/*//'XML Recebido:'*/

cTexto += 'KpiDefaultDialogSystem_00001='+STR0011+CRLF/*//'Erro'*/
cTexto += 'KpiDefaultDialogSystem_00002='+STR0058+CRLF/*//'associados a este elemento. N\u00E3o pode ser exclu\u00EDdo.'*/
cTexto += 'KpiDefaultDialogSystem_00003='+STR0057+CRLF/*//'alterado por outro usu\u00E1rio. Tente novamente mais tarde.'*/
cTexto += 'KpiDefaultDialogSystem_00004='+STR0056+CRLF/*//'Voc\u00EA n\u00E3o est\u00E1 autorizado a\ '*/
cTexto += 'KpiDefaultDialogSystem_00005='+STR0055+CRLF/*//'\ Aten\u00E7\u00E3o: todos os registros filhos tamb\u00E9m ser\u00E3o excluidos.'*/
cTexto += 'KpiDefaultDialogSystem_00006='+STR0054+CRLF/*//'Este elemento n\u00E3o est\u00E1\ '*/
cTexto += 'KpiDefaultDialogSystem_00007='+STR0053+CRLF/*//'Erro de protocolo: NOCMD.'*/
cTexto += 'KpiDefaultDialogSystem_00008='+STR0052+CRLF/*//'Erro de protocolo:\ '*/
cTexto += 'KpiDefaultDialogSystem_00009='+STR0051+CRLF/*//'com o servidor expirou. Por favor realize novamente a conex\u00E3o.'*/
cTexto += 'KpiDefaultDialogSystem_00010='+STR0050+CRLF/*//'presente no servidor. Tente atualizar os dados.'*/
cTexto += 'KpiDefaultDialogSystem_00011='+STR0049+CRLF/*//'O tempo ocioso de conex\u00E3o\ '*/
cTexto += 'KpiDefaultDialogSystem_00012='+STR0048+CRLF/*//'opera\u00E7\u00E3o ao servidor. Por favor, espere a sua conclus\u00E3o.'*/
cTexto += 'KpiDefaultDialogSystem_00013='+STR0047+CRLF/*//'Existem outros objetos\ '*/
cTexto += 'KpiDefaultDialogSystem_00014='+STR0046+CRLF/*//'\ desconhecido.'*/
cTexto += 'KpiDefaultDialogSystem_00015='+STR0045+CRLF/*//'Este registro est\u00E1 sendo\ '*/
cTexto += 'KpiDefaultDialogSystem_00016='+STR0044+CRLF/*//'realizar esta opera\u00E7\u00E3o.'*/
cTexto += 'KpiDefaultDialogSystem_00017='+STR0043+CRLF/*//'Erro n\u00BA\ '*/
cTexto += 'KpiDefaultDialogSystem_00018='+STR0042+CRLF/*//'Erro de protocolo: BADXML.'*/
cTexto += 'KpiDefaultDialogSystem_00019='+STR0012+CRLF/*//'Confirma\u00E7\u00E3o'*/
cTexto += 'KpiDefaultDialogSystem_00020='+STR0041+CRLF/*//'Voc\u00EA j\u00E1 requisitou uma\ '*/
cTexto += 'KpiDefaultDialogSystem_00021='+STR0078+CRLF/*//'Voc\u00EA deseja realmente excluir este registro?'*/
cTexto += 'KpiDefaultDialogSystem_00022='+STR0094+CRLF/*//'Informacao'*/
cTexto += 'KpiDefaultDialogSystem_00023='+STR0095+CRLF/*//'Aviso'*/
cTexto += 'KpiDefaultDialogSystem_00024='+STR0080+CRLF/*//'Sim'*/
cTexto += 'KpiDefaultDialogSystem_00025='+STR0081+CRLF/*//'N�o'*/
cTexto += 'KpiDefaultDialogSystem_00026='+STR0739+CRLF/*//'Sess�o expirada. Efetue novamente o login.'*/

cTexto += 'BIXMLGeneralData_00001='+STR0069+CRLF/*//'\ o valor \"'*/
cTexto += 'BIXMLGeneralData_00002='+STR0065+CRLF/*//'\" n\u00E3o existe.'*/
cTexto += 'BIXMLGeneralData_00003='+STR0066+CRLF/*//'Chave \"'*/
cTexto += 'BIXMLGeneralData_00004='+STR0067+CRLF/*//'\" do campo \"'*/
cTexto += 'BIXMLGeneralData_00005='+STR0068+CRLF/*//'N\u00E3o foi poss\u00EDvel converter'*/
cTexto += 'BIXMLGeneralData_00006='+STR0070+CRLF/*//'\" para um valor no formato float.'*/
cTexto += 'BIXMLGeneralData_00007='+STR0064+CRLF/*//'\" para um valor no formato boolean.'*/
cTexto += 'BIXMLGeneralData_00008='+STR0063+CRLF/*//'\" para um valor no formato int.'*/
cTexto += 'BIXMLGeneralData_00009='+STR0062+CRLF/*//'\" para um valor no formato GregorianCalendar.'*/
cTexto += 'BIXMLGeneralData_00010='+STR0061+CRLF/*//'A chave \"'*/
cTexto += 'BIXMLGeneralData_00011='+STR0059+CRLF/*//'\" para um valor no formato double.'*/
cTexto += 'BIXMLGeneralData_00012='+STR0060+CRLF/*//'\" para um valor no formato long.'*/

cTexto += 'BIXMLRecord_00001='+STR0065+CRLF/*//'\" n\u00E3o existe.'*/
cTexto += 'BIXMLRecord_00002='+STR0066+CRLF/*//'Chave \"'*/

cTexto += 'BIXMLVector_00001='+STR0077+CRLF/*//'Erro de I/O no XML.'*/
cTexto += 'BIXMLVector_00002='+STR0076+CRLF/*//'Erro no processamento dos dados recebidos'*/
cTexto += 'BIXMLVector_00003='+STR0075+CRLF/*//'\ do servidor.'*/
cTexto += 'BIXMLVector_00004='+STR0074+CRLF/*//'est\u00E3o corrompidos.\ '*/
cTexto += 'BIXMLVector_00005='+STR0073+CRLF/*//'Dados recebidos do servidor\ '*/
cTexto += 'BIXMLVector_00006='+STR0072+CRLF/*//'Cadeia com XML \u00E9 vazia.'*/
cTexto += 'BIXMLVector_00007='+STR0071+CRLF/*//'Cadeia com XML \u00E9 nula.'*/

cTexto += 'KpiAjuda_00001='+STR0115+CRLF/*//'Ajuda'*/

//Kpi FileChooser
cTexto += 'KpiFileChooser_00001='+STR0096+CRLF/*//'O arquivo ''*/		
cTexto += 'KpiFileChooser_00002='+STR0097+CRLF/*//' ja existe.\nDeseja substituir o arquivo existente? '*/		
cTexto += 'KpiFileChooser_00003='+STR0098+CRLF/*//' ja existe. '*/		
cTexto += 'KpiFileChooser_00004='+STR0099+CRLF/*//'Escolha outro nome.'*/		
cTexto += 'KpiFileChooser_00005='+STR0100+CRLF/*//'N�o foi encontrado. \n '*/		
cTexto += 'KpiFileChooser_00006='+STR0101+CRLF/*//'Verifique o nome do arquivo.'*/		
cTexto += 'KpiFileChooser_00007='+STR0102+CRLF/*//'KPI - Gravar arquivo...'*/		
cTexto += 'KpiFileChooser_00008='+STR0103+CRLF/*//'KPI - Abrir arquivo...'*/		
cTexto += 'KpiFileChooser_00009='+STR0104+CRLF/*//'Arquivo'*/		
cTexto += 'KpiFileChooser_00010='+STR0105+CRLF/*//'Tamanho'*/		
cTexto += 'KpiFileChooser_00011='+STR0106+CRLF/*//'Data'*/		
cTexto += 'KpiFileChooser_00012='+STR0117+CRLF/*//'Gravar'*/		
cTexto += 'KpiFileChooser_00013='+STR0139+CRLF/*//'Abrir'*/		
cTexto += 'KpiFileChooser_00014='+STR0107+CRLF/*// 'Local'*/
cTexto += 'KpiFileChooser_00015='+STR0108+CRLF/*// 'Nome do arquivo'*/
cTexto += 'KpiFileChooser_00016='+STR0109+CRLF/*// 'Tipo do arquivo'*/
cTexto += 'KpiFileChooser_00017='+STR0116+CRLF/*// 'Cancelar'*/
cTexto += 'KpiFileChooser_00018='+STR0110+CRLF/*// 'Lista de arquivos.'*/

//Grupo de pessoas
cTexto += 'KpiGrupoPessoaFrame_00001='+STR0089+CRLF/*//'Grupo de Pessoas'*/
cTexto += 'KpiGrupoPessoaFrame_00002='+STR0090+CRLF/*//'Grupo'*/
cTexto += 'KpiGrupoPessoaFrame_00003='+STR0124+CRLF/*//'Pessoas'*/
cTexto += 'KpiGrupoPessoaFrame_00004='+STR0118+CRLF/*//'Nome:'*/
cTexto += 'KpiGrupoPessoaFrame_00005='+STR0131+CRLF/*//'Descri��o:'*/
cTexto += 'KpiGrupoPessoaFrame_00006='+STR0247+CRLF/*//'Cadastro de Grupos'*/
cTexto += 'KpiGrupoPessoaFrame_00007='+STR0248+CRLF/*//'Grupo ativo'*/
cTexto += 'KpiGrupoPessoaFrame_00008='+STR0249+CRLF/*//'Seguran�a'*/
cTexto += 'KpiGrupoPessoaFrame_00009='+STR0090+CRLF/*//'Grupo'*/
cTexto += 'KpiGrupoPessoaFrame_00010='+STR0118+CRLF/*//'Nome:'*/
cTexto += 'KpiGrupoPessoaFrame_00011='+STR0246+CRLF/*//'Permissao'*/
cTexto += 'KpiGrupoPessoaFrame_00012='+STR0138+CRLF/*//'Usu�rios'*/
cTexto += 'KpiGrupoPessoaFrame_00013='+STR0242+CRLF/*//'Manuten��o'*/
cTexto += 'KpiGrupoPessoaFrame_00014='+STR0243+CRLF/*//'Visualiza��o'*/
cTexto += 'KpiGrupoPessoaFrame_00015='+STR0245+CRLF/*//'Nome n�o informado!'*/
cTexto += 'KpiGrupoPessoaFrame_00016='+STR0349+CRLF/*//'Descri��o n�o informada!'*/

cTexto += 'JBIMultiSelectionDialog_00001='+STR0120+CRLF/*//'Organiza��o:'*/
cTexto += 'JBIMultiSelectionDialog_00002='+STR0091+CRLF/*//'Grupos:'*/
cTexto += 'JBIMultiSelectionDialog_00003='+STR0092+CRLF/*//'Pessoas:'*/
cTexto += 'JBIMultiSelectionDialog_00004='+STR0116+CRLF/*//'Cancelar'*/
cTexto += 'JBIMultiSelectionDialog_00005='+STR0093+CRLF/*//'Adiciona'*/

//SeekList Panel
cTexto += 'JBISeekListPanel_00001='+STR0140+CRLF/*//'Procurar*/

//Grupo de Indicadores
cTexto += 'KpiListaGrupoIndicador_00001='+STR0141+CRLF/*//'Grupo de Indicadores*/

//Indicadores
cTexto += 'KpiGrupoIndicador_00001='+STR0141+CRLF/*//'Grupo de Indicadores*/
cTexto += 'KpiGrupoIndicador_00002='+STR0131+CRLF/*//'Descri��o*/
cTexto += 'KpiGrupoIndicador_00003='+STR0245+CRLF/*//'Nome n�o informado!*/    
cTexto += 'KpiGrupoIndicador_00004='+STR0135+CRLF/*//'Indicadores*/    


//Usuarios
cTexto += 'KpiUsuarioFrame_00001='+STR0142+CRLF/*//'Usu�rio'*/
cTexto += 'KpiUsuarioFrame_00002='+STR0143+CRLF/*//'Alterar Senha'*/
cTexto += 'KpiUsuarioFrame_00003='+STR0144+CRLF/*//'Administrador'*/
cTexto += 'KpiUsuarioFrame_00004='+STR0118+CRLF/*//'Nome:'*/
cTexto += 'KpiUsuarioFrame_00005='+STR0145+CRLF/*//'Cargo:'*/
cTexto += 'KpiUsuarioFrame_00006='+STR0146+CRLF/*//'Telefone:'*/
cTexto += 'KpiUsuarioFrame_00007='+STR0147+CRLF/*//'Ramal:'*/
cTexto += 'KpiUsuarioFrame_00008='+STR0148+CRLF/*//'E-mail:'*/
cTexto += 'KpiUsuarioFrame_00009='+STR0149+CRLF/*//'Seguran\u00e7a'*/
cTexto += 'KpiUsuarioFrame_00010='+STR0150+CRLF/*//'Usu\u00E1rio:'*/
cTexto += 'KpiUsuarioFrame_00011='+STR0151+CRLF/*//'Senha:'*/
cTexto += 'KpiUsuarioFrame_00012='+STR0152+CRLF/*//'Origem*/
cTexto += 'KpiUsuarioFrame_00013='+STR0153+CRLF/*//'Usuario Protheus*/
cTexto += 'KpiUsuarioFrame_00014='+STR0237+CRLF/*//'Cadastro de Usu�rios'*/
cTexto += 'KpiUsuarioFrame_00015='+STR0238+CRLF/*//'Usu�rio ativo'*/
cTexto += 'KpiUsuarioFrame_00016='+STR0239+CRLF/*//'Permiss�es'*/
cTexto += 'KpiUsuarioFrame_00017='+STR0240+CRLF/*//'Selecione o Scorecard e adicione os usu�rios que est�o autorizados a visualiz�-lo'*/
cTexto += 'KpiUsuarioFrame_00018='+STR0241+CRLF/*//'Selecione o Scorecard:'*/
cTexto += 'KpiUsuarioFrame_00019='+STR0138+CRLF/*//'Usu�rios'*/
cTexto += 'KpiUsuarioFrame_00020='+STR0242+CRLF/*//'Manuten��o' */
cTexto += 'KpiUsuarioFrame_00021='+STR0243+CRLF/*//'Visualiza��o'*/
cTexto += 'KpiUsuarioFrame_00022='+STR0244+CRLF/*//'Selecione um scorecard.'*/
cTexto += 'KpiUsuarioFrame_00023='+STR0245+CRLF/*//'Nome n�o informado!'*/
cTexto += 'KpiUsuarioFrame_00024='+STR0246+CRLF/*//'Permiss�es:'*/
cTexto += 'KpiUsuarioFrame_00025='+STR0129+CRLF/*//'Configura��o'*/
cTexto += 'KpiUsuarioFrame_00026='+STR0085+CRLF/*//'Personaliza��o'*/
cTexto += 'KpiUsuarioFrame_00027='+STR0085+CRLF/*//'Tipo de vizualiza��o:'*/
cTexto += 'KpiUsuarioFrame_00028='+STR0137+CRLF/*//'Janela'*/
cTexto += 'KpiUsuarioFrame_00029='+STR0121+CRLF/*//'Pasta'*/
cTexto += 'KpiUsuarioFrame_00030='+STR0127+CRLF/*//'�rea de travalho'*/
cTexto += 'KpiUsuarioFrame_00031='+STR0422+CRLF/*//'Ferramentas'*/
cTexto += 'KpiUsuarioFrame_00032='+STR0346+CRLF/*//'Mostrar scorecarding na inicializa��o?'*/
cTexto += 'KpiUsuarioFrame_00033='+STR0360+CRLF/*//'Usu�rio n�o informado!'*/
cTexto += 'KpiUsuarioFrame_00034='+STR0560+CRLF/*//'Utilizar como padr�o para data alvo o m�s anterior.'*/
cTexto += 'KpiUsuarioFrame_00035='+STR0732+CRLF/*//'Ativar atualiza��o autom�tica ao abrir o scorecarding.'*/
cTexto += 'KpiUsuarioFrame_00036='+STR0733+CRLF/*//'Ocultar �rvore de departamentos ao abrir o scorecarding.'*/
cTexto += 'KpiUsuarioFrame_00037='+STR0734+CRLF/*//'Ao abrir a tela do scorecarging definir como padr�o:'*/
cTexto += 'KpiUsuarioFrame_00038='+STR0178+CRLF/*//'Scorecarding:'*/
cTexto += 'KpiUsuarioFrame_00039='+STR0735+CRLF/*//'Prefer�ncias'*/
cTexto += 'KpiUsuarioFrame_00040='+STR0780+CRLF/*//'Permiss�o de acesso'*/
cTexto += 'KpiUsuarioFrame_00041='+STR1001+CRLF/*//"O Que o usu�rio deve visualizar ao inicializar o sistema"*/

//Grupos
cTexto += 'KpiUsuariosFrame_00001='+STR0154+CRLF/*//'Grupos'*/
cTexto += 'KpiUsuariosFrame_00002='+STR0155+CRLF/*//'Total de Grupos:'*/
cTexto += 'KpiUsuariosFrame_00003='+STR0156+CRLF/*//'Total de Usu\u00e1rios:'*/
cTexto += 'KpiUsuariosFrame_00004='+STR0157+CRLF/*//'Usu\u00e1rios'*/
cTexto += 'KpiUsuariosFrame_00005='+STR0158+CRLF/*//'Diret\u00f3rio de Usu\u00e1rios'*/


//Scorecard
cTexto += 'KpiScorecard_00001='+cTextScor+CRLF
cTexto += 'KpiScorecard_00002='+cTextScor+CRLF
cTexto += 'KpiScorecard_00003='+STR0118+CRLF/*//'Nome:'*/
cTexto += 'KpiScorecard_00004='+STR0131+CRLF/*//'Descri��o:'*/
cTexto += 'KpiScorecard_00005='+STR0125+CRLF/*//'Respons�vel:'*/  
cTexto += 'KpiScorecard_00006='+STR0245+CRLF/*//'Nome n�o informado!'*/
cTexto += 'KpiScorecard_00007='+STR0265+CRLF/*//'O Nome n�o pode conter o caracter "." (ponto)'*/
cTexto += 'KpiScorecard_00008='+STR0348+CRLF/*//'Respons�vel n�o informado!'*/
cTexto += 'KpiScorecard_00009='+STR0349+CRLF/*//'Descri��o n�o informada!'*/
cTexto += 'KpiScorecard_00010='+STR0524+CRLF/*//'A Descri��o n�o pode conter o caracter "&" '*/
cTexto += 'KpiScorecard_00011='+STR0578+CRLF/*//'Pai:'*/ 
cTexto += 'KpiScorecard_00012='+STR0799+CRLF/*//'Inspetor de f�rmula'*/ 
cTexto += 'KpiScorecard_00013='+STR0815+CRLF/*//'Enviar E-mail'*/ 

//Lista de Planos
cTexto += 'KpiListaPlanos_00001='+STR0558+CRLF/*//'Filtrar'*/
cTexto += 'KpiListaPlanos_00002='+STR0557+CRLF/*//'Filtrar por Plano de A��o'*/

//Plano de Acao
cTexto += 'KpiPlanoDeAcao_00001='+STR0161+CRLF/*//'A��o'*/
cTexto += 'KpiPlanoDeAcao_00002='+STR0118+CRLF/*//'Nome:'*/
cTexto += 'KpiPlanoDeAcao_00003='+STR0131+CRLF/*//'Descri��o:'*/
cTexto += 'KpiPlanoDeAcao_00004='+STR0125+CRLF/*//'Respons�vel:'*/
cTexto += 'KpiPlanoDeAcao_00005='+STR0119+CRLF/*//'Objetivo:'*/
cTexto += 'KpiPlanoDeAcao_00006='+STR0163+CRLF/*//'Como:'*/
cTexto += 'KpiPlanoDeAcao_00007='+STR0164+CRLF/*//'Investimento:'*/
cTexto += 'KpiPlanoDeAcao_00008='+STR0165+CRLF/*//'Causa:'*/
cTexto += 'KpiPlanoDeAcao_00009='+STR0166+CRLF/*//'Resultado:'*/
cTexto += 'KpiPlanoDeAcao_00010='+STR0167+CRLF/*//'Observa��o do Status:'*/
cTexto += 'KpiPlanoDeAcao_00011='+STR0168+CRLF/*//'Data In�cio:'*/
cTexto += 'KpiPlanoDeAcao_00012='+STR0169+CRLF/*//'Data Fim:'*/
cTexto += 'KpiPlanoDeAcao_00013='+STR0170+CRLF/*//'Finalizada em:'*/
cTexto += 'KpiPlanoDeAcao_00014='+STR0171+CRLF/*//'Status:'*/
cTexto += 'KpiPlanoDeAcao_00015='+STR0172+CRLF/*//'% Realizado:'*/
cTexto += 'KpiPlanoDeAcao_00016='+STR0173+CRLF/*//'Investimento:'*/
cTexto += 'KpiPlanoDeAcao_00017='+STR0174+CRLF/*//'Planos de A��es'*/
cTexto += 'KpiPlanoDeAcao_00018='+STR0178+CRLF/*//'Scorecard:'*/
cTexto += 'KpiPlanoDeAcao_00019='+STR0134+CRLF/*//'Indicador:'*/
cTexto += 'KpiPlanoDeAcao_00020='+STR0175+CRLF/*//'Tipo de A��o:'*/
cTexto += 'KpiPlanoDeAcao_00021='+STR0176+CRLF/*//'por Indicador'*/
cTexto += 'KpiPlanoDeAcao_00022='+STR0177+CRLF/*//'por Projeto'*/
cTexto += 'KpiPlanoDeAcao_00023='+STR0181+CRLF/*//'Projeto:'*/
cTexto += 'KpiPlanoDeAcao_00024='+STR0224+CRLF/*//'Data final deve ser maior que data inicial.'*/
cTexto += 'KpiPlanoDeAcao_00025='+STR0033+CRLF/*//'Descri��o'*/
cTexto += 'KpiPlanoDeAcao_00026='+STR0035+CRLF/*//'Como'*/
cTexto += 'KpiPlanoDeAcao_00027='+STR0037+CRLF/*//'Propriet�rio'*/
cTexto += 'KpiPlanoDeAcao_00028='+STR0079+CRLF/*//'Data t�rmino'*/
cTexto += 'KpiPlanoDeAcao_00029='+STR0084+CRLF/*//'Observa��o'*/
cTexto += 'KpiPlanoDeAcao_00030='+STR0245+CRLF/*//'Nome n�o informado!'*/
cTexto += 'KpiPlanoDeAcao_00031='+STR0197+CRLF/*//'Scorecard n�o informado!'*/
cTexto += 'KpiPlanoDeAcao_00032='+STR0351+CRLF/*//'Indicador n�o informado!'*/
cTexto += 'KpiPlanoDeAcao_00033='+STR0353+CRLF/*//'Data de in�cio n�o informada!'*/
cTexto += 'KpiPlanoDeAcao_00034='+STR0354+CRLF/*//'Data fim n�o informada!'*/
cTexto += 'KpiPlanoDeAcao_00035='+STR0355+CRLF/*//'Causa n�o informada!'*/
cTexto += 'KpiPlanoDeAcao_00036='+STR0349+CRLF/*//'Descri��o n�o informada!'*/
cTexto += 'KpiPlanoDeAcao_00037='+STR0356+CRLF/*//'Objetivo n�o informado!'*/
cTexto += 'KpiPlanoDeAcao_00038='+STR0357+CRLF/*//'Campo Como n�o informado!'*/
cTexto += 'KpiPlanoDeAcao_00039='+STR0358+CRLF/*//'Respons�vel n�o informado!'*/
cTexto += 'KpiPlanoDeAcao_00040='+STR0475+CRLF/*//'Criador:'*/
cTexto += 'KpiPlanoDeAcao_00041='+STR0489+CRLF/*//'A data final foi alterada, o respons�vel pelo scorecard ser� notificado!'*/
cTexto += 'KpiPlanoDeAcao_00042='+STR0490+CRLF/*//'Justificativa do Cancelamento'*/
cTexto += 'KpiPlanoDeAcao_00043='+STR0491+CRLF/*//'Preencher a justificativa do cancelamento!'*/
cTexto += 'KpiPlanoDeAcao_00044='+STR0492+CRLF/*//'Data Cadastro:'*/
cTexto += 'KpiPlanoDeAcao_00045='+STR0493+CRLF/*//'MOTIVO DO CANCELAMENTO:'*/   
cTexto += 'KpiPlanoDeAcao_00046='+STR0111+CRLF/*//'Novo'*/   
cTexto += 'KpiPlanoDeAcao_00047='+STR0114+CRLF/*//'Excluir'*/   
cTexto += 'KpiPlanoDeAcao_00048='+STR0549+CRLF/*//'Download'*/   
cTexto += 'KpiPlanoDeAcao_00049='+STR0550+CRLF/*//'Upload'*/   
cTexto += 'KpiPlanoDeAcao_00050='+STR0551+CRLF/*//'Documentos'*/   
cTexto += 'KpiPlanoDeAcao_00051='+STR0397+CRLF/*//'Plano de A��o:'*/
cTexto += 'KpiPlanoDeAcao_00052='+STR0753+CRLF/*//'Plano de A��o'*/
cTexto += 'KpiPlanoDeAcao_00053='+STR0754+CRLF/*//'Limite de caracteres excedido.'*/
cTexto += 'KpiPlanoDeAcao_00054='+STR0755+CRLF/*//'Caracteres'*/
cTexto += 'KpiPlanoDeAcao_00055='+STR0756+CRLF/*//'de'*/
cTexto += 'KpiPlanoDeAcao_00056='+STR0781+CRLF/*//'Efeito:'*/
cTexto += 'KpiPlanoDeAcao_00057='+STR0782+CRLF/*//'Descri��o do Plano de A��o:'*/ 
cTexto += 'KpiPlanoDeAcao_00058='+STR0783+CRLF/*//'Descri��o da Causa:'*/ 
cTexto += 'KpiPlanoDeAcao_00059='+STR0818+CRLF/*//'Log da A��o'*/ 
cTexto += 'KpiPlanoDeAcao_00060='+STR0819+CRLF/*//'"Reiniciar A��o"'*/ 
cTexto += 'KpiPlanoDeAcao_00061='+STR0820+CRLF/*//'"Confirma o reinicio da a��o "'*/ 
cTexto += 'KpiPlanoDeAcao_00062='+STR0821+CRLF/*//'" ? Esta opera��o sera gravada no log de A��es."'*/ 
cTexto += 'KpiPlanoDeAcao_00063='+STR0822+CRLF/*//'"Reiniciar A��o"'*/ 
cTexto += 'KpiPlanoDeAcao_00064='+STR0823+CRLF/*//'"Sim"'*/ 
cTexto += 'KpiPlanoDeAcao_00065='+STR0824+CRLF/*//'"N�o"'*/ 
                                                               

//Lista de Projetos
cTexto += 'KpiListaProjeto_00001='+STR0558+CRLF/*//'Filtrar'*/
cTexto += 'KpiListaProjeto_00002='+STR0559+CRLF/*//'Filtrar por Departamento'*/
cTexto += 'KpiListaProjeto_00003='+STR0668+CRLF/*//'Total de a��es'*/

//Projetos
cTexto += 'KpiProjeto_00001='+STR0179+CRLF/*//'Projeto'*/
cTexto += 'KpiProjeto_00002='+STR0118+CRLF/*//'Nome:'*/
cTexto += 'KpiProjeto_00003='+STR0131+CRLF/*//'Descri��o:'*/
cTexto += 'KpiProjeto_00004='+STR0178+CRLF/*//'Scorecard:'*/
cTexto += 'KpiProjeto_00005='+STR0180+CRLF/*//'Projetos'*/
cTexto += 'KpiProjeto_00006='+STR0030+CRLF/*//'Permiss�o'*/
cTexto += 'KpiProjeto_00007='+STR0245+CRLF/*//'Nome n�o informado!'*/
cTexto += 'KpiProjeto_00008='+STR0197+CRLF/*//'Scorecard n�o informado!'*/
cTexto += 'KpiProjeto_00009='+STR0125+CRLF/*//'Respons�vel:'*/
cTexto += 'KpiProjeto_00010='+STR0539+CRLF/*//'Tipo:'*/ 
cTexto += 'KpiProjeto_00011='+STR0784+CRLF/*//'C�digo:'*/  
cTexto += 'KpiProjeto_00012='+STR0817+CRLF/*//'A��es de Scorecards'*/ 

//Tabela de Indicadores
cTexto += 'KpiTabIndicador_00001='+STR0180+CRLF/*// 'Projetos'*/        
cTexto += 'KpiTabIndicador_00002='+STR0182+CRLF/*// 'Ano'*/
cTexto += 'KpiTabIndicador_00003='+STR0538+CRLF/*// 'Real'*/
cTexto += 'KpiTabIndicador_00004='+STR0184+CRLF/*// 'Meta'*/
cTexto += 'KpiTabIndicador_00005='+STR0185+CRLF/*// 'Semestre'*/
cTexto += 'KpiTabIndicador_00006='+STR0186+CRLF/*// 'Quadrimestre'*/
cTexto += 'KpiTabIndicador_00007='+STR0187+CRLF/*// 'Trimestre'*/
cTexto += 'KpiTabIndicador_00008='+STR0188+CRLF/*// 'Bimestre'*/
cTexto += 'KpiTabIndicador_00009='+STR0189+CRLF/*// 'M�s'*/
cTexto += 'KpiTabIndicador_00010='+STR0190+CRLF/*// 'Quinzena'*/
cTexto += 'KpiTabIndicador_00011='+STR0191+CRLF/*// 'Semana'*/
cTexto += 'KpiTabIndicador_00012='+STR0192+CRLF/*// 'Dia'*/
cTexto += 'KpiTabIndicador_00013='+STR0459+CRLF/*// 'Estrat�gico'*/	
cTexto += 'KpiTabIndicador_00014='+STR0476+CRLF/*// 'Pr�via'*/
cTexto += 'KpiTabIndicador_00015='+STR0757+CRLF/*// 'Real<br>Acumulado'*/
cTexto += 'KpiTabIndicador_00016='+STR0758+CRLF/*// 'Meta<br>Acumulada'*/

//Lista de Indicadores
cTexto += 'KpiListaIndicador_00001='+STR0135+CRLF/*//'Indicadores'*/
cTexto += 'KpiListaIndicador_00002='+STR0178+CRLF/*//'Scorecard:'*/
cTexto += 'KpiListaIndicador_00003='+STR0134+CRLF/*//'Indicador:'*/
cTexto += 'KpiListaIndicador_00004='+STR0544+CRLF/*//'Ordenar'*/

//Lista de meta formula
cTexto += 'KpiListaMetaFormula_00001='+STR0193+CRLF/*//'Meta Formula*/

//Tela de Indicadores
cTexto += 'KpiIndicador_00001='+ STR0004+CRLF/*// 'Adicionar'*/
cTexto += 'KpiIndicador_00002='+ STR0195+CRLF/*// 'Freq��ncia n�o informada!*/
cTexto += 'KpiIndicador_00003='+ STR0196+CRLF/*// 'Grupo n�o informado!*/
cTexto += 'KpiIndicador_00004='+ STR0197+CRLF/*// 'Scorecard n�o informado!*/
cTexto += 'KpiIndicador_00005='+ STR0198+CRLF/*// 'Cadastro de indicadores*/
cTexto += 'KpiIndicador_00006='+ STR0131+CRLF/*// 'Descri��o:    */   
cTexto += 'KpiIndicador_00007='+ STR0199+CRLF/*// 'Decimais:*/
cTexto += 'KpiIndicador_00008='+ STR0200+CRLF/*// 'Quanto Maior Melhor*/
cTexto += 'KpiIndicador_00009='+ STR0201+CRLF/*// 'Quanto Menor Melhor*/
cTexto += 'KpiIndicador_00010='+ STR0202+CRLF/*// 'Freq��ncia:*/
cTexto += 'KpiIndicador_00011='+ STR0203+CRLF/*// 'Unidade:*/
cTexto += 'KpiIndicador_00012='+ STR0204+CRLF/*// 'C�d. importa��o:*/
cTexto += 'KpiIndicador_00013='+ STR0205+CRLF/*// 'Vis�vel:*/
cTexto += 'KpiIndicador_00014='+ STR0206+CRLF/*// 'Grupo:*/
cTexto += 'KpiIndicador_00015='+ STR0178+CRLF/*// 'Scorecard:*/
cTexto += 'KpiIndicador_00016='+ STR0207+CRLF/*// 'Ind. Pai:*/
cTexto += 'KpiIndicador_00017='+ STR0208+CRLF/*// 'Maior valor*/
cTexto += 'KpiIndicador_00018='+ STR0209+CRLF/*// 'Menor valor*/
cTexto += 'KpiIndicador_00019='+ STR0210+CRLF/*// 'Pela coleta:*/
cTexto += 'KpiIndicador_00020='+ STR0211+CRLF/*// 'Pelo Indicador:*/
cTexto += 'KpiIndicador_00021='+ STR0134+CRLF/*// 'Indicador: */   
cTexto += 'KpiIndicador_00022='+ STR0212+CRLF/*// 'Meta f�rmula:*/
cTexto += 'KpiIndicador_00023='+ STR0213+CRLF/*// 'Verificar*/
cTexto += 'KpiIndicador_00024='+ STR0214+CRLF/*// 'Limpar*/
cTexto += 'KpiIndicador_00025='+ STR0215+CRLF/*// 'Express�o:*/
cTexto += 'KpiIndicador_00026='+ STR0193+CRLF/*// 'Adicionar */   
cTexto += 'KpiIndicador_00027='+ STR0216+CRLF/*// 'F�rmula:*/
cTexto += 'KpiIndicador_00028='+ STR0111+CRLF/*// 'Novo*/
cTexto += 'KpiIndicador_00029='+ STR0114+CRLF/*// 'Excluir*/
cTexto += 'KpiIndicador_00030='+ STR0217+CRLF/*// 'ATEN��O: Se o per�odo do indicador for alterado, a planilha de valores ser� exclu�da.\n Confirma a altera��o?*/
cTexto += 'KpiIndicador_00031='+ STR0218+CRLF/*// 'Alvo / Respons�veis'*/
cTexto += 'KpiIndicador_00032='+ STR0219+CRLF/*// 'F�rmula'*/
cTexto += 'KpiIndicador_00033='+ STR0220+CRLF/*// 'Planilha de valores'*/
cTexto += 'KpiIndicador_00034='+ STR0221+CRLF/*// 'Indicador'*/
cTexto += 'KpiIndicador_00035='+ STR0223+CRLF/*// 'Por favor, verifique os valores digitados para os alvos. A ordem est� errada.'*/
cTexto += 'KpiIndicador_00036='+ STR0266+CRLF/*// 'Toler�ncia'*/   
cTexto += 'KpiIndicador_00037='+ STR0267+CRLF/*// 'da Meta:'*/
cTexto += 'KpiIndicador_00038='+ STR0020+CRLF/*// 'Peso:'*/
cTexto += 'KpiIndicador_00039='+ STR0021+CRLF/*// 'Soma '*/
cTexto += 'KpiIndicador_00040='+ STR0022+CRLF/*// 'M�dia'*/
cTexto += 'KpiIndicador_00041='+ STR0024+CRLF/*// 'Tipo do acumulado:'*/
cTexto += 'KpiIndicador_00042='+ STR0350+CRLF/*// 'Unidade n�o informada!'*/
cTexto += 'KpiIndicador_00043='+ STR0385+CRLF/*// 'Deseja visualizar os outros indicadores deste grupo?'*/
cTexto += 'KpiIndicador_00044='+ STR0013+CRLF/*// 'Cadastros'*/
cTexto += 'KpiIndicador_00045='+ STR0427+CRLF/*// 'A express�o n�o pode conter os caracteres: + - * /'*/
cTexto += 'KpiIndicador_00046='+ STR0431+CRLF/*// '�ltimo valor*/
cTexto += 'KpiIndicador_00047='+ STR0459+CRLF/*// 'Estrategico'*/
cTexto += 'KpiIndicador_00048='+ STR0461+CRLF/*// 'Usando a f�rmula'*/
cTexto += 'KpiIndicador_00049='+ STR0462+CRLF/*// 'Calcular:'*/
cTexto += 'KpiIndicador_00050='+ STR0538+CRLF/*// 'Real'*/
cTexto += 'KpiIndicador_00051='+ STR0184+CRLF/*// 'Meta'*/
cTexto += 'KpiIndicador_00052='+ STR0476+CRLF/*// 'Pr�via'*/
cTexto += 'KpiIndicador_00053='+ STR0479+CRLF/*// 'data invalida'*/
cTexto += 'KpiIndicador_00054='+ STR0480+CRLF/*// 'O Nome n�o pode conter o caracter ">" (maior)'*/
cTexto += 'KpiIndicador_00055='+ STR0486+CRLF/*// '"Est� est� linha est� fora do per�odo de edi��o e n�o pode ser exclu�da."'*/
cTexto += 'KpiIndicador_00056='+ STR0527+CRLF/*// '"Informe uma f�rmula ou altere o tipo do acumulado. "*/
cTexto += 'KpiIndicador_00057='+ STR0463+CRLF/*// '"Orienta��o "*/
cTexto += 'KpiIndicador_00058='+ STR0464+CRLF/*// '"Alvos"*/
cTexto += 'KpiIndicador_00059='+ STR0465+CRLF/*// '"Respons�veis"*/ 
cTexto += 'KpiIndicador_00060='+ STR0579+CRLF/*// '"Tipo de atualiza��o:"*/ 
cTexto += 'KpiIndicador_00061='+ STR0623+CRLF/*// '"Usu�rio sem permiss�o para efetuar manuten��o"*/ 
cTexto += 'KpiIndicador_00062='+ STR0624+CRLF/*// '"Manuten��o bloqueada para indicadores com f�rmulas"*/ 
cTexto += 'KpiIndicador_00063='+ STR0625+CRLF/*// '"Somente respons�veis podem alterar a planilha"*/ 
cTexto += 'KpiIndicador_00064='+ STR0626+CRLF/*// '"Manuten��o bloqueada para esse per�odo'"*/ 
cTexto += 'KpiIndicador_00065='+ STR0628+CRLF/*// '"Indicador Pai'"*/ 
cTexto += 'KpiIndicador_00066='+ STR0652+CRLF/*// '"Dia limite para'"*/
cTexto += 'KpiIndicador_00067='+ STR0653+CRLF/*// '"preenchimento'"*/
cTexto += 'KpiIndicador_00068='+ STR0649+CRLF/*// '"Consultas:'"*/ 
cTexto += 'KpiIndicador_00069='+ STR0654+CRLF/*// '"Consulta:'"*/ 
cTexto += 'KpiIndicador_00070='+ STR0112+CRLF/*// '"Visualizar'"*/ 
cTexto += 'KpiIndicador_00071='+ STR0114+CRLF/*// '"Excluir'"*/ 
cTexto += 'KpiIndicador_00072='+ STR0243+CRLF/*// '"Visualiza��o'"*/ 
cTexto += 'KpiIndicador_00073='+ STR0655+CRLF/*// '"Tabela'"*/ 
cTexto += 'KpiIndicador_00074='+ STR0656+CRLF/*// '"Gr�fico'"*/ 
cTexto += 'KpiIndicador_00075='+ STR0657+CRLF/*// ' "Selecione uma linha para continuar."*/
cTexto += 'KpiIndicador_00076='+ STR0658+CRLF/*// ' "Esta consulta j� foi adicionada."*/
cTexto += 'KpiIndicador_00077='+ STR0659+CRLF/*// ' "Selecione uma consulta para adicionar."*/
cTexto += 'KpiIndicador_00078='+ STR0660+CRLF/*// ' "Por favor selecione uma consulta."*/
cTexto += 'KpiIndicador_00079='+ STR0661+CRLF/*// ' "Consulta"*/
cTexto += 'KpiIndicador_00080='+ STR0737+CRLF/*// ' "Deseja excluir todos os registros da planilha de valores?"*/
cTexto += 'KpiIndicador_00081='+ STR0738+CRLF/*// ' "Excluir Todos"*/
cTexto += 'KpiIndicador_00082='+ STR0751+CRLF/*// ' "Deseja excluir todos os registros do Ano de "*/
cTexto += 'KpiIndicador_00083='+ STR0752+CRLF/*// ' "Filtrar por Ano: "*/
cTexto += 'KpiIndicador_00084='+ STR0752+CRLF/*// ' "Filtrar por Ano: "*/
cTexto += 'KpiIndicador_00085='+ STR0649+CRLF/*// ' "Consultas: "*/
cTexto += 'KpiIndicador_00086='+ STR0765+CRLF/*// ' "Visualiza��o em: "*/
cTexto += 'KpiIndicador_00087='+ STR0655+CRLF/*// ' "Tabela "*/
cTexto += 'KpiIndicador_00088='+ STR0656+CRLF/*// ' "Gr�fico "*/  
cTexto += 'KpiIndicador_00089='+ STR0763+CRLF/*// ' "Integra��o com SIGADW"*/   
cTexto += 'KpiIndicador_00090='+ STR0807+CRLF/*// ' "M�todo"*/  
cTexto += 'KpiIndicador_00091='+ STR0808+CRLF/*// ' "Consolidador"*/  
cTexto += 'KpiIndicador_00092='+ STR0840+CRLF/*// ' "Painel de Widget"*/
cTexto += 'KpiIndicador_00093='+ STR0841+CRLF/*// ' "Tipo de An�lise:"*/
cTexto += 'KpiIndicador_00094='+ STR0842+CRLF/*// ' "Tipo de Gr�fico:"*/
cTexto += 'KpiIndicador_00095='+ STR0843+CRLF/*// ' "Tipo de An�lise n�o informado!"*/
cTexto += 'KpiIndicador_00096='+ STR0844+CRLF/*// ' "Tipo de Gr�fico n�o informado!"*/
cTexto += 'KpiIndicador_00097='+ STR0851+CRLF/*// ' "Valores no Gr�fico:"*/
cTexto += 'KpiIndicador_00098='+ STR0852+CRLF/*// ' "Valores no Gr�fico n�o informado!"*/
cTexto += 'KpiIndicador_00099='+ STR0852+CRLF/*// ' "Alvos"*/
cTexto += 'KpiIndicador_00100='+ STR0908+CRLF/*// ' "Barra"*/
cTexto += 'KpiIndicador_00101='+ STR0909+CRLF/*// ' "Odometro"*/
cTexto += 'KpiIndicador_00102='+ STR0910+CRLF/*// ' "Regua"*/
cTexto += 'KpiIndicador_00103='+ STR0911+CRLF/*// ' "Termometro"*/
cTexto += 'KpiIndicador_00104='+ STR0912+CRLF/*// ' "Ambos"*/
cTexto += 'KpiIndicador_00105='+ STR0913+CRLF/*// ' "Acumulado"*/
cTexto += 'KpiIndicador_00106='+ STR0914+CRLF/*// ' "Parcelado"*/
cTexto += 'KpiIndicador_00107='+ STR0915+CRLF/*// ' "Percentual"*/
cTexto += 'KpiIndicador_00108='+ STR0916+CRLF/*// ' "Preview"*/
cTexto += 'KpiIndicador_00109='+ STR0917+CRLF/*// ' "F�rmula R�pida"*/
cTexto += 'KpiIndicador_00110='+ STR0918+CRLF/*// ' "A express�o de filtro deve conter no m�nimo tr�s caracteres."*/
cTexto += 'KpiIndicador_00111='+ STR0907+CRLF/*// ' "Alvos"*/

//Cadastro de Meta Formula
cTexto += 'KpiMetaFormula_00001='+ STR0194+CRLF/*//'Cadastro de Meta F�rmula'*/
cTexto += 'KpiMetaFormula_00002='+ STR0131+CRLF/*//'Descri��o:'*/
cTexto += 'KpiMetaFormula_00003='+ STR0213+CRLF/*//'Verificar'*/
cTexto += 'KpiMetaFormula_00004='+ STR0214+CRLF/*//'Limpar'*/
cTexto += 'KpiMetaFormula_00005='+ STR0215+CRLF/*//'Express�o'*/
cTexto += 'KpiMetaFormula_00006='+ STR0004+CRLF/*//'Adicionar'*/
cTexto += 'KpiMetaFormula_00007='+ STR0216+CRLF/*//'F�rmula'*/
cTexto += 'KpiMetaFormula_00008='+ STR0134+CRLF/*//'Indicador:'*/
cTexto += 'KpiMetaFormula_00009='+ STR0178+CRLF/*//'Scorecard:'*/
cTexto += 'KpiMetaFormula_00010='+ STR0222+CRLF/*//'Meta F�rmula:'*/
cTexto += 'KpiMetaFormula_00011='+ STR0245+CRLF/*//'Nome n�o informado!'*/
cTexto += 'KpiMetaFormula_00012='+ STR0480+CRLF/*//'O Nome n�o pode conter o caracter ">" (maior)'*/
cTexto += 'KpiMetaFormula_00013='+ STR0349+CRLF/*//'Descri��o n�o informada!'*/
cTexto += 'KpiMetaFormula_00014='+ STR0352+CRLF/*//'F�rmula n�o informada!'*/
cTexto += 'KpiMetaFormula_00015='+ STR0427+CRLF/*//'A express�o n�o pode conter os caracteres: + - * /'*/

//Lembrete de pendecias
cTexto += 'KpiLembrete_00001='+ STR0225+CRLF/*//'Pend�ncias:'*/
cTexto += 'KpiLembrete_00002='+ STR0226+CRLF/*//'De Indicadores'*/
cTexto += 'KpiLembrete_00003='+ STR0227+CRLF/*//'A��es VENCIDAS'*/
cTexto += 'KpiLembrete_00004='+ STR0228+CRLF/*//'De Projetos'*/
cTexto += 'KpiLembrete_00005='+ STR0229+CRLF/*//'A��es a Vencer em at� '*/
cTexto += 'KpiLembrete_00006='+ STR0230+CRLF/*//'Lembrete'*/
cTexto += 'KpiLembrete_00007='+ STR0419+CRLF/*//'Mensagens (Caixa de entrada)'*/
cTexto += 'KpiLembrete_00008='+ STR0451+CRLF/*//'a��es'*/
cTexto += 'KpiLembrete_00009='+ STR0452+CRLF/*//'a��o'*/
cTexto += 'KpiLembrete_00010='+ STR0468+CRLF/*//' dia'*/
cTexto += 'KpiLembrete_00011='+ STR0469+CRLF/*//' dias'*/

//Cadastro do Agendador
cTexto += 'KpiAgendador_00001='+ STR0113+CRLF/*//'Editar'*/
cTexto += 'KpiAgendador_00002='+ STR0114+CRLF/*//'Excluir'*/
cTexto += 'KpiAgendador_00003='+ STR0128+CRLF/*//'Atualizar'*/
cTexto += 'KpiAgendador_00004='+ STR0117+CRLF/*//'Gravar'*/
cTexto += 'KpiAgendador_00005='+ STR0116+CRLF/*//'Cancelar'*/
cTexto += 'KpiAgendador_00006='+ STR0231+CRLF/*//'Ativo'*/
cTexto += 'KpiAgendador_00007='+ STR0168+CRLF/*//'Data In�cio'*/
cTexto += 'KpiAgendador_00008='+ STR0139+CRLF/*//'Data Fim'*/
cTexto += 'KpiAgendador_00009='+ STR0232+CRLF/*//'Hora In�cio'*/
cTexto += 'KpiAgendador_00010='+ STR0233+CRLF/*//'Hora Fim'*/
cTexto += 'KpiAgendador_00011='+ STR0234+CRLF/*//'Frequ�ncia'*/
cTexto += 'KpiAgendador_00012='+ STR0235+CRLF/*//'Diret�rio'*/
cTexto += 'KpiAgendador_00013='+ STR0236+CRLF/*//'Agendador de Tarefas'*/
cTexto += 'KpiAgendador_00014='+ STR0250+CRLF/*//'Importacao de dados'*/ 
cTexto += 'KpiAgendador_00015='+ STR0251+CRLF/*//'Agendador'*/  
cTexto += 'KpiAgendador_00016='+ STR0252+CRLF/*//'Iniciar'*/
cTexto += 'KpiAgendador_00017='+ STR0253+CRLF/*//'Parar'*/
cTexto += 'KpiAgendador_00018='+ STR0254+CRLF/*//'Situa��o'*/
cTexto += 'KpiAgendador_00019='+ STR0255+CRLF/*//'Iniciando ...'*/
cTexto += 'KpiAgendador_00020='+ STR0256+CRLF/*//'Parando ...'*/
cTexto += 'KpiAgendador_00021='+ STR0257+CRLF/*//'Executando ...'*/
cTexto += 'KpiAgendador_00022='+ STR0258+CRLF/*//'Parado!'*/    
cTexto += 'KpiAgendador_00023='+ STR0580+CRLF/*//'Agendamentos'*/   


//Cadastro do Agendamento
cTexto += 'KpiAgendamento_00001='+STR0236+CRLF/*// 'Agendamento'*/    
cTexto += 'KpiAgendamento_00002='+STR0336+CRLF/*// 'Comando a ser executado:'*/   
cTexto += 'KpiAgendamento_00003='+STR0337+CRLF/*// 'Ambiente:'*/   
cTexto += 'KpiAgendamento_00004='+STR0338+CRLF/*// 'Data de In�cio:'*/   
cTexto += 'KpiAgendamento_00005='+STR0339+CRLF/*// 'Data de T�rmino:'*/   
cTexto += 'KpiAgendamento_00006='+STR0340+CRLF/*// 'Executado em:'*/   
cTexto += 'KpiAgendamento_00007='+STR0202+CRLF/*// 'Freq��ncia:*/   
cTexto += 'KpiAgendamento_00008='+STR0341+CRLF/*// 'Elemento:'*/   
cTexto += 'KpiAgendamento_00009='+STR0342+CRLF/*// 'A��o:'*/   
cTexto += 'KpiAgendamento_00010='+STR0343+CRLF/*// 'Pasta de origem:'*/   
cTexto += 'KpiAgendamento_00011='+STR0335+CRLF/*// 'Logs*/ 
cTexto += 'KpiAgendamento_00012='+STR0496+CRLF/*// 'Selecione o item para importa��o da fonte de dados.*/ 
cTexto += 'KpiAgendamento_00013='+STR0516+CRLF/*// 'Calculos*/ 
cTexto += 'KpiAgendamento_00014='+STR0629+CRLF/*// 'Preencher at� dia:*/ 
cTexto += 'KpiAgendamento_00015='+STR0630+CRLF/*// 'Dia limite para preenchimento inv�lido.*/ 
cTexto += 'KpiAgendamento_00016='+STR0693+CRLF/*// 'Agendar'*/ 
cTexto += 'KpiAgendamento_00017='+STR0694+CRLF/*// 'Per�odo'*/ 
cTexto += 'KpiAgendamento_00018='+STR0695+CRLF/*// 'Hor�rio:'*/ 
cTexto += 'KpiAgendamento_00019='+STR0696+CRLF/*// 'Frequ�ncia'*/ 
cTexto += 'KpiAgendamento_00020='+STR0697+CRLF/*// 'Di�rio'*/ 
cTexto += 'KpiAgendamento_00021='+STR0698+CRLF/*// 'Semanal'*/ 
cTexto += 'KpiAgendamento_00022='+STR0699+CRLF/*// 'Mensal'*/ 
cTexto += 'KpiAgendamento_00023='+STR0700+CRLF/*// '�ltima execu��o'*/ 
cTexto += 'KpiAgendamento_00024='+STR0701+CRLF/*// 'Pr�xima execu��o'*/ 
cTexto += 'KpiAgendamento_00025='+STR0702+CRLF/*// 'Tarefa'*/ 
cTexto += 'KpiAgendamento_00026='+STR0192+CRLF/*// 'Dia'*/ 
cTexto += 'KpiAgendamento_00027='+STR0650+CRLF/*// 'Data:'*/
cTexto += 'KpiAgendamento_00028='+STR0592+CRLF/*// 'Detalhes'*/ 
cTexto += 'KpiAgendamento_00029='+ STR0833+CRLF/*//'Per�odo Fixo'*/ 
cTexto += 'KpiAgendamento_00030='+ STR0834+CRLF/*//'Per�odo Din�mico'*/     
cTexto += 'KpiAgendamento_00031='+ STR0835+CRLF/*//'Calcular da Data da Execu��o (-)'*/     
cTexto += 'KpiAgendamento_00032='+ STR0836+CRLF/*//'Calcular at� a Data da Execu��o (+)'*/ 
cTexto += 'KpiAgendamento_00033='+ STR0837+CRLF/*//'Dias:'*/       

//Senha do Usuario
cTexto += 'KpiSenhaDialog_00001='+STR0259+CRLF/*//'Senha'*/
cTexto += 'KpiSenhaDialog_00002='+STR0260+CRLF/*//'A senha e a confirma\u00E7\u00E3o da senha diferem.\ '*/
cTexto += 'KpiSenhaDialog_00003='+STR0261+CRLF/*//'Digite novamente.'*/
cTexto += 'KpiSenhaDialog_00004='+STR0262+CRLF/*//'A senha deve ter mais de 3 dig\u00EDtos.'*/
cTexto += 'KpiSenhaDialog_00005='+STR0263+CRLF/*//'Ok'*/
cTexto += 'KpiSenhaDialog_00006='+STR0116+CRLF/*//'Cancelar'*/
cTexto += 'KpiSenhaDialog_00007='+STR0264+CRLF/*//'Confirmar Senha:'*/
cTexto += 'KpiSenhaDialog_00008='+STR0088+CRLF/*//'Senha:'*/

//Painel de indicadores
cTexto += 'KpiPainel_00001='+STR0268+CRLF/*//'Painel de Indicadores'*/
cTexto += 'KpiPainel_00002='+STR0131+CRLF/*//'Descri��o:'*/
cTexto += 'KpiPainel_00003='+STR0269+CRLF/*//'Painel:'*/
cTexto += 'KpiPainel_00004='+STR0178+CRLF/*//'Scorecard:'*/
cTexto += 'KpiPainel_00005='+STR0134+CRLF/*//'Indicador:'*/
cTexto += 'KpiPainel_00006='+STR0275+CRLF/*//'Data Alvo:'*/
cTexto += 'KpiPainel_00007='+STR0270+CRLF/*//'Acumulado de:'*/
cTexto += 'KpiPainel_00008='+STR0271+CRLF/*//'At�:'*/
cTexto += 'KpiPainel_00009='+STR0085+CRLF/*//'Tipo de vizualiza��o:'*/
cTexto += 'KpiPainel_00010='+STR0174+CRLF/*//'Planos de A��es'*/
cTexto += 'KpiPainel_00011='+STR0272+CRLF/*//'Imprimir'*/
cTexto += 'KpiPainel_00012='+STR0273+CRLF/*//'Valor Atual:'*/
cTexto += 'KpiPainel_00013='+STR0274+CRLF/*//'Valor Anterior:'*/
cTexto += 'KpiPainel_00014='+STR0359+CRLF/*//'Painel n�o informado!'*/
cTexto += 'KpiPainel_00015='+STR0478+CRLF/*//'Valor Previsto:'*/
cTexto += 'KpiPainel_00016='+STR0577+CRLF/*//'Op��es de An�lise'*/
cTexto += 'KpiPainel_00017='+STR0276+CRLF/*//'Gr�ficos'*/

//ScoreCarding
cTexto += 'KpiScoreCarding_00001='+STR0031+CRLF/*//'ScoreCarding'*/
cTexto += 'KpiScoreCarding_00002='+STR0276+CRLF/*//'Gr�ficos'*/
cTexto += 'KpiScoreCarding_00003='+STR0277+CRLF/*//'Anterior'*/
cTexto += 'KpiScoreCarding_00004='+STR0278+CRLF/*//'Posterior'*/
cTexto += 'KpiScoreCarding_00005='+STR0275+CRLF/*//'Data Alvo'*/
cTexto += 'KpiScoreCarding_00006='+STR0270+CRLF/*//'Acumulado de'*/
cTexto += 'KpiScoreCarding_00007='+STR0271+CRLF/*//'At�'*/
cTexto += 'KpiScoreCarding_00008='+STR0280+CRLF/*//'Indicadores Analisados:'*/
cTexto += 'KpiScoreCarding_00009='+STR0281+CRLF/*//'Clique para ver os indicadores filhos.'*/
cTexto += 'KpiScoreCarding_00010='+STR0282+CRLF/*//'Lista de Plano de A��es'*/
cTexto += 'KpiScoreCarding_00011='+cTextScor+CRLF
cTexto += 'KpiScoreCarding_00012='+STR0361+CRLF/*//' - Por Usu�rio'*/
cTexto += 'KpiScoreCarding_00013='+STR0362+CRLF/*//' - Por Indicador'*/
cTexto += 'KpiScoreCarding_00014='+STR0372+CRLF/*//'Data base da analise.'*/
cTexto += 'KpiScoreCarding_00015='+STR0373+CRLF/*//'Data de inicio para o c�lculo do acumulado.'*/
cTexto += 'KpiScoreCarding_00016='+STR0374+CRLF/*//'Data final para o c�lculo do acumulado.'*/
cTexto += 'KpiScoreCarding_00017='+STR0375+CRLF/*//'Minhas A��es'*/
cTexto += 'KpiScoreCarding_00018='+STR0376+CRLF/*//'Mostra a lista de a��es deste usu�rio.'*/
cTexto += 'KpiScoreCarding_00019='+STR0377+CRLF/*//'Meus Projetos'*/
cTexto += 'KpiScoreCarding_00020='+STR0378+CRLF/*//'Mostra a lista de projetos deste usu�rio.'*/
cTexto += 'KpiScoreCarding_00021='+STR0379+CRLF/*//'Mostra o gr�fico do indicador selecionado.'*/
cTexto += 'KpiScoreCarding_00022='+STR0380+CRLF/*//'Abre o cadastro do indicador selecionado.'*/
cTexto += 'KpiScoreCarding_00023='+STR0381+CRLF/*//'Faz a atualiza��o da tabela.'*/
cTexto += 'KpiScoreCarding_00024='+STR0382+CRLF/*//'Voltar.'*/
cTexto += 'KpiScoreCarding_00025='+STR0383+CRLF/*//'Avan�ar.'*/
cTexto += 'KpiScoreCarding_00026='+STR0384+CRLF/*//'Mostra os indicadores que j� foram analisados.'*/
cTexto += 'KpiScoreCarding_00027='+STR0441+CRLF/*//'por Scorecards'*/
cTexto += 'KpiScoreCarding_00028='+STR0442+CRLF/*//'A��es do Scorecard'*/
cTexto += 'KpiScoreCarding_00029='+STR0446+CRLF/*//'Relat�rio'*/
cTexto += 'KpiScoreCarding_00030='+STR0460+CRLF/*//'Navegacao'*/
cTexto += 'KpiScoreCarding_00031='+STR0495+CRLF/*//'Comparativo'*/
cTexto += 'KpiScoreCarding_00032='+STR0494+CRLF/*//'Mostrar todos os per�odos do Acumulado'*/
cTexto += 'KpiScoreCarding_00033='+STR0515+CRLF/*//'A data alvo n�o pode ser menor que o 'Acumulado de' e n�o pode ser maior que o 'Acumulado At�'!'*/
cTexto += 'KpiScoreCarding_00034='+STR0581+CRLF/*//'Congelar colunas sem valores'*/
cTexto += 'KpiScoreCarding_00035='+STR0582+CRLF/*//'Descongelar colunas sem valores'*/
cTexto += 'KpiScoreCarding_00036='+STR0622+CRLF/*//'Visualiza��o por Pacote'*/
cTexto += 'KpiScoreCarding_00037='+STR0662+CRLF/*//'Consultas do DW'*/
cTexto += 'KpiScoreCarding_00038='+STR0663+CRLF/*//'N�o existem consultas para este indicador.'*/
cTexto += 'KpiScoreCarding_00039='+STR0664+CRLF/*//'Por favor selecione um indicador.'*/
cTexto += 'KpiScoreCarding_00040='+STR0665+CRLF/*//'Ativar o refresh autom�tico.'*/
cTexto += 'KpiScoreCarding_00041='+STR0674+CRLF/*//'Varia��o (Diferen�a)'*/
cTexto += 'KpiScoreCarding_00042='+STR0675+CRLF/*//'Varia��o (Percentual)'*/
cTexto += 'KpiScoreCarding_00043='+STR0703+CRLF/*//'Indicador atingiu a meta e n�o existe plano de a��o cadastrado'*/
cTexto += 'KpiScoreCarding_00044='+STR0704+CRLF/*//'Existe plano de a��o cadastrado para o indicador'*/
cTexto += 'KpiScoreCarding_00045='+STR0705+CRLF/*//'Indicador n�o atingiu a meta e n�o existe plano de a��o cadastrado'*/
cTexto += 'KpiScoreCarding_00046='+STR0706+CRLF/*//'N�o existem valores para efetuar a compara��o'*/
cTexto += 'KpiScoreCarding_00047='+STR0707+CRLF/*//'Atingiu a meta com valor menor que o per�odo anterior'*/
cTexto += 'KpiScoreCarding_00048='+STR0708+CRLF/*//'Atingiu a meta com valor maior que o per�odo anterior'*/
cTexto += 'KpiScoreCarding_00049='+STR0709+CRLF/*//'Atingiu a meta e manteve o mesmo resultado do per�odo anterior'*/
cTexto += 'KpiScoreCarding_00050='+STR0710+CRLF/*//'N�o atingiu a meta e o resultado alcan�ado foi menor que o per�odo anterior'*/
cTexto += 'KpiScoreCarding_00051='+STR0711+CRLF/*//'N�o atingiu a meta, mas o resultado alcan�ado foi maior que o per�odo anterior'*/
cTexto += 'KpiScoreCarding_00052='+STR0712+CRLF/*//'N�o atingiu a meta e manteve o mesmo resultado do per�odo anterior'*/
cTexto += 'KpiScoreCarding_00053='+STR0713+CRLF/*//'Atingiu a meta na toler�ncia com valor menor que o per�odo anterior'*/
cTexto += 'KpiScoreCarding_00054='+STR0714+CRLF/*//'Atingiu a meta na toler�ncia com valor maior que o per�odo anterior'*/
cTexto += 'KpiScoreCarding_00055='+STR0715+CRLF/*//'Atingiu a meta na toler�ncia e manteve o mesmo resultado do per�odo anterior'*/
cTexto += 'KpiScoreCarding_00056='+STR0747+CRLF/*//'Restaurar configura��es'*/
cTexto += 'KpiScoreCarding_00057='+STR0748+CRLF/*//'Salvar configura��es'*/
cTexto += 'KpiScoreCarding_00058='+STR0749+CRLF/*//'Salvar configura��es relacionadas a coluna (congelamento e largura).'*/
cTexto += 'KpiScoreCarding_00059='+STR0778+CRLF/*//'Abrir link relacionado.'*/
cTexto += 'KpiScoreCarding_00060='+STR0777+CRLF/*//'Visualiza��o da F�rmula de Indicadores'*/
cTexto += 'KpiScoreCarding_00061='+STR0808+CRLF/*//'Consolidador'*/          
cTexto += 'KpiScoreCarding_00062='+STR0945+CRLF/*//'Superou a meta com valor menor que o per�odo anterior'*/          
cTexto += 'KpiScoreCarding_00063='+STR0946+CRLF/*//'Superou a meta com valor maior que o per�odo anterior'*/          
cTexto += 'KpiScoreCarding_00064='+STR0947+CRLF/*//'Superou a meta e manteve o mesmo resultado do per�odo anterior'*/        
cTexto += 'KpiScoreCarding_00065='+STR0994+CRLF/*//'Mapa Estrat�gico - Modelo 1*/
cTexto += 'KpiScoreCarding_00066='+STR0995+CRLF/*//'Mapa Estrat�gico - Modelo 2*/

//Graficos
cTexto += 'KpiGraphIndicador_00001='+STR0284+CRLF/*//'Barra'*/
cTexto += 'KpiGraphIndicador_00002='+STR0285+CRLF/*//'Barra 3D'*/
cTexto += 'KpiGraphIndicador_00003='+STR0286+CRLF/*//'Linha'*/
cTexto += 'KpiGraphIndicador_00004='+STR0287+CRLF/*//'Linha 3D'*/
cTexto += 'KpiGraphIndicador_00005='+STR0288+CRLF/*//'Pizza'*/
cTexto += 'KpiGraphIndicador_00006='+STR0289+CRLF/*//'Pizza 3D'*/
cTexto += 'KpiGraphIndicador_00007='+STR0290+CRLF/*//'Gr�fico de Indicadores'*/
cTexto += 'KpiGraphIndicador_00008='+STR0128+CRLF/*//'Atualizar'*/
cTexto += 'KpiGraphIndicador_00009='+STR0130+CRLF/*//'Configura��es'*/
cTexto += 'KpiGraphIndicador_00010='+STR0291+CRLF/*//'Tipo do gr�fico:'*/
cTexto += 'KpiGraphIndicador_00011='+STR0115+CRLF/*//'Ajuda'*/
cTexto += 'KpiGraphIndicador_00012='+STR0292+CRLF/*//'Fechar'*/
cTexto += 'KpiGraphIndicador_00013='+STR0293+CRLF/*//'Cor de fundo'*/
cTexto += 'KpiGraphIndicador_00014='+STR0294+CRLF/*//'Inverter Eixos'*/
cTexto += 'KpiGraphIndicador_00015='+STR0295+CRLF/*//'Legenda do eixo X'*/
cTexto += 'KpiGraphIndicador_00016='+STR0296+CRLF/*//'Legenda do eixo Y'*/
cTexto += 'KpiGraphIndicador_00017='+STR0297+CRLF/*//'Legenda do eixo Z'*/
cTexto += 'KpiGraphIndicador_00018='+STR0298+CRLF/*//'Sele��o de linhas'*/
cTexto += 'KpiGraphIndicador_00019='+STR0299+CRLF/*//'Mostrar valor'*/
cTexto += 'KpiGraphIndicador_00020='+STR0300+CRLF/*//'Cor'*/
cTexto += 'KpiGraphIndicador_00021='+STR0301+CRLF/*//'Mostrar Meta'*/
cTexto += 'KpiGraphIndicador_00022='+STR0302+CRLF/*//'Mostrar diferen�a'*/
cTexto += 'KpiGraphIndicador_00023='+STR0303+CRLF/*//'Sele��o de colunas'*/
cTexto += 'KpiGraphIndicador_00024='+STR0304+CRLF/*//'Use <Ctrl + Mouse Click> para Zoom ou <Shit+ Mouse Click> para rotacionar'*/
cTexto += 'KpiGraphIndicador_00025='+STR0305+CRLF/*//'Por favor, aguarde o processamento do indicador...'*/
cTexto += 'KpiGraphIndicador_00026='+STR0183+CRLF/*//'Valor'*/
cTexto += 'KpiGraphIndicador_00027='+STR0184+CRLF/*//'Meta'*/
cTexto += 'KpiGraphIndicador_00028='+STR0306+CRLF/*//'Diferen�a'*/
cTexto += 'KpiGraphIndicador_00029='+STR0307+CRLF/*//'Sem legenda'*/
cTexto += 'KpiGraphIndicador_00030='+STR0308+CRLF/*//'A esquerda'*/
cTexto += 'KpiGraphIndicador_00031='+STR0309+CRLF/*//'A direita'*/
cTexto += 'KpiGraphIndicador_00032='+STR0310+CRLF/*//'Em baixo'*/
cTexto += 'KpiGraphIndicador_00033='+STR0139+CRLF/*//'Abrir'*/
cTexto += 'KpiGraphIndicador_00034='+STR0363+CRLF/*//'Exportar'*/
cTexto += 'KpiGraphIndicador_00035='+STR0476+CRLF/*//'Pr�via'*/
cTexto += 'KpiGraphIndicador_00036='+STR0477+CRLF/*//'Mostra pr�via'*/
cTexto += 'KpiGraphIndicador_00037='+STR0529+CRLF/*//'"M�s por extenso"	'*/	
cTexto += 'KpiGraphIndicador_00038='+STR0271+CRLF/*//'"Ate:"'*/
cTexto += 'KpiGraphIndicador_00039='+STR0561+CRLF/*//'"Zoom:"'*/
cTexto += 'KpiGraphIndicador_00040='+STR0562+CRLF/*//'"Data de:"'*/
cTexto += 'KpiGraphIndicador_00041='+STR0563+CRLF/*//'"Legenda:"'*/
cTexto += 'KpiGraphIndicador_00042='+STR0564+CRLF/*//'"Tipo:"'*/
cTexto += 'KpiGraphIndicador_00043='+STR0565+CRLF/*//'"Gr�fico"'*/
cTexto += 'KpiGraphIndicador_00044='+STR0566+CRLF/*//'"S�rie"'*/
cTexto += 'KpiGraphIndicador_00045='+STR0183+CRLF/*//'"Valor"'*/
cTexto += 'KpiGraphIndicador_00046='+STR0184+CRLF/*//'"Meta"'*/
cTexto += 'KpiGraphIndicador_00047='+STR0306+CRLF/*//'"Diferen�a"'*/
cTexto += 'KpiGraphIndicador_00048='+STR0476+CRLF/*//'"Previa"'*/
cTexto += 'KpiGraphIndicador_00049='+STR0567+CRLF/*//'"Grafico - XY"'*/
cTexto += 'KpiGraphIndicador_00050='+STR0568+CRLF/*//'"Grafico - Pizza"'*/
cTexto += 'KpiGraphIndicador_00051='+STR0569+CRLF/*//'"O valor digitado nao e valido"'*/
cTexto += 'KpiGraphIndicador_00052='+STR0570+CRLF/*//'"O valor maximo do zoom e 150%"'*/
cTexto += 'KpiGraphIndicador_00053='+STR0571+CRLF/*//'"Cilindro"'*/
cTexto += 'KpiGraphIndicador_00054='+STR0572+CRLF/*//'"Em cima"'*/
cTexto += 'KpiGraphIndicador_00055='+STR0573+CRLF/*//'"Perido"'*/
cTexto += 'KpiGraphIndicador_00056='+STR0574+CRLF/*//'"Valores"'*/
cTexto += 'KpiGraphIndicador_00057='+STR0200+CRLF/*//'"Quanto Maior Melhor"'*/
cTexto += 'KpiGraphIndicador_00058='+STR0201+CRLF/*//'"Quanto Menor Melhor"'*/        
cTexto += 'KpiGraphIndicador_00059='+STR0688+CRLF/*//'"Atingido"'*/
cTexto += 'KpiGraphIndicador_00060='+STR0689+CRLF/*//'"N�o atingido"'*/
cTexto += 'KpiGraphIndicador_00061='+STR0690+CRLF/*//'"Na toler�ncia"'*/
cTexto += 'KpiGraphIndicador_00062='+STR0539+CRLF/*//'"Tipo:"'*/
cTexto += 'KpiGraphIndicador_00063='+STR0691+CRLF/*//'"Exibir valores"'*/
cTexto += 'KpiGraphIndicador_00064='+STR0117+CRLF/*//'"Gravar"'*/
cTexto += 'KpiGraphIndicador_00065='+STR0845+CRLF/*//'Mostrar valor acumulado'*/
cTexto += 'KpiGraphIndicador_00066='+STR0846+CRLF/*//'Mostrar meta acumulada'*/
cTexto += 'KpiGraphIndicador_00067='+STR0847+CRLF/*//'Mostrar pr�via acumulada'*/
cTexto += 'KpiGraphIndicador_00068='+STR0848+CRLF/*//'Valor Acumulado'*/
cTexto += 'KpiGraphIndicador_00069='+STR0849+CRLF/*//'Meta Acumulada'*/
cTexto += 'KpiGraphIndicador_00070='+STR0850+CRLF/*//'Pr�via Acumulada'*/
cTexto += 'KpiGraphIndicador_00071='+STR0944+CRLF/*//'Superou'*/

//Relatorio do Plano de Acoes
cTexto += 'KpiRelatorioPlanoAcao_00001='+STR0118+CRLF/*//'Nome:'*/
cTexto += 'KpiRelatorioPlanoAcao_00002='+STR0131+CRLF/*//'Descri��o:'*/
cTexto += 'KpiRelatorioPlanoAcao_00003='+STR0311+CRLF/*//'Imprimir:'*/
cTexto += 'KpiRelatorioPlanoAcao_00004='+STR0312+CRLF/*//'Imprime Descri��o'*/
cTexto += 'KpiRelatorioPlanoAcao_00005='+STR0313+CRLF/*//'Projeto de:'*/
cTexto += 'KpiRelatorioPlanoAcao_00006='+STR0314+CRLF/*//'At� o projeto:'*/
cTexto += 'KpiRelatorioPlanoAcao_00007='+STR0178+CRLF/*//'Scorecard:'*/
cTexto += 'KpiRelatorioPlanoAcao_00008='+STR0315+CRLF/*//'Indicador de:'*/
cTexto += 'KpiRelatorioPlanoAcao_00009='+STR0316+CRLF/*//'At� o Indicador:'*/
cTexto += 'KpiRelatorioPlanoAcao_00010='+STR0317+CRLF/*//'Usu�rio de:'*/
cTexto += 'KpiRelatorioPlanoAcao_00011='+STR0318+CRLF/*//'At� o Usu�rio:'*/
cTexto += 'KpiRelatorioPlanoAcao_00012='+STR0319+CRLF/*//'In�cio de:'*/
cTexto += 'KpiRelatorioPlanoAcao_00013='+STR0271+CRLF/*//'At�:'*/
cTexto += 'KpiRelatorioPlanoAcao_00014='+STR0320+CRLF/*//'T�rmino de:'*/
cTexto += 'KpiRelatorioPlanoAcao_00015='+STR0321+CRLF/*//'Situa��o:'*/
cTexto += 'KpiRelatorioPlanoAcao_00016='+STR0322+CRLF/*//'Gerar'*/
cTexto += 'KpiRelatorioPlanoAcao_00017='+STR0112+CRLF/*//'Visualizar'*/
cTexto += 'KpiRelatorioPlanoAcao_00018='+STR0117+CRLF/*//'Gravar'*/      
cTexto += 'KpiRelatorioPlanoAcao_00019='+STR0447+CRLF/*//'Filtro'*/      
cTexto += 'KpiRelatorioPlanoAcao_00020='+STR0171+CRLF/*//'Status:'*/
cTexto += 'KpiRelatorioPlanoAcao_00021='+STR0139+CRLF/*//'Abrir'*/
cTexto += 'KpiRelatorioPlanoAcao_00022='+STR0790+CRLF/*//'Relat�rio de Planos de A��o'*/

//Calculo dos indicadores
cTexto += 'KpiCalcIndicador_00001='+STR0323+CRLF/*//'A data de c�lculo n�o pode abranger anos diferentes.'*/
cTexto += 'KpiCalcIndicador_00002='+STR0324+CRLF/*//'Enquanto os indicadores estiverem sendo calculados, os dados apresentados no scorecarding podem ficar inconsistentes.'*/
cTexto += 'KpiCalcIndicador_00003='+STR0325+CRLF/*//'C�lculo em processamento. Por favor, aguarde...'*/
cTexto += 'KpiCalcIndicador_00004='+STR0326+CRLF/*//'Enquanto os indicadores estiverem sendo calculados, os dados apresentados no scorecarding podem ficar inconsistentes.'*/
cTexto += 'KpiCalcIndicador_00005='+STR0327+CRLF/*//'Parada solicitada. Por favor aguarde a finaliza��o do processamento atual.'*/
cTexto += 'KpiCalcIndicador_00006='+STR0328+CRLF/*//'Pressione o bot�o calcular para iniciar o c�lculo dos indicadores.'*/
cTexto += 'KpiCalcIndicador_00007='+STR0329+CRLF/*//'C�lculo'*/
cTexto += 'KpiCalcIndicador_00008='+STR0330+CRLF/*//'C�lculo dos Indicadores'*/
cTexto += 'KpiCalcIndicador_00009='+STR0331+CRLF/*//'Existe um c�lculo em processamento. Por favor, aguarde...'*/
cTexto += 'KpiCalcIndicador_00010='+STR0332+CRLF/*//'Calcular de:'*/
cTexto += 'KpiCalcIndicador_00011='+STR0271+CRLF/*//'At�'*/
cTexto += 'KpiCalcIndicador_00012='+STR0178+CRLF/*//'ScoreCard:'*/
cTexto += 'KpiCalcIndicador_00013='+STR0333+CRLF/*//'Calcular'*/
cTexto += 'KpiCalcIndicador_00014='+STR0334+CRLF/*//'Atualizar Status'*/
cTexto += 'KpiCalcIndicador_00015='+STR0253+CRLF/*//'Parar '*/
cTexto += 'KpiCalcIndicador_00016='+STR0335+CRLF/*//'Logs'*/
cTexto += 'KpiCalcIndicador_00017='+STR0029+CRLF/*//'Mensagem'*/

//Duplicador
cTexto += 'KpiDuplicador_00001='+STR0364+CRLF/*// 'O campo diferenciador n�o pode conter "."'*/
cTexto += 'KpiDuplicador_00002='+STR0365+CRLF/*// 'Duplicando... Aguarde a finaliza��o da duplica��o do(s) Scorecard(s).'*/
cTexto += 'KpiDuplicador_00003='+STR0366+CRLF/*// 'Duplica��o conclu�da.'*/
cTexto += 'KpiDuplicador_00004='+STR0367+CRLF/*// 'Duplicador'*/
cTexto += 'KpiDuplicador_00005='+STR0368+CRLF/*// 'Origem:'*/
cTexto += 'KpiDuplicador_00006='+STR0369+CRLF/*// 'Scorecard Pai:'*/
cTexto += 'KpiDuplicador_00007='+STR0370+CRLF/*// 'Diferenciador:'*/
cTexto += 'KpiDuplicador_00008='+STR0371+CRLF/*// 'Duplicar'*/
cTexto += 'KpiDuplicador_00009='+STR0308+CRLF/*// 'A esquerda'*/
cTexto += 'KpiDuplicador_00010='+STR0309+CRLF/*//'A direita'*/ 
cTexto += 'KpiDuplicador_00011='+STR0535+CRLF/*//'Alinhamento'*/ 
cTexto += 'KpiDuplicador_00012='+STR0536+CRLF/*//'Aplicar aos indicadores'*/ 
cTexto += 'KpiDuplicador_00013='+STR0537+CRLF/*//'Destino'*/ 

//Unidade
cTexto += 'KpiUnidade_00001='+STR0386+CRLF/*// 'Cadastro de Unidades'*/
cTexto += 'KpiUnidade_00002='+STR0387+CRLF/*// 'Unidade de Medida'*/
cTexto += 'KpiUnidade_00003='+STR0118+CRLF/*// 'Nome:'*/
cTexto += 'KpiUnidade_00004='+STR0131+CRLF/*// 'Descri��o:'*/
cTexto += 'KpiUnidade_00005='+STR0245+CRLF/*// 'Nome n�o informado!'*/

//Lista de Unidades
cTexto += 'KpiListaUnidade_00001='+STR0388+CRLF/*// 'Unidades de Medida'*/
cTexto += 'KpiListaUnidade_00002='+STR0010+CRLF/*//'Consultas'*/

//JBIMessagePanel
cTexto += 'JBIMessagePanel_00001='+STR0392+CRLF/*// 'Unidades de Medida'*/
cTexto += 'JBIMessagePanel_00002='+STR0389+CRLF/*// 'Responder'*/
cTexto += 'JBIMessagePanel_00003='+STR0390+CRLF/*// 'Responder a todos'*/
cTexto += 'JBIMessagePanel_00004='+STR0391+CRLF/*// 'Encaminhar'*/        

//KPIMenssagem
cTexto += 'KPIMenssagem_00001='+STR0400+CRLF/*//'Anexo:'*/
cTexto += 'KPIMenssagem_00002='+STR0394+CRLF/*//'Mensagens'*/
cTexto += 'KPIMenssagem_00003='+STR0395+CRLF/*//'Enviar'*/
cTexto += 'KPIMenssagem_00004='+STR0389+CRLF/*//'Responder'*/
cTexto += 'KPIMenssagem_00005='+STR0390+CRLF/*//'Responder a todos'*/
cTexto += 'KPIMenssagem_00006='+STR0391+CRLF/*//'Encaminhar'*/
cTexto += 'KPIMenssagem_00007='+STR0396+CRLF/*//'De:'*/
cTexto += 'KPIMenssagem_00008='+STR0397+CRLF/*//'Plano de A��o:'*/
cTexto += 'KPIMenssagem_00009='+STR0029+CRLF/*//'Mensagem'*/
cTexto += 'KPIMenssagem_00010='+STR0398+CRLF/*//'Prioridade:'*/
cTexto += 'KPIMenssagem_00011='+STR0022+CRLF/*//'M�dia'*/
cTexto += 'KPIMenssagem_00012='+STR0399+CRLF/*//'Baixa'*/
cTexto += 'KPIMenssagem_00013='+STR0400+CRLF/*//'Anexo'//certo*/
cTexto += 'KPIMenssagem_00014='+STR0139+CRLF/*//'Abrir'*/
cTexto += 'KPIMenssagem_00015='+STR0401+CRLF/*//'Para'*/
cTexto += 'KPIMenssagem_00016='+STR0402+CRLF/*//'CC'*/
cTexto += 'KPIMenssagem_00017='+STR0403+CRLF/*//'Deseja notificar por email?'*/
cTexto += 'KPIMenssagem_00018='+STR0404+CRLF/*//'O link n�o pode ser aberto:'*/
cTexto += 'KPIMenssagem_00019='+STR0405+CRLF/*//'Resp:'*/
cTexto += 'KPIMenssagem_00020='+STR0406+CRLF/*//'Enc: '*/
cTexto += 'KPIMenssagem_00021='+STR0407+CRLF/*//'Alta'*/
cTexto += 'KPIMenssagem_00022='+STR0408+CRLF/*//'Mensagem:'*/
cTexto += 'KPIMenssagem_00023='+STR0467+CRLF/*//'O destinat�rio n�o foi informado!'*/
cTexto += 'KPIMenssagem_00024='+STR0750+CRLF/*//'Deseja excluir todas as mensagens?'*/

//KPIMenssagens Enviadas
cTexto += 'KPIMenssagensEnviadas_00001='+STR0409+CRLF/*//'Mensagens Enviadas'*/


//KPIMenssagens Recebidas
cTexto += 'KPIMenssagensRecebidas_00001='+STR0410+CRLF/*//'Mensagens Recebidas'*/

//KPIMenssagens Excluidas
cTexto += 'KPIMenssagensExcluidas_00001='+STR0411+CRLF/*//'Mensagens Exclu�das'*/

//KPIMenssagens Excluidas
cTexto += 'KPISMTPConfFrame_00001='+STR0412+CRLF/*// 'Conta de e-mail:'*/
cTexto += 'KPISMTPConfFrame_00002='+STR0413+CRLF/*// 'Servidor SMTP:'*/
cTexto += 'KPISMTPConfFrame_00003='+STR0414+CRLF/*// 'Porta SMTP:'*/
cTexto += 'KPISMTPConfFrame_00004='+STR0150+CRLF/*// 'Usu�rio:'*/
cTexto += 'KPISMTPConfFrame_00005='+STR0151+CRLF/*// 'Porta SMTP:'*/
cTexto += 'KPISMTPConfFrame_00006='+STR0415+CRLF/*// 'A conta deve ser informada.'*/
cTexto += 'KPISMTPConfFrame_00007='+STR0416+CRLF/*// +'O servidor de SMTP deve ser informado.'*/
cTexto += 'KPISMTPConfFrame_00008='+STR0418+CRLF/*// +'Servidor de e-mail'*/
cTexto += 'KPISMTPConfFrame_00009='+STR0129+CRLF/*// +'Configuracao'*/
             
//Relatorio de Scorecards e Indicadores
cTexto += 'KpiRelatorioScoreInd_00001='+STR0423+CRLF/*//'Relat�rio de Scorecads e Indicadores'*/
cTexto += 'KpiRelatorioScoreInd_00002='+STR0118+CRLF/*//'Nome:'*/
cTexto += 'KpiRelatorioScoreInd_00003='+STR0131+CRLF/*//'Descri��o:'*/
cTexto += 'KpiRelatorioScoreInd_00004='+STR0312+CRLF/*//'Imprime Descri��o?'*/
cTexto += 'KpiRelatorioScoreInd_00005='+STR0424+CRLF/*//'Scorecard De:'*/
cTexto += 'KpiRelatorioScoreInd_00006='+STR0425+CRLF/*//'Scorecard Ate:'*/
cTexto += 'KpiRelatorioScoreInd_00007='+STR0426+CRLF/*//'Imprime Indicadores?'*/
cTexto += 'KpiRelatorioScoreInd_00008='+STR0322+CRLF/*//'Gerar'*/
cTexto += 'KpiRelatorioScoreInd_00009='+STR0112+CRLF/*//'Visualizar'*/
cTexto += 'KpiRelatorioScoreInd_00010='+STR0117+CRLF/*//'Gravar'*/
cTexto += 'KpiRelatorioScoreInd_00011='+STR0447+CRLF/*//'Filtro'*/
cTexto += 'KpiRelatorioScoreInd_00012='+STR0139+CRLF/*//'Abrir'*/

//Parametros do Sistema
cTexto += 'KpiParametrosSistema_00001='+STR0428+CRLF/*//'Par�metros do Sistema'*/
cTexto += 'KpiParametrosSistema_00002='+STR0429+CRLF/*//'Vers�o do KPI:'*/
cTexto += 'KpiParametrosSistema_00003='+STR0430+CRLF/*//'Habilitar log de usu�rios'*/
cTexto += 'KpiParametrosSistema_00004='+STR0443+CRLF/*//'Mostrar projetos finalizados durante:'*/
cTexto += 'KpiParametrosSistema_00005='+STR0444+CRLF/*//'dias.'*/
cTexto += 'KpiParametrosSistema_00006='+STR0335+CRLF/*//'Logs'*/
cTexto += 'KpiParametrosSistema_00007='+STR0220+CRLF/*//'Planilha de valores'*/
cTexto += 'KpiParametrosSistema_00008='+STR0482+CRLF/*//'Alterar valores do indicador a partir de:'*/
cTexto += 'KpiParametrosSistema_00009='+STR0483+CRLF/*//'Exce��es''*/
cTexto += 'KpiParametrosSistema_00010='+STR0484+CRLF/*//'N�mero de dias a vencer para Planos de A��es:'*/
cTexto += 'KpiParametrosSistema_00011='+STR0485+CRLF/*//'Habilitar valor pr�vio de indicadores'*/
cTexto += 'KpiParametrosSistema_00012='+STR0497+CRLF/*//'Habilitar altera��o da data final dos Planos de A��es'*/
cTexto += 'KpiParametrosSistema_00013='+STR0514+CRLF/*//'Somente respons�veis geram Apresenta��es'*/  
cTexto += 'KpiParametrosSistema_00014='+STR0528+CRLF/*//'Bloquear altera��o de valores quando o indicador possuir f�rmula'*/
cTexto += 'KpiParametrosSistema_00015='+STR0530+CRLF/*//'Ordem padr�o do ScoreCarding:'*/
cTexto += 'KpiParametrosSistema_00016='+cTextScor+CRLF
cTexto += 'KpiParametrosSistema_00017='+STR0545+CRLF/*//'Usu�rio'*/
cTexto += 'KpiParametrosSistema_00018='+STR0538+CRLF/*//'Real'*/
cTexto += 'KpiParametrosSistema_00019='+STR0184+CRLF/*//'Meta'*/
cTexto += 'KpiParametrosSistema_00020='+STR0476+CRLF/*//'Pr�via'*/       
cTexto += 'KpiParametrosSistema_00021='+STR0546+CRLF/*//'a partir de:'*/       
cTexto += 'KpiParametrosSistema_00022='+STR0547+CRLF/*//'at�:'*/       
cTexto += 'KpiParametrosSistema_00023='+STR0548+CRLF/*//'Alterar valores dos indicadores'*/       
cTexto += 'KpiParametrosSistema_00024='+STR0560+CRLF/*//'Utilizar como padr�o para data alvo o m�s anterior.'*/       
cTexto += 'KpiParametrosSistema_00025='+STR0586+CRLF/*//'Incluir obrigatoriamente na apresenta��o, indicadores que n�o atingiram a meta.'*/       
cTexto += 'KpiParametrosSistema_00026='+STR0609+CRLF/*//'Ao incluir plano de a��o, notificar o respons�vel por e-mail'*/       
cTexto += 'KpiParametrosSistema_00027='+STR0610+CRLF/*//'Restri��o de Acesso'*/       
cTexto += 'KpiParametrosSistema_00028='+STR0611+CRLF/*//'Restri��o por hor�rio'*/       
cTexto += 'KpiParametrosSistema_00029='+STR0612+CRLF/*//'Permitir o uso da ferramenta somente nos hor�rios:'*/       
cTexto += 'KpiParametrosSistema_00030='+STR0613+CRLF/*//'De'*/       
cTexto += 'KpiParametrosSistema_00031='+STR0614+CRLF/*//'At�'*/       
cTexto += 'KpiParametrosSistema_00032='+STR0615+CRLF/*//'Restri��o por IP'*/       
cTexto += 'KpiParametrosSistema_00033='+STR0616+CRLF/*//'Liberar acesso apenas para endere�os IP confi�veis:'*/       
cTexto += 'KpiParametrosSistema_00034='+STR0617+CRLF/*//'Per�odo para restri��o de acesso inv�lido.'*/       
cTexto += 'KpiParametrosSistema_00035='+STR0618+CRLF/*//'Endere�o IP'*/       
cTexto += 'KpiParametrosSistema_00036='+STR0033+CRLF/*//'Descri��o'*/       
cTexto += 'KpiParametrosSistema_00037='+STR0627+CRLF/*//'Somente respons�veis pelo departamento, indicador e coleta alteram planilha de valores'*/       
cTexto += 'KpiParametrosSistema_00038='+STR0647+CRLF/*//'Endere�o WSDL de integra��o com o DW:'*/
cTexto += 'KpiParametrosSistema_00039='+STR0666+CRLF/*//'Intervalo do refresh do scorecarding'*/
cTexto += 'KpiParametrosSistema_00040='+STR0667+CRLF/*//'minutos.'*/                         
cTexto += 'KpiParametrosSistema_00041='+cTextScor+CRLF
cTexto += 'KpiParametrosSistema_00042='+STR0221+CRLF/*//'Indicador'*/
cTexto += 'KpiParametrosSistema_00043='+STR0161+CRLF/*//'A��o'*/
cTexto += 'KpiParametrosSistema_00044='+STR0457+CRLF/*//'Apresenta��o'*/    
cTexto += 'KpiParametrosSistema_00045='+STR0670+CRLF/*//'Configura��es Gerais'*/
cTexto += 'KpiParametrosSistema_00046='+STR0671+CRLF/*//'casas decimais.'*/
cTexto += 'KpiParametrosSistema_00047='+STR0672+CRLF/*//'No campo varia��o(Percentual) exibir:'*/
cTexto += 'KpiParametrosSistema_00048='+STR0673+CRLF/*//'Exibir valores em percentual no campo varia��o'*/
cTexto += 'KpiParametrosSistema_00049='+STR0692+CRLF/*//'Utilizar como padr�o para o per�odo acumulado de Janeiro at� a data alvo'*/
cTexto += 'KpiParametrosSistema_00050='+STR0130+CRLF/*//'Configura��es'*/
cTexto += 'KpiParametrosSistema_00051='+STR0736+CRLF/*//'Ocultar departamentos que o usu�rio n�o possui acesso'*/
cTexto += 'KpiParametrosSistema_00052='+STR0741+CRLF/*//'Exibir coluna Unidade de Medida'*/
cTexto += 'KpiParametrosSistema_00053='+STR0740+CRLF/*//'Exibir coluna de per�odo'*/
cTexto += 'KpiParametrosSistema_00054='+STR0993+CRLF/*//'Habilitar auditoria da meta e notifica�ao via e-mail'*/
//Obs> Continua KPIINTCONT.PRW
      
//Gera��o da Planilha de Planos de A��o
cTexto += 'KpiExportPlan_00001='+STR0322+CRLF/*//'Gerar'*/
cTexto += 'KpiExportPlan_00002='+STR0128+CRLF/*//'Atualizar'*/
cTexto += 'KpiExportPlan_00003='+STR0432+CRLF/*//'Gera��o da Planilha'*/
cTexto += 'KpiExportPlan_00004='+STR0321+CRLF/*//'Situa��o:'*/
cTexto += 'KpiExportPlan_00005='+STR0171+CRLF/*//'Status:'*/
cTexto += 'KpiExportPlan_00006='+STR0162+CRLF/*//'Respons�veis:'*/
cTexto += 'KpiExportPlan_00007='+STR0539+CRLF/*//'Tipo:'*/
cTexto += 'KpiExportPlan_00008='+STR0797+CRLF/*//'Gerar Planilha de Planos de A��o'*/

//Gera��o da Planilha de Importa��o
cTexto += 'KpiGeraPlanilha_00001='+STR0322+CRLF/*//'Gerar'*/
cTexto += 'KpiGeraPlanilha_00002='+STR0128+CRLF/*//'Atualizar'*/
cTexto += 'KpiGeraPlanilha_00003='+STR0432+CRLF/*//'Gera��o da Planilha'*/
cTexto += 'KpiGeraPlanilha_00004='+STR0433+CRLF/*//'Per�odo De:'*/
cTexto += 'KpiGeraPlanilha_00005='+STR0434+CRLF/*//'Per�odo At�:'*/
cTexto += 'KpiGeraPlanilha_00006='+STR0343+CRLF/*//'Pasta de Origem:'*/
cTexto += 'KpiGeraPlanilha_00007='+STR0435+CRLF/*//'Ordem'*/
cTexto += 'KpiGeraPlanilha_00008='+STR0436+CRLF/*//'Id do Indicador'*/
cTexto += 'KpiGeraPlanilha_00009='+STR0437+CRLF/*//'C�digo do Cliente'*/
cTexto += 'KpiGeraPlanilha_00010='+STR0438+CRLF/*//'Nome do Indicador'*/
cTexto += 'KpiGeraPlanilha_00011='+STR0439+CRLF/*//'Scorecards:'*/
cTexto += 'KpiGeraPlanilha_00012='+STR0440+CRLF/*//'Gerar Planilha para a Importa��o'*/
cTexto += 'KpiGeraPlanilha_00013='+STR0458+CRLF/*//'Deseja abrir a planilha gerada?'*/
cTexto += 'KpiGeraPlanilha_00014='+STR0481+CRLF/*//'Exportar valores?'*/
cTexto += 'KpiGeraPlanilha_00015='+STR0531+CRLF/*//'Indicador sem f�rmula'	*/
cTexto += 'KpiGeraPlanilha_00016='+STR0532+CRLF/*//'Indicador com f�rmula'*/
cTexto += 'KpiGeraPlanilha_00017='+STR0533+CRLF/*//'Ambos'*/
cTexto += 'KpiGeraPlanilha_00018='+STR0534+CRLF/*//'Exportar:'*/
cTexto += 'KpiGeraPlanilha_00019='+STR0579+CRLF/*//'Tipo de Atualiza��o:'*/   
cTexto += 'KpiGeraPlanilha_00020='+STR0601+CRLF/*//'Gerar ou Importar'*/   
cTexto += 'KpiGeraPlanilha_00021='+STR0602+CRLF/*//'Importa��o da Planilha'*/   
cTexto += 'KpiGeraPlanilha_00022='+STR0550+CRLF/*//'Upload'*/   
cTexto += 'KpiGeraPlanilha_00023='+STR0114+CRLF/*//'Excluir'*/   
cTexto += 'KpiGeraPlanilha_00024='+STR0669+CRLF/*//'Importar Todos'*/   
cTexto += 'KpiGeraPlanilha_00025='+STR0335+CRLF/*//'Logs'*/   
cTexto += 'KpiGeraPlanilha_00026='+STR0593+CRLF/*//'Nome'*/   
cTexto += 'KpiGeraPlanilha_00027='+STR0106+CRLF/*//'Data'*/   
cTexto += 'KpiGeraPlanilha_00028='+STR0105+CRLF/*//'Tamanho'*/   
cTexto += 'KpiGeraPlanilha_00029='+STR0603+CRLF/*//'Arquivos'*/   
cTexto += 'KpiGeraPlanilha_00030='+STR0604+CRLF/*//'"Selecionar'*/   
cTexto += 'KpiGeraPlanilha_00031='+STR0605+CRLF/*//'"Selecionar Planilha'*/   

//Gera��o do Relat�rio de Estat�stica de Planos de A��es
cTexto += 'KpiRelEstatPlan_00001='+STR0446+CRLF/*//'Relat�rio com Estat�sticas de Planos de A��es'*/
cTexto += 'KpiRelEstatPlan_00002='+STR0118+CRLF/*//'Nome:'*/
cTexto += 'KpiRelEstatPlan_00003='+STR0131+CRLF/*//'Descri��o:'*/
cTexto += 'KpiRelEstatPlan_00004='+STR0312+CRLF/*//'Imprime Descri��o?'*/
cTexto += 'KpiRelEstatPlan_00005='+STR0447+CRLF/*//'Filtro'*/
cTexto += 'KpiRelEstatPlan_00006='+STR0322+CRLF/*//'Gerar'*/
cTexto += 'KpiRelEstatPlan_00007='+STR0112+CRLF/*//'Visualizar'*/
cTexto += 'KpiRelEstatPlan_00008='+STR0117+CRLF/*//'Gravar'*/
cTexto += 'KpiRelEstatPlan_00009='+STR0139+CRLF/*//'Abrir'*/

//Indicador Card
cTexto += 'KpiIndicadorCard_00001='+STR0448+CRLF/*//'Acumulado'*/
cTexto += 'KpiIndicadorCard_00002='+STR0449+CRLF/*//'Parcelado'*/
cTexto += 'KpiIndicadorCard_00003='+STR0450+CRLF/*//'Diferen�a:'*/
cTexto += 'KpiIndicadorCard_00004='+STR0282+CRLF/*//'Lista de plano de acoes'*/
cTexto += 'KpiIndicadorCard_00005='+STR0454+CRLF/*//'Meta:'*/

//Lista de acoes por scorecard
cTexto += 'KpiListaStatusAcoes_00001='+STR0282+CRLF/*//'Lista de Plano de A��es'*/

//Apresenta��es
cTexto += 'KpiApresentacao_00001='+STR0455+CRLF/*//'Relat�rio de Apresenta��es'*/
cTexto += 'KpiApresentacao_00002='+STR0456+CRLF/*//'Apresenta��es'*/
cTexto += 'KpiApresentacao_00003='+STR0457+CRLF/*//'Apresenta��o'*/
cTexto += 'KpiApresentacao_00004='+STR0118+CRLF/*//'Nome:'*/
cTexto += 'KpiApresentacao_00005='+STR0131+CRLF/*//'Descri��o:'*/
cTexto += 'KpiApresentacao_00006='+STR0319+CRLF/*//'In�cio de:'*/
cTexto += 'KpiApresentacao_00007='+STR0271+CRLF/*//'At�:'*/
cTexto += 'KpiApresentacao_00008='+STR0275+CRLF/*//'Data Alvo:'*/
cTexto += 'KpiApresentacao_00009='+STR0178+CRLF/*//'Scorecard:'*/
cTexto += 'KpiApresentacao_00010='+STR0174+CRLF/*//'Planos de A��es'*/
cTexto += 'KpiApresentacao_00011='+STR0135+CRLF/*//'Indicadores'*/
cTexto += 'KpiApresentacao_00012='+STR0470+CRLF/*//'Indicador X Scorecard'*/
cTexto += 'KpiApresentacao_00013='+STR0471+CRLF/*//'Plano de A��o X Scorecard'*/
cTexto += 'KpiApresentacao_00014='+STR0472+CRLF/*//'Projeto X Scorecard'*/
cTexto += 'KpiApresentacao_00015='+STR0473+CRLF/*//'Selecione o Scorecard'*/
cTexto += 'KpiApresentacao_00016='+STR0139+CRLF/*//'Abrir'*/ 
cTexto += 'KpiApresentacao_00017='+STR0552+CRLF/*//'Dados Gerais'*/ 
cTexto += 'KpiApresentacao_00018='+STR0553+CRLF/*//'T�picos'*/
cTexto += 'KpiApresentacao_00019='+STR0554+CRLF/*//'T�picos:'*/
cTexto += 'KpiApresentacao_00020='+STR0583+CRLF/*//'Todos indicadores que n�o atingiram  a  meta, foram'*/
cTexto += 'KpiApresentacao_00021='+STR0584+CRLF/*//'selecionados automaticamente pelo administrador  do'*/
cTexto += 'KpiApresentacao_00022='+STR0585+CRLF/*//'sistema, e n�o poder�o ser removidos.'*/
cTexto += 'KpiApresentacao_00023='+STR0986+CRLF/*//'Informe o Nome do Relat�rio de Apresenta��o'*/

//Fonte de Dados
cTexto += 'KpiDataSourceFrame_00001='+STR0498+CRLF/*//'"Fonte de Dados"'*/
cTexto += 'KpiDataSourceFrame_00002='+STR0118+CRLF/*//'"Nome:"'*/
cTexto += 'KpiDataSourceFrame_00003='+STR0131+CRLF/*//'"Descricao:"'*/
cTexto += 'KpiDataSourceFrame_00004='+STR0499+CRLF/*//'"Classe:"'*/
cTexto += 'KpiDataSourceFrame_00005='+STR0500+CRLF/*//'"Agendamento:"'*/
cTexto += 'KpiDataSourceFrame_00006='+STR0501+CRLF/*//'"Executar c�lculo ao final?"'*/
cTexto += 'KpiDataSourceFrame_00007='+STR0502+CRLF/*//'"Principal"'*/
cTexto += 'KpiDataSourceFrame_00008='+STR0503+CRLF/*//'"Top DataBase:"'*/
cTexto += 'KpiDataSourceFrame_00009='+STR0337+CRLF/*//'"Ambiente:"'*/
cTexto += 'KpiDataSourceFrame_00010='+STR0504+CRLF/*//'"Top Alias:"'*/
cTexto += 'KpiDataSourceFrame_00011='+STR0505+CRLF/*//'"Top Server:"'*/
cTexto += 'KpiDataSourceFrame_00012='+STR0506+CRLF/*//'"Utilizar o seguinte ambiente do servidor Protheus"'*/
cTexto += 'KpiDataSourceFrame_00013='+STR0507+CRLF/*//'"Utilizar a seguinte conex�o Top Connect"'*/
cTexto += 'KpiDataSourceFrame_00014='+STR0508+CRLF/*//'"Top Contype:"'*/
cTexto += 'KpiDataSourceFrame_00015='+STR0509+CRLF/*//'"Testar conex�o"'*/
cTexto += 'KpiDataSourceFrame_00016='+STR0510+CRLF/*//'"Configura��es"'*/
cTexto += 'KpiDataSourceFrame_00017='+STR0511+CRLF/*//'"Declara��es"'*/
cTexto += 'KpiDataSourceFrame_00018='+STR0512+CRLF/*//'"Testar sintaxe"'*/
cTexto += 'KpiDataSourceFrame_00019='+STR0509+CRLF/*//'"Testar conexao"'*/ 
cTexto += 'KpiDataSourceFrame_00020='+STR0513+CRLF/*//'"Importar"'*/ 
cTexto += 'KpiDataSourceFrame_00021='+STR0178+CRLF/*//'ScoreCard:'*/
cTexto += 'KpiDataSourceFrame_00022='+STR0332+CRLF/*//'Calcular de:'*/
cTexto += 'KpiDataSourceFrame_00023='+STR0271+CRLF/*//'At�'*/
cTexto += 'KpiDataSourceFrame_00024='+STR0337+CRLF/*//'Ambiente:'*/
cTexto += 'KpiDataSourceFrame_00025='+STR0517+CRLF/*//'Servidor:'*/ 
cTexto += 'KpiDataSourceFrame_00026='+STR0518+CRLF/*//'Porta:'*/ 
cTexto += 'KpiDataSourceFrame_00027='+STR0519+CRLF/*//'Empresa:'*/ 
cTexto += 'KpiDataSourceFrame_00028='+STR0520+CRLF/*//'Filial:'*/  
cTexto += 'KpiDataSourceFrame_00029='+STR0521+CRLF/*//'Tipo Comunica��o:'*/ 
cTexto += 'KpiDataSourceFrame_00030='+STR0522+CRLF/*//'Fonte:'*/ 
cTexto += 'KpiDataSourceFrame_00031='+STR0523+CRLF/*//'"Declara��es:"'*/ 
cTexto += 'KpiDataSourceFrame_00032='+STR0363+CRLF/*//'"Exportar"'*/ 
cTexto += 'KpiDataSourceFrame_00033='+STR0139+CRLF/*//'"Exportar"'*/
cTexto += 'KpiDataSourceFrame_00034='+STR0525+CRLF/*//'"Nome da Fun��o (ADVPL):"'*/ 
cTexto += 'KpiDataSourceFrame_00035='+STR0526+CRLF/*//'"Consulta (Select):"'*/
cTexto += 'KpiDataSourceFrame_00036='+STR0135+CRLF/*//' "Indicadores"'*/
cTexto += 'KpiDataSourceFrame_00037='+STR0648+CRLF/*//' "Endere�o do DW:"'*/
cTexto += 'KpiDataSourceFrame_00038='+STR0649+CRLF/*//' "Consultas:"'*/
cTexto += 'KpiDataSourceFrame_00039='+STR0650+CRLF/*//' "Data:"'*/
cTexto += 'KpiDataSourceFrame_00040='+STR0221+CRLF/*//' "Indicador"'*/
cTexto += 'KpiDataSourceFrame_00041='+STR0651+CRLF/*//' "Importar:"'*/
cTexto += 'KpiDataSourceFrame_00042='+STR0476+CRLF/*//' "Pr�via"'*/
cTexto += 'KpiDataSourceFrame_00043='+STR0184+CRLF/*//' "Meta"'*/
cTexto += 'KpiDataSourceFrame_00044='+STR0538+CRLF/*//' "Real"'*/
cTexto += 'KpiDataSourceFrame_00045='+STR0509+CRLF/*//' "Testar conex�o"'*/
cTexto += 'KpiDataSourceFrame_00046='+STR0134+CRLF/*//' "Indicador:"'*/
cTexto += 'KpiDataSourceFrame_00047='+STR0731+CRLF/*//' "Preparar ambiente antes de executar a fun��o"'*/
cTexto += 'KpiDataSourceFrame_00048='+STR0792+CRLF/*//' "IMPORTANTE"'*/
cTexto += 'KpiDataSourceFrame_00049='+STR0793+CRLF/*//' "Os valores n�o poder�o conter separador de milhares"'*/
cTexto += 'KpiDataSourceFrame_00050='+STR0794+CRLF/*//' "Formato da data dever� ser yyyymmdd"'*/
cTexto += 'KpiDataSourceFrame_00051='+STR0795+CRLF/*//' "Campo PREVIA � opcional"'*/
cTexto += 'KpiDataSourceFrame_00052='+STR0796+CRLF/*//' "Caso o campo ID e USERID sejam informados prevalecer� o campo USERID"'*/

//Ordem dos Indicadores
cTexto += 'kpiOrdemIndicador_00001='+STR0540+CRLF/*//'"Ordem dos Indicadores"'*/
cTexto += 'kpiOrdemIndicador_00002='+STR0541+CRLF/*//'"Ordem de visualiza��o dos indicadores no Scorecarding:"'*/
cTexto += 'kpiOrdemIndicador_00003='+STR0542+CRLF/*//'"Acima"'*/
cTexto += 'kpiOrdemIndicador_00004='+STR0543+CRLF/*//'"Abaixo"'*/

//Lista de Grupo de A��es                                                       
cTexto += 'KpiListaGrupoAcao_00001='+STR0555+CRLF/*//'"Plano de A��o"'*/
cTexto += 'KpiListaGrupoAcao_00002='+STR0668+CRLF/*//'"Total de a��es"'*/

//Cadastro de Grupo de A��es
cTexto += 'KpiGrupoAcao_00001='+STR0555+CRLF/*//'"Plano de A��o"'*/
cTexto += 'KpiGrupoAcao_00002='+STR0555+CRLF/*//'"Plano de A��o"'*/
cTexto += 'KpiGrupoAcao_00003='+STR0397+CRLF/*//'"Plano de A��o:"'*/
cTexto += 'KpiGrupoAcao_00004='+STR0125+CRLF/*//'"Respons�vel:"'*/
cTexto += 'KpiGrupoAcao_00005='+STR0131+CRLF/*//'"Descri��o:"'*/
cTexto += 'KpiGrupoAcao_00006='+STR0816+CRLF/*//'"A��o de Indicadores"'*/

//Lista de Paineis Comparativos                                                    
cTexto += 'KpiListaPainelComp_00001='+STR0575+CRLF/*//'"Pain�is Comparativos"'*/

//Cadastro de Paineis Comparativos
cTexto += 'KpiPainelComp_00001='+STR0575+CRLF/*//'"Pain�is Comparativos"'*/
cTexto += 'KpiPainelComp_00002='+STR0269+CRLF/*//'"Painel:"'*/
cTexto += 'KpiPainelComp_00003='+STR0131+CRLF/*//'"Descri��o:"'*/
cTexto += 'KpiPainelComp_00004='+STR0178+CRLF/*//'"Departamento:"'*/
cTexto += 'KpiPainelComp_00005='+STR0134+CRLF/*//'"Indicador:"'*/
cTexto += 'KpiPainelComp_00006='+STR0270+CRLF/*//'"Acumulado de:"'*/
cTexto += 'KpiPainelComp_00007='+STR0271+CRLF/*//'"At�:"'*/
cTexto += 'KpiPainelComp_00008='+STR0004+CRLF/*//'"Adicionar"'*/
cTexto += 'KpiPainelComp_00009='+STR0576+CRLF/*//'"Ocultar Varia��o"'*/
cTexto += 'KpiPainelComp_00010='+STR0577+CRLF/*//'"Op��es de an�lise"'*/   
cTexto += 'KpiPainelComp_00011='+STR0646+CRLF/*//'"Ocultar Acumulado"'*/   
cTexto += 'KpiPainelComp_00012='+STR0742+CRLF //'Ocultar Real Acumulado'
cTexto += 'KpiPainelComp_00013='+STR0743+CRLF //'Ocultar Meta Acumulada'  
cTexto += 'KpiPainelComp_00014='+STR0791+CRLF //'Paineis'  

//Indicadore Paineis Comparativos
cTexto += 'KpiIndicadorTable_00001='+STR0221+CRLF/*//'"Indicador"'*/
cTexto += 'KpiIndicadorTable_00002='+STR0161+CRLF/*//'"A��o"'*/
cTexto += 'KpiIndicadorTable_00003='+STR0276+CRLF/*//'"Gr�ficos"'*/

//kpiUIManeger
cTexto += 'kpiUIManeger_00001='+STR0587+CRLF/*//'"Examinar"'*/
cTexto += 'kpiUIManeger_00002='+STR0588+CRLF/*//'"Salvar em"'*/
cTexto += 'kpiUIManeger_00003='+STR0108+CRLF/*//'"Nome do arquivo"'*/
cTexto += 'kpiUIManeger_00004='+STR0564+CRLF/*//'"Tipo"'*/
cTexto += 'kpiUIManeger_00005='+STR0589+CRLF/*//'"Um n�vel acima"'*/
cTexto += 'kpiUIManeger_00006='+STR0127+CRLF/*//'"Desktop"'*/
cTexto += 'kpiUIManeger_00007='+STR0590+CRLF/*//'"Criar nova pasta"'*/
cTexto += 'kpiUIManeger_00008='+STR0591+CRLF/*//'"Lista"'*/
cTexto += 'kpiUIManeger_00009='+STR0592+CRLF/*//'"Detalhes"'*/
cTexto += 'kpiUIManeger_00010='+STR0593+CRLF/*//'"Nome"'*/
cTexto += 'kpiUIManeger_00011='+STR0105+CRLF/*//'"Tamanho"'*/
cTexto += 'kpiUIManeger_00012='+STR0106+CRLF/*//'"Data"'*/
cTexto += 'kpiUIManeger_00013='+STR0594+CRLF/*//'"Atributos"'*/
cTexto += 'kpiUIManeger_00014='+STR0116+CRLF/*//'"Cancelar"'*/

//Upload de arquivos
cTexto += 'KpiUpload_00001='+STR0595+CRLF/*//'"Conectando..."'*/
cTexto += 'KpiUpload_00002='+STR0596+CRLF/*//'"Fechar essa caixa de dialogo quando o upload for conclu�do"'*/
cTexto += 'KpiUpload_00003='+STR0597+CRLF/*//'"Fazendo o upload de: "'*/
cTexto += 'KpiUpload_00004='+STR0598+CRLF/*//'"Tamanho do arquivo: "'*/
cTexto += 'KpiUpload_00005='+STR0116+CRLF/*//'"Cancelar"'*/
cTexto += 'KpiUpload_00006='+STR0599+CRLF/*//'"Cancelando Upload"'*/
cTexto += 'KpiUpload_00007='+STR0600+CRLF/*//'"%  SGI - Upload conclu�do"'*/
cTexto += 'KpiUpload_00008='+STR0292+CRLF/*//'"Fechar"'*/
cTexto += 'KpiUpload_00009='+STR0606+CRLF/*//'"Aguarde ..."'*/
cTexto += 'KpiUpload_00010='+STR0607+CRLF/*//'"Cancelando ..."'*/
cTexto += 'KpiUpload_00011='+STR0608+CRLF/*//'"Upload conclu�do"'*/

//Pacotes
cTexto += 'KpiPacote_00001='+STR0619+CRLF/*//'"Pacote"'*/
cTexto += 'KpiPacote_00002='+STR0118+CRLF/*//'"Nome:"'*/
cTexto += 'KpiPacote_00003='+STR0131+CRLF/*//'"Descri��o:"'*/
cTexto += 'KpiPacote_00004='+STR0141+CRLF/*//'"Grupo de Indicadores"'*/
cTexto += 'KpiPacote_00005='+cTextScor+CRLF
cTexto += 'KpiPacote_00006='+STR0545+CRLF/*//'"Usu�rio"'*/      
cTexto += 'KpiPacote_00007='+cTextScor+CRLF
cTexto += 'KpiPacote_00008='+STR0245+CRLF/*//'"Nome n�o informado!"'*/
cTexto += 'KpiPacote_00009='+STR0621+CRLF/*//'"Cadastro de Pacotes"'*/

//Lista de Pacotes
cTexto += 'KpiListaPacote_00001='+STR0620+CRLF/*//'"Pacotes"'*/

//Lista Espinha de Peixe 
cTexto += 'KpiEspinhaPeixeLista_00001='+STR0631+CRLF/*//'"Espinha de Peixe"'*/
 
//Cadastro Espinha de Peixe 
cTexto += 'KpiEspinhaPeixeCadastro_00001='+STR0631+CRLF/*//'"Espinha de Peixe"'*/
cTexto += 'KpiEspinhaPeixeCadastro_00002='+STR0632+CRLF/*//'"Anomalia"'*/
cTexto += 'KpiEspinhaPeixeCadastro_00003='+STR0633+CRLF/*//'"An�lise"'*/
cTexto += 'KpiEspinhaPeixeCadastro_00004='+STR0118+CRLF/*//'"Nome:"'*/
cTexto += 'KpiEspinhaPeixeCadastro_00005='+STR0178+CRLF/*//'"Departamento:"'*/
cTexto += 'KpiEspinhaPeixeCadastro_00006='+STR0134+CRLF/*//'"Indicador:"'*/
cTexto += 'KpiEspinhaPeixeCadastro_00007='+STR0131+CRLF/*//'"Descri��o:"'*/
cTexto += 'KpiEspinhaPeixeCadastro_00008='+STR0111+CRLF/*//'"Novo"'*/
cTexto += 'KpiEspinhaPeixeCadastro_00009='+STR0161+CRLF/*//'"A��o"'*/
cTexto += 'KpiEspinhaPeixeCadastro_00010='+STR0634+CRLF/*//'"Espinha de Peixe:"'*/
cTexto += 'KpiEspinhaPeixeCadastro_00011='+STR0140+CRLF/*//'"Procurar"'*/
cTexto += 'KpiEspinhaPeixeCadastro_00012='+STR0635+CRLF/*//'"Visualizar Plano de A��o"'*/
cTexto += 'KpiEspinhaPeixeCadastro_00013='+STR0636+CRLF/*//'"Voc� n�o pode mover um objeto do tipo Efeito."'*/    
cTexto += 'KpiEspinhaPeixeCadastro_00014='+STR0644+CRLF/*//'"O texto n�o pode conter caracteres:"'*/
cTexto += 'KpiEspinhaPeixeCadastro_00015='+STR0785+CRLF/*//'"Nova Causa"'*/
cTexto += 'KpiEspinhaPeixeCadastro_00016='+STR0786+CRLF/*//'"Novo Efeito"'*/  
cTexto += 'KpiEspinhaPeixeCadastro_00017='+STR0787+CRLF/*//'"Causa"'*/
cTexto += 'KpiEspinhaPeixeCadastro_00018='+STR0788+CRLF/*//'"Efeito"'*/ 
cTexto += 'KpiEspinhaPeixeCadastro_00019='+STR0798+CRLF/*//'A causa deve ser gravada antes de incluir uma a��o.'*/

//Espinha de Peixe Relat�rio
cTexto += 'KpiEspinhaPeixeRel_00001='+STR0631+CRLF/*//'"Espinha de Peixe"'*/
cTexto += 'KpiEspinhaPeixeRel_00002='+STR0128+CRLF/*//'"Atualizar"'*/
cTexto += 'KpiEspinhaPeixeRel_00003='+STR0363+CRLF/*//'"Exportar"'*/
cTexto += 'KpiEspinhaPeixeRel_00004='+STR0139+CRLF/*//'"Abrir"'*/
cTexto += 'KpiEspinhaPeixeRel_00005='+STR0637+CRLF/*//'"Zoom:"'*/
cTexto += 'KpiEspinhaPeixeRel_00006='+STR0563+CRLF/*//'"Legenda:"'*/
cTexto += 'KpiEspinhaPeixeRel_00007='+STR0638+CRLF/*//'"Sub Efeito"'*/
cTexto += 'KpiEspinhaPeixeRel_00008='+STR0639+CRLF/*//'"Causa com Plano de A��o"'*/
cTexto += 'KpiEspinhaPeixeRel_00009='+STR0640+CRLF/*//'"Causa sem Plano de A��o"'*/
cTexto += 'KpiEspinhaPeixeRel_00010='+STR0131+CRLF/*//'"Descri��o:"'*/
cTexto += 'KpiEspinhaPeixeRel_00011='+STR0641+CRLF/*//'"O n�mero deve estar entre 30 e 200."'*/
cTexto += 'KpiEspinhaPeixeRel_00012='+STR0642+CRLF/*//'"Esta n�o � uma medida v�lida."'*/
cTexto += 'KpiEspinhaPeixeRel_00013='+STR0643+CRLF/*//'"N�o exite plano de a��o cadastrado para essa causa."'*/
cTexto += 'KpiEspinhaPeixeRel_00014='+STR0645+CRLF/*//'"Efeito Principal"'*/

//Integracao SGI com o DW
cTexto += 'KpiConsultaDW_00001='+STR0662+CRLF/*//' "Consultas do DW"'*/
cTexto += 'KpiConsultaDW_00002='+STR0112+CRLF/*//' "Visualizar"'*/
cTexto += 'KpiConsultaDW_00003='+STR0765+CRLF/*//' "Visualiza��o em:"'*/		
cTexto += 'KpiConsultaDW_00004='+STR0655+CRLF/*//' "Tabela"'*/
cTexto += 'KpiConsultaDW_00005='+STR0656+CRLF/*//' "Gr�fico"'*/
cTexto += 'KpiConsultaDW_00006='+STR0660+CRLF/*//' "Por favor selecione uma consulta."'*/

//Altera��o de imagens
cTexto += 'KpiChangeImage_00001='+STR0677+CRLF/*//' "Alterar Imagem"'*/
cTexto += 'KpiChangeImage_00002='+STR0678+CRLF/*//' "Selecione o arquivo que ir� substituir a imagem atual e selecione ok."'*/
cTexto += 'KpiChangeImage_00003='+STR0679+CRLF/*//' "Este arquivo deve ser do tipo GIF (*.gif) e recomendamos que possua as"'*/
cTexto += 'KpiChangeImage_00004='+STR0680+CRLF/*//' "medidas de 232x62 (ou proporcional) no tamnaho m�ximo de 50Kbytes."'*/
cTexto += 'KpiChangeImage_00005='+STR0681+CRLF/*//' "Para que atualiza��o tenha efeito � necess�rio reinicar o browser."'*/
cTexto += 'KpiChangeImage_00006='+STR0682+CRLF/*//' "Imagem (*.gif)"'*/
cTexto += 'KpiChangeImage_00007='+STR0263+CRLF/*//' "Ok"'*/
cTexto += 'KpiChangeImage_00008='+STR0683+CRLF/*//' "Restaurar Padr�o"'*/
cTexto += 'KpiChangeImage_00009='+STR0116+CRLF/*//' "Cancelar"'*/
cTexto += 'KpiChangeImage_00010='+STR0684+CRLF/*//' "Arquivo de permiss�o n�o encontrado. Deseja salvar o arquivo?"'*/
cTexto += 'KpiChangeImage_00011='+STR0685+CRLF/*//' "A imagem deve conter no m�ximo 50Kbytes."'*/
cTexto += 'KpiChangeImage_00012='+STR0686+CRLF/*//' "Imagem n�o localizada."'*/
cTexto += 'KpiChangeImage_00013='+STR0687+CRLF/*//' "Acesso negado."'*/

//Exporta��o de Metadados
cTexto += 'KpiEstruturaExport_00001='+STR0716+CRLF/*//' "Estrutura"'*/
cTexto += 'KpiEstruturaExport_00002='+STR0252+CRLF/*//' "Iniciar"'*/
cTexto += 'KpiEstruturaExport_00003='+STR0363+CRLF/*//' "Exportar"'*/
cTexto += 'KpiEstruturaExport_00004='+cTextScor+CRLF
cTexto += 'KpiEstruturaExport_00005='+STR0717+CRLF/*//' "Nome do Arquivo:"'*/
cTexto += 'KpiEstruturaExport_00006='+STR0029+CRLF/*//' "Mensagem"'*/    
cTexto += 'KpiEstruturaExport_00007='+STR0718+CRLF/*//' "Campo departamento obrigat�rio"'*/    
cTexto += 'KpiEstruturaExport_00008='+STR0719+CRLF/*//' "Campo nome do arquivo obrigat�rio"'*/    
cTexto += 'KpiEstruturaExport_00009='+STR0720+CRLF/*//' "Aguarde... Exportando"'*/    
cTexto += 'KpiEstruturaExport_00010='+STR0721+CRLF/*//' "Aguarde... Parando a exporta��o"'*/    
cTexto += 'KpiEstruturaExport_00011='+STR0722+CRLF/*//' "Opera��o finalizada. Verifique o arquivo de log para mais detalhes."'*/    
cTexto += 'KpiEstruturaExport_00012='+STR0723+CRLF/*//' "Pressione o bot�o iniciar, para exportar a estrutura."'*/    
cTexto += 'KpiEstruturaExport_00013='+STR0724+CRLF/*//' "N�o existem estruturas pr�-cadastradas para ser exportada."'*/    
cTexto += 'KpiEstruturaExport_00014='+STR0801+CRLF/*//' "Proteger Regra de Neg�cio."'*/    
cTexto += 'KpiEstruturaExport_00015='+STR0803+CRLF/*//' "Campo LicenseKey obrigat�rio"'*/    

//Importa��o de Metadados
cTexto += 'KpiEstruturaImport_00001='+STR0716+CRLF/*//' "Estrutura"'*/
cTexto += 'KpiEstruturaImport_00002='+STR0252+CRLF/*//' "Iniciar"'*/
cTexto += 'KpiEstruturaImport_00003='+STR0513+CRLF/*//' "Importar"'*/
cTexto += 'KpiEstruturaImport_00004='+STR0725+CRLF/*//' "Arquivo:"'*/
cTexto += 'KpiEstruturaImport_00005='+STR0592+CRLF/*//' "Detalhes"'*/
cTexto += 'KpiEstruturaImport_00006='+STR0598+CRLF/*//' "Tamanho do arquivo"'*/
cTexto += 'KpiEstruturaImport_00007='+STR0726+CRLF/*//' "Data de Modifica��o"'*/
cTexto += 'KpiEstruturaImport_00008='+STR0029+CRLF/*//' "Mensagem"'*/
cTexto += 'KpiEstruturaImport_00009='+STR0727+CRLF/*//' "Enquanto a estrutura estiver sendo importada, os dados apresentados no scorecarding podem ficar inconsistentes."'*/
cTexto += 'KpiEstruturaImport_00010='+STR0728+CRLF/*//' "Aguarde... Parando a importa��o"'*/
cTexto += 'KpiEstruturaImport_00011='+STR0729+CRLF/*//' "Selecione o arquivo com estrutura e pressione o bot�o iniciar, para importar os indicadores e departamentos. Opcionalmente, escolha um Scorecard para conter os indicadores e departamentos a serem importados."'*/
cTexto += 'KpiEstruturaImport_00012='+STR0730+CRLF/*//' "N�o existem estruturas pr�-cadastradas para ser importada."'*/
cTexto += 'KpiEstruturaImport_00013='+STR0804+CRLF/*//' "Departamento:"*/
cTexto += 'KpiEstruturaImport_00014='+STR0805+CRLF/*//' "Campo Arquivo obrigat�rio"*/

//Integra��o com DW        
cTexto += 'KpiConfDw_00001='+STR0759+CRLF/*//' "Conex�o com SIGADW"'*/
cTexto += 'KpiConfDw_00002='+STR0509+CRLF/*//' "Testar Conex�o"'*/
cTexto += 'KpiConfDw_00003='+STR0760+CRLF/*//' "Endere�o WSDL:"'*/
cTexto += 'KpiConfDw_00004='+STR0761+CRLF/*//' "URL Site:"'*/
cTexto += 'KpiConfDw_00005='+STR0150+CRLF/*//' "Usu�rio:"'*/
cTexto += 'KpiConfDw_00006='+STR0088+CRLF/*//' "Senha:"'*/
cTexto += 'KpiConfDw_00007='+STR0762+CRLF/*//' "Conex�o Ok"'*/

//Exibi��o da F�rmula de Indicadores
cTexto += 'KpiIndicadorFormula_00001='+STR0766+CRLF/*//' "F�rmula do Indicador"'*/
cTexto += 'KpiIndicadorFormula_00002='+STR0767+CRLF/*//' "Nome:"'*/
cTexto += 'KpiIndicadorFormula_00003='+STR0768+CRLF/*//' "Departamento:"'*/
cTexto += 'KpiIndicadorFormula_00004='+STR0769+CRLF/*//' "F�rmula:"'*/
cTexto += 'KpiIndicadorFormula_00005='+STR0770+CRLF/*//' "Valor Real:"'*/
cTexto += 'KpiIndicadorFormula_00006='+STR0771+CRLF/*//' "Valor Meta:"'*/
cTexto += 'KpiIndicadorFormula_00007='+STR0772+CRLF/*//' "Valor Real Acumulado:"'*/
cTexto += 'KpiIndicadorFormula_00008='+STR0773+CRLF/*//' "Valor Meta Acumulado:"'*/
cTexto += 'KpiIndicadorFormula_00009='+STR0774+CRLF/*//' "Valor Real Status:"'*/
cTexto += 'KpiIndicadorFormula_00010='+STR0775+CRLF/*//' "Valor Acumulado Status:"'*/
cTexto += 'KpiIndicadorFormula_00011='+STR0776+CRLF/*//' "Valor Pr�via:"'*/
cTexto += 'KpiIndicadorFormula_00012='+STR0802+CRLF/*//' "Tend�ncia:"'*/
                           
cTexto += 'KpiApplication_00001='+STR0838+CRLF/*//' "SGI-Sistema de Gest�o de Indicadores:"'*/ 

//KpiFormMatrix
cTexto += 'KpiFormMatrix_00001='+STR0853+CRLF/*//' "Cadastro de Entidades"'*/ 
cTexto += 'KpiFormMatrix_00002='+STR0854+CRLF/*//' "Por favor, selecione um item para duplicar."'*/ 
cTexto += 'KpiFormMatrix_00003='+STR0855+CRLF/*//' "Duplicador"'*/ 

//BscEntityType
cTexto += 'BscEntityType_00001='+STR0856+CRLF/*//' "Duplicador"'*/ 
cTexto += 'BscEntityType_00002='+STR0857+CRLF/*//' "Organiza��es"'*/ 
cTexto += 'BscEntityType_00003='+STR0858+CRLF/*//' "Perspectivas"'*/ 
cTexto += 'BscEntityType_00004='+STR0859+CRLF/*//' "Objetivos"'*/ 
cTexto += 'BscEntityType_00005='+STR0859+CRLF/*//' "Objetivos"'*/ 
cTexto += 'BscEntityType_00006='+STR0903+CRLF/*//' "Estrat�gia"'*/ 

//KpiEntrategia
cTexto += 'KpiEstrategia_00001='+STR0860+CRLF/*//'"Informe o Nome da Estrat�gia"'*/
cTexto += 'KpiEstrategia_00002='+STR0861+CRLF/*//'"Informe a Data Inicial"'*/
cTexto += 'KpiEstrategia_00003='+STR0862+CRLF/*//'"Informe a Data Final"'*/
cTexto += 'KpiEstrategia_00004='+STR0863+CRLF/*//'"Data Inicial n�o pode ser maior que a Data Final"'*/
cTexto += 'KpiEstrategia_00005='+STR0864+CRLF/*//'"Estrat�gia"'*/
cTexto += 'KpiEstrategia_00006='+STR0865+CRLF/*//'"Estrat�gia:"'*/
cTexto += 'KpiEstrategia_00007='+STR0866+CRLF/*//'"Descri��o:"'*/
cTexto += 'KpiEstrategia_00008='+STR0867+CRLF/*//'"In�cio:"'*/
cTexto += 'KpiEstrategia_00009='+STR0868+CRLF/*//'"Fim:"'*/    
cTexto += 'KpiEstrategia_00010='+STR0980+CRLF/*//'"Tema Estrat�gico"'*/    
 
//KpiObjetivo
cTexto += 'KpiObjetivo_00001='+STR0869+CRLF/*//'"Informe o Nome do Objetivo"'*/
cTexto += 'KpiObjetivo_00002='+STR0870+CRLF/*//'"Objetivo:"'*/
cTexto += 'KpiObjetivo_00003='+STR0871+CRLF/*//'"Informe o Respons�vel pelo Objetivo"'*/
cTexto += 'KpiObjetivo_00004='+STR0872+CRLF/*//'"Descri��o:"'*/
cTexto += 'KpiObjetivo_00005='+STR0873+CRLF/*//'"Respons�vel:"'*/
cTexto += 'KpiObjetivo_00006='+STR0905+CRLF/*//'"Origem:"'*/
cTexto += 'KpiObjetivo_00007='+STR0906+CRLF/*//'"Objetivo"'*/
                                                              
//KpiOrganizacao
cTexto += 'KpiOrganizacao_00001='+STR0874+CRLF/*//'"Organiza��o"'*/
cTexto += 'KpiOrganizacao_00002='+STR0875+CRLF/*//'"Organiza��o:"'*/
cTexto += 'KpiOrganizacao_00003='+STR0876+CRLF/*//'"Descri��o:"'*/
cTexto += 'KpiOrganizacao_00004='+STR0877+CRLF/*//'"Informe o Nome da Organiza��o"'*/
cTexto += 'KpiOrganizacao_00005='+STR0878+CRLF/*//'"Miss�o:"'*/
cTexto += 'KpiOrganizacao_00006='+STR0879+CRLF/*//'"Vis�o:"'*/
cTexto += 'KpiOrganizacao_00007='+STR0880+CRLF/*//'"Valores:"'*/
cTexto += 'KpiOrganizacao_00008='+STR0881+CRLF/*//'"Princ�pios:"'*/
cTexto += 'KpiOrganizacao_00009='+STR0882+CRLF/*//'"Pol�tica de Qualidade:"'*/
cTexto += 'KpiOrganizacao_00010='+STR0883+CRLF/*//'"Notas:"'*/
cTexto += 'KpiOrganizacao_00011='+STR0884+CRLF/*//'"Endere�o:"'*/
cTexto += 'KpiOrganizacao_00012='+STR0885+CRLF/*//'"Cidade:"'*/
cTexto += 'KpiOrganizacao_00013='+STR0886+CRLF/*//'"Estado:"'*/
cTexto += 'KpiOrganizacao_00014='+STR0887+CRLF/*//'"Pa�s:"'*/
cTexto += 'KpiOrganizacao_00015='+STR0888+CRLF/*//'"Telefone:"'*/
cTexto += 'KpiOrganizacao_00016='+STR0889+CRLF/*//'"E-mail:"'*/
cTexto += 'KpiOrganizacao_00017='+STR0890+CRLF/*//'"P�gina na Web:"'*/

//KpiPerspectiva
cTexto += 'KpiPerspectiva_00001='+STR0891+CRLF/*//"Perspectiva"'*/
cTexto += 'KpiPerspectiva_00002='+STR0892+CRLF/*//"Perspectiva:"'*/
cTexto += 'KpiPerspectiva_00003='+STR0893+CRLF/*//"Descri��o:"'*/
cTexto += 'KpiPerspectiva_00004='+STR0894+CRLF/*//"Ordem:"'*/

//MatrixFrameBehavior
cTexto += 'MatrixFrameBehavior_00001='+STR0895+CRLF/*//'"Segura"'*/
cTexto += 'MatrixFrameBehavior_00002='+STR0896+CRLF/*//'"Recursiva"'*/
cTexto += 'MatrixFrameBehavior_00003='+STR0897+CRLF/*//'"Cancelar"'*/

cTexto += 'MatrixFrameBehavior_00004='+STR0898+CRLF/*//'"Segura � Somente a Organiza��o ser� exclu�da se n�o existir estrutura hier�rquica relacionada.\nRecursiva � A Organiza��o e toda estrutura hier�rquica relacionada ser�o exclu�das."'*/
cTexto += 'MatrixFrameBehavior_00005='+STR0899+CRLF/*//'"Segura � Somente a Estrat�gia ser� exclu�da se n�o existir estrutura hier�rquica relacionada.\nRecursiva � A Estrat�gia e toda estrutura hier�rquica relacionada ser�o exclu�das."'*/
cTexto += 'MatrixFrameBehavior_00006='+STR0900+CRLF/*//'"Segura � Somente a Perspectiva ser� exclu�da se n�o existir estrutura hier�rquica relacionada.\nRecursiva � A Perspectiva e toda estrutura hier�rquica relacionada ser�o exclu�das."'*/
cTexto += 'MatrixFrameBehavior_00007='+STR0901+CRLF/*//'"Segura � Somente o Objetivo ser� exclu�do se n�o existirem itens relacionados.\nRecursiva � O Objetivo e todos os itens relacionados ser�o exclu�dos."'*/
cTexto += 'MatrixFrameBehavior_00008='+STR0902+CRLF/*//'"M�todo de Exclus�o"'*/

cTexto += 'KpiCustomLabels_00001='+STR0924+CRLF/*//'"Entidades"'*/          
cTexto += 'KpiCustomLabels_00002='+STR0925+CRLF/*//'"Objetivo"'*/          

//KpiRelBook
cTexto += 'KpiRelBook_00001='+STR0927+CRLF/*// "Book de Planejamento Estrat�gico"'*/
cTexto += 'KpiRelBook_00002='+STR0928+CRLF/*// "Nome:"'*/
cTexto += 'KpiRelBook_00003='+STR0929+CRLF/*// "Descri��o:"'*/
cTexto += 'KpiRelBook_00004='+STR0930+CRLF/*// "Entidades:"'*/
cTexto += 'KpiRelBook_00005='+STR0931+CRLF/*// "Imprimir descri��o"'*/
cTexto += 'KpiRelBook_00006='+STR0932+CRLF/*// "Imprimir Indicadoes"'*/

//KpiRelInd
cTexto += 'KpiRelInd_00001='+STR0933+CRLF/*//'Relat�rio de Indicadores"'*/
cTexto += 'KpiRelInd_00002='+STR0934+CRLF/*//'Nome:"'*/
cTexto += 'KpiRelInd_00003='+STR0935+CRLF/*//'Descri��o:"'*/
cTexto += 'KpiRelInd_00004='+STR0936+CRLF/*//'Entidades"'*/
cTexto += 'KpiRelInd_00005='+STR0937+CRLF/*//'Data Alvo:"'*/
cTexto += 'KpiRelInd_00006='+STR0938+CRLF/*//'Objetivos:"'*/
cTexto += 'KpiRelInd_00007='+STR0939+CRLF/*//'Imprimir descri��o"'*/
cTexto += 'KpiRelInd_00008='+STR0940+CRLF/*//'Atingido"'*/
cTexto += 'KpiRelInd_00009='+STR0941+CRLF/*//'N�o Atingido"'*/
cTexto += 'KpiRelInd_00010='+STR0942+CRLF/*//'Dentro da Toler�ncia"'*/
cTexto += 'KpiRelInd_00011='+STR0943+CRLF/*//'Todos"'*/

//KpiMapaFrame
cTexto += 'KpiMapaFrame_00001='+STR0948+CRLF/*//'Fechar'*/
cTexto += 'KpiMapaFrame_00002='+STR0949+CRLF/*//'Maximizar'*/
cTexto += 'KpiMapaFrame_00003='+STR0950+CRLF/*//'Mapa Estrat�gico*/
cTexto += 'KpiMapaFrame_00004='+STR0951+CRLF/*//'Data Alvo:*/
cTexto += 'KpiMapaFrame_00005='+STR0952+CRLF/*//'Gravar*/
cTexto += 'KpiMapaFrame_00006='+STR0953+CRLF/*//'Cancelar*/
cTexto += 'KpiMapaFrame_00007='+STR0954+CRLF/*//'Selecionar*/
cTexto += 'KpiMapaFrame_00008='+STR0955+CRLF/*//'Criar agrupamentos*/
cTexto += 'KpiMapaFrame_00009='+STR0956+CRLF/*//'Criar liga��es*/
cTexto += 'KpiMapaFrame_00010='+STR0957+CRLF/*//'Excluir*/
cTexto += 'KpiMapaFrame_00011='+STR0958+CRLF/*//'Divis�es*/
cTexto += 'KpiMapaFrame_00012='+STR0959+CRLF/*//'Editar*/
cTexto += 'KpiMapaFrame_00013='+STR0960+CRLF/*//'Atualizar*/
cTexto += 'KpiMapaFrame_00014='+STR0961+CRLF/*//'Imprimir*/
cTexto += 'KpiMapaFrame_00015='+STR0962+CRLF/*//'Exportar*/
cTexto += 'KpiMapaFrame_00016='+STR0963+CRLF/*//'Confirma a exporta��o do mapa estrategico?*/
cTexto += 'KpiMapaFrame_00017='+STR0964+CRLF/*//'Confirma a impress�o do mapa estrategico?*/
cTexto += 'KpiMapaFrame_00018='+STR0965+CRLF/*//'Estrat�gia: */
cTexto += 'KpiMapaFrame_00019='+STR0966+CRLF/*//'Cor do Texto*/
cTexto += 'KpiMapaFrame_00020='+STR0967+CRLF/*//'Cor do Fundo*/
cTexto += 'KpiMapaFrame_00021='+STR0968+CRLF/*//'Selecione a Cor do Texto*/
cTexto += 'KpiMapaFrame_00022='+STR0969+CRLF/*//'Selecione a Cor de Fundo*/
cTexto += 'KpiMapaFrame_00023='+STR0970+CRLF/*//'Mudar para Oval*/
cTexto += 'KpiMapaFrame_00024='+STR0971+CRLF/*//'Mudar para Ret�ngulo*/
cTexto += 'KpiMapaFrame_00025='+STR0972+CRLF/*//'Nome*/
cTexto += 'KpiMapaFrame_00026='+STR0973+CRLF/*//'Informe o Nome do agrupamento*/
cTexto += 'KpiMapaFrame_00027='+STR0974+CRLF/*//'Redefinir Linha*/
cTexto += 'KpiMapaFrame_00028='+STR0975+CRLF/*//'Cor da Linha*/
cTexto += 'KpiMapaFrame_00029='+STR0976+CRLF/*//'Selecione a Cor da Linha'*/  
cTexto += 'KpiMapaFrame_00030='+STR0987+CRLF/*//'Tema Estrat�gico:'*/  
cTexto += 'KpiMapaFrame_00031='+STR0988+CRLF/*//'Ocultar Texto'*/  
cTexto += 'KpiMapaFrame_00032='+STR0989+CRLF/*//'Fundo Transparente'*/  
cTexto += 'KpiMapaFrame_00033='+STR0990+CRLF/*//'Imagem de Fundo'*/  
cTexto += 'KpiMapaFrame_00034='+STR0991+CRLF/*//'Selecionar'*/  
cTexto += 'KpiMapaFrame_00035='+STR0992+CRLF/*//'Selecionar Imagem'*/  

//KpiMapaFormController
cTexto += 'KpiMapaFormController_00001='+STR0977+CRLF/*//'Novo Agrupamento'*/
cTexto += 'KpiMapaFormController_00002='+STR0978+CRLF/*//'Confirma a exclus�o do Agrupamento?'*/
cTexto += 'KpiMapaFormController_00003='+STR0979+CRLF/*//'Confirma a exclus�o da liga��o?'*/

//KpiTemaEstrategico
cTexto += 'KpiTemaEstrategico_00001='+STR0981+CRLF/*//'Tema Estrat�gico'*/
cTexto += 'KpiTemaEstrategico_00002='+STR0982+CRLF/*//'Nome'*/
cTexto += 'KpiTemaEstrategico_00003='+STR0983+CRLF/*//'Descri�ao'*/
cTexto += 'KpiTemaEstrategico_00004='+STR0984+CRLF/*//'Objetivos'*/
cTexto += 'KpiTemaEstrategico_00005='+STR0985+CRLF/*//'Informe o Nome do Tema Estrat�gico'*/

//KpiJustificativaMeta
cTexto += 'KpiJustificativaMeta_00001='+STR0997+CRLF/*//'Justificativa de Altera��o de Meta'*/
cTexto += 'KpiJustificativaMeta_00002='+STR0998+CRLF/*//'Hist�rico:'*/
cTexto += 'KpiJustificativaMeta_00003='+STR0999+CRLF/*//'Indicador:'*/
cTexto += 'KpiJustificativaMeta_00004='+STR1000+CRLF/*//'Per�odo De:'*/

cTexto += cKPIIntContinue()

return cTexto
