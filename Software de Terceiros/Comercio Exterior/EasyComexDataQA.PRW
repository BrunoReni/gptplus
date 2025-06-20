#include "Protheus.ch"
#include "MsObject.ch"
#Include "Average.ch"

#Define ROTEIRO "ROT"

/*
Classe   : EasyComexDataQA
Objetivo : Integra��o com o portal ComexData QA
Autor    : Rodrigo Mendes Diaz
Data     : 01/01/14
*/
*---------------------------------*
Function EasyComexDataQA()
*---------------------------------*
Return

*------------------------------------*
Class EasyComexDataQA From AvObject
*------------------------------------*
	Data cUsuario
	Data cSenha
	
	//*** Dados utilizados nas buscas no site
	//Termo a ser buscado
	Data cBusca
	//C�digo da NCM sem m�scara
	Data cNCM
	//Termo (descri��o do produto) para ferramenta de classifica��o fiscal
	Data cClassificacao
	//C�digo do Roteiro
	Data cRoteiro
	//***
	
	//*** Dados relacionados aos links para roteiros no site
	//Define se foram informados roteiros relacionados � rotina que chamou a tela do ComexData QA
	Data lRoteirosRel
	//Rela��o de todos os links para roteiros
	Data aLinks
	//Rela��o dos c�digos dos roteiros relacionados � pagina atual
	Data aRelacionados
	
	/* Construtor. Informar m�dulo origem e rotina origem para utilizar na busca por roteiros relacionados. 
	   Valor padr�o: M�dulo atual e rotina que instanciou a classe.
	*/
	Method New(nMod, cOwner, cUserCD, cPassCD) Constructor
	
	//Exibe a tela principal
	Method ShowDlg()
	
	//Retorna o login (USUARIO.HASH_SENHA) para utiliza��o nos links
	Method GetLoginHash()
	
	//Carrega todos os links de roteiro dispon�veis
	Method LoadLinks()
	
	//Executa uma busca no site com base no termo digitado
	Method OpenURLBusca()
	
	//Exibe as informa��es relacionadas � NCM escolhida
	Method OpenURLNCM()
	
	//Exibe a rotina de classifica��o fiscal do site para a descri��o de produto informada.
	Method OpenUrlClassificacao()
	
	//Exibe um roteiro do site com base no que foi selecionado no listbox da tela principal
	Method OpenURLRoteiro()
	
	//*** Ferramentas relacionadas aos links para roteiros no site
	//Relaciona um roteiro com a rotina atual (que instanciou a classe), a partir do c�digo do mesmo.
	Method RelRoteiro(cID)
	//Carrega/recarrega os roteiros de acordo com a op��o do usu�rio (somente relacionados ou todos)
	Method ListRoteiro()
	//Carrega a rela��o de roteiros pr�-definidos para o m�dulo e/ou rotina.
	Method LoadRelacao(nMod, cOwner)
	//***

EndClass

*----------------------------------------------*
Method New(nMod, cOwner, cUserCD, cPassCD) Class EasyComexDataQA
*----------------------------------------------*
Default nMod := nModulo
Default cOwner := ProcName(1)

	Self:cUsuario		:= cUserCD
	Self:cSenha		:= AllTrim(cPassCD)//AllTrim(DECRYP(cPassCD))
	
	Self:cBusca         := Space(100)
	Self:cNCM           := CriaVar("YD_TEC")
	Self:cClassificacao := Space(100)
	
	Self:aLinks			:= {}
	Self:aRelacionados	:= {}
	
	Self:lRoteirosRel := .F.
	
	Self:LoadLinks()
	Self:LoadRelacao(nMod, cOwner)

Return Self

*----------------------------------------------*
Method ShowDlg() Class EasyComexDataQA
*----------------------------------------------*
Local oDlg, oRoteiros, oCBox
Local aRoteiros := Self:ListRoteiro()
Local lRoteiros := Len(Self:aRelacionados) > 0
Local cRoteiro := " "
Local bOk := {|| oDlg:End() }, bCancel := {|| oDlg:End() }

	Define MsDialog oDlg Title "Dados da Pesquisa" From 0, 0 To 350, 425 Of oMainWnd Pixel
	    
	    oPanel:= TPanel():New(0, 0, "", oDlg,, .F., .F.,,, 90, 165) //MCF - 11/02/2016
	    oPanel:Align:= CONTROL_ALIGN_ALLCLIENT
	    
		@ 5, 5 BitMap ResName "easy_comexqa" Size 210, 25 NoBorder Of oPanel Pixel
		
		@ 30, 5   To 70, 210 Label "Roteiros" Of oPanel Pixel
		@ 42, 12  ComboBox oRoteiros Var Self:cRoteiro Items aRoteiros Size 180,40 Of oPanel Pixel
		@ 42, 195 Button "Ir" Action Self:OpenURLRoteiro() Size 10,10 Pixel Of oPanel
		@ 60, 90  CheckBox oCBox Var Self:lRoteirosRel Valid (oRoteiros:SetItems(Self:ListRoteiro()), .T.) Prompt "Exibir somente roteiros relacionados" Size 100,10 Of oPanel Pixel
		
		@ 74, 5   To 105, 210 Label "Buscar Termo" Of oPanel Pixel
		@ 85, 12  MsGet Self:cBusca Size 180,10 Of oPanel Pixel
		@ 85, 195 Button "Ir" Action Self:OpenUrlBusca() Size 10,10 Pixel Of oPanel
		
		@ 109, 5   To 140, 75 Label "Buscar NCM" Of oPanel Pixel
		@ 120, 12  MsGet Self:cNCM F3 "SYD" Picture AvSx3("YD_TEC", AV_PICTURE) Size 40,10 Of oPanel Pixel
		@ 120, 60 Button "Ir" Action Self:OpenUrlNCM() Size 10,10 Pixel Of oPanel
		
		@ 109, 80   To 140, 210 Label "Buscar Classifica��o" Of oPanel Pixel
		@ 120, 90  MsGet Self:cClassificacao Size 100,10 Of oPanel Pixel
		@ 120, 195 Button "Ir" Action Self:OpenUrlClassificacao() Size 10,10 Pixel Of oPanel

	Activate MSDialog oDlg On Init EnchoiceBar(oDlg, bOk, bCancel) Centered

Return Nil

*----------------------------------------------*
Method GetLoginHash() Class EasyComexDataQA
*----------------------------------------------*
Return Self:cUsuario + "." + SubStr(Md5(Self:cSenha + SubStr(DToS(dDataBase), 7, 2) + SubStr(DToS(dDataBase), 5, 2) + SubStr(DToS(dDataBase), 1, 4), 2) + Md5(Self:cSenha + SubStr(DToS(dDataBase), 7, 2) + SubStr(DToS(dDataBase), 5, 2) + SubStr(DToS(dDataBase), 1, 4), 2), Day(Date()) + 1, 32) + "/"

*----------------------------------------------*
Method OpenURLBusca() Class EasyComexDataQA
*----------------------------------------------*
Local cURL := ""

	cURL := "http://www.comexdata.com.br/consulta/" + Self:GetLoginHash() + "legislacao/?expressao=" + Self:cBusca
	ShellExecute("open", cUrl,"","", 1)

Return cURL

*---------------------------------------------------*
Method OpenUrlClassificacao() Class EasyComexDataQA
*---------------------------------------------------*
Local cURL := ""

	cURl := "http://www.comexdata.com.br/consulta/" + Self:GetLoginHash() + "classificacao/?descricao=" + Self:cClassificacao
	ShellExecute("open", cUrl,"","", 1)

Return cURL

*----------------------------------------------*
Method OpenURLNCM() Class EasyComexDataQA
*----------------------------------------------*
Local cURL := ""

	cURL := "http://www.comexdata.com.br/consulta/" + Self:GetLoginHash() + "tec/?ncm=" + Self:cNCM
	ShellExecute("open", cUrl,"","", 1)

Return cURL

*----------------------------------------------*
Method OpenURLRoteiro() Class EasyComexDataQA
*----------------------------------------------*
Local cURL := ""

	If (nPos := aScan(Self:aLinks, {|x| x[3] == Self:cRoteiro })) > 0
		cURL := "http://www.comexdata.com.br/consulta/" + Self:GetLoginHash() + "documento/?PID=" + Self:aLinks[nPos][4]
		ShellExecute("open", cUrl,"","", 1)
	EndIf

Return cURL

*----------------------------------------------*
Method RelRoteiro(cID) Class EasyComexDataQA
*----------------------------------------------*
	If aScan(Self:aRelacionados, cID) == 0
		aAdd(Self:aRelacionados, cID)
	EndIf
	Self:lRoteirosRel := .T.

Return Nil

*----------------------------------------------*
Method ListRoteiro() Class EasyComexDataQA
*----------------------------------------------*
Local aRoteiros := {}
Local i, nPos
    
	If !Self:lRoteirosRel
		For i := 1 To Len(Self:aLinks)
			aAdd(aRoteiros, Self:aLinks[i][3])
		Next
	Else
		For i := 1 To Len(Self:aRelacionados)
			If (nPos := aScan(Self:aLinks, {|x| x[2] == Self:aRelacionados[i] })) > 0
				aAdd(aRoteiros, Self:aLinks[nPos][3])
			EndIf
		Next
	EndIf

Return aRoteiros

*----------------------------------------------*
Method LoadLinks() Class EasyComexDataQA
*----------------------------------------------*
	aAdd(Self:aLinks, {ROTEIRO, "01", 'Exporta��o - Roteiro de Procedimentos','284390'})
	aAdd(Self:aLinks, {ROTEIRO, "02", 'Siscoserv - Roteiro de Procedimentos','273218'})
	aAdd(Self:aLinks, {ROTEIRO, "03", 'Drawback - Roteiro de Procedimentos','148630'})
	aAdd(Self:aLinks, {ROTEIRO, "04", 'RADAR - Roteiro de Procedimentos','248698'})
	aAdd(Self:aLinks, {ROTEIRO, "05", 'Importa��o de Material Usado - Roteiro de Procedimentos','269017'})
	aAdd(Self:aLinks, {ROTEIRO, "06", 'RECOF - Roteiro de Procedimentos','208844'})
	aAdd(Self:aLinks, {ROTEIRO, "07", 'ICMS/SP - Exporta��o - Roteiro de Procedimentos','198919'})
	aAdd(Self:aLinks, {ROTEIRO, "08", 'Exame de similaridade - Roteiro de Procedimentos','257629'})
	aAdd(Self:aLinks, {ROTEIRO, "09", 'Regime Especial de Reintegra��o de Valores Tribut�rios para as Empresas Exportadoras (REINTEGRA) - Roteiro de Procedimentos','258278'})
	aAdd(Self:aLinks, {ROTEIRO, "10", 'Remessa Expressa (Courier) - Roteiro de Procedimentos','212240'})
	aAdd(Self:aLinks, {ROTEIRO, "11", 'Registro de Exporta��o (RE) - Roteiro de Procedimentos','278207'})
	aAdd(Self:aLinks, {ROTEIRO, "12", 'Medidas Antidumping - Roteiro de Procedimentos','276403'})
	aAdd(Self:aLinks, {ROTEIRO, "13", 'ICMS/SP - Drawback - Tratamento Fiscal - Roteiro de Procedimentos','202780'})
	aAdd(Self:aLinks, {ROTEIRO, "14", 'ICMS/SP - Regime Especial Simplificado de Exporta��o - Roteiro de Procedimentos','125777'})
	aAdd(Self:aLinks, {ROTEIRO, "15", 'Regime Aduaneiro Especial de Tr�nsito Aduaneiro - Roteiro de Procedimentos','270402'})
	aAdd(Self:aLinks, {ROTEIRO, "16", 'ICMS/BA - Exporta��o - Roteiro de Procedimentos','215054'})
	aAdd(Self:aLinks, {ROTEIRO, "17", 'Classifica��o fiscal de mercadorias - Roteiro de Procedimentos','251293'})
	aAdd(Self:aLinks, {ROTEIRO, "18", 'Bens de viajante - Bagagem - Tratamento tribut�rio e controle aduaneiro - Roteiro de Procedimentos','249118'})
	aAdd(Self:aLinks, {ROTEIRO, "19", 'Procedimentos especiais de fiscaliza��o aduaneira - Roteiro de Procedimentos','261305'})
	aAdd(Self:aLinks, {ROTEIRO, "20", 'Processo Administrativo de Consulta - Roteiro de Procedimentos','160726'})
	aAdd(Self:aLinks, {ROTEIRO, "21", 'INCOTERMS 2010 - Roteiro de Procedimentos','249804'})
	aAdd(Self:aLinks, {ROTEIRO, "22", 'ICMS/SP - Encomenda A�rea Internacional - Empresa de Courier - Roteiro de Procedimentos','202323'})
	aAdd(Self:aLinks, {ROTEIRO, "23", 'ICMS/RS - Exporta��o direta e indireta - Roteiro de Procedimentos - Roteiro de Procedimentos','215111'})
	aAdd(Self:aLinks, {ROTEIRO, "24", 'Modalidades de Pagamento Internacional - Roteiro de Procedimentos','251810'})
	aAdd(Self:aLinks, {ROTEIRO, "25", 'ICMS/RO - Exporta��o - Roteiro de Procedimentos','196340'})
	aAdd(Self:aLinks, {ROTEIRO, "26", 'ICMS/PE - Exporta��o - Roteiro de Procedimentos','193943'})
	aAdd(Self:aLinks, {ROTEIRO, "27", 'ICMS/ES - Exporta��o - Roteiro de Procedimentos','214631'})
	aAdd(Self:aLinks, {ROTEIRO, "28", 'ICMS/MS - Exporta��es - Regime Especial de Controle e Fiscaliza��o - Roteiro de Procedimentos','161597'})
	aAdd(Self:aLinks, {ROTEIRO, "29", 'ICMS/RJ - Exporta��o - Roteiro de Procedimentos','214632'})
	aAdd(Self:aLinks, {ROTEIRO, "30", 'ICMS/MT - Exporta��o direta e indireta - Roteiro de Procedimentos','220856'})
	aAdd(Self:aLinks, {ROTEIRO, "31", 'ICMS/MG - Exporta��o direta e indireta - Roteiro de Procedimentos','108543'})
	aAdd(Self:aLinks, {ROTEIRO, "32", 'ICMS/GO - Exporta��o direta e indireta - Roteiro de Procedimentos','218917'})
	aAdd(Self:aLinks, {ROTEIRO, "33", 'SGPC - Sistema Global de Prefer�ncias Comerciais - Coment�rios','277390'})
	aAdd(Self:aLinks, {ROTEIRO, "34", 'Despachante Aduaneiro - Procedimentos para Registro - Coment�rios','269420'})
	aAdd(Self:aLinks, {ROTEIRO, "35", 'SGP - Sistema Geral de Prefer�ncias - Coment�rios','267707'})
	aAdd(Self:aLinks, {ROTEIRO, "36", 'SISCOSERV - Sistema Integrado de Com�rcio Exterior de Servi�os - Coment�rios','266986'})
	aAdd(Self:aLinks, {ROTEIRO, "37", 'Financiamentos � exporta��o - Coment�rios','256960'})
	aAdd(Self:aLinks, {ROTEIRO, "38", 'Lista de Exce��o � TEC - Coment�rios','256300'})
	aAdd(Self:aLinks, {ROTEIRO, "39", 'Empresa Comercial Exportadora - Trading Company - Diferen�as � Coment�rios','243642'})
	aAdd(Self:aLinks, {ROTEIRO, "40", 'ICMS/Nacional - Produtos importados - Al�quota de 4% nas opera��es interestaduais - Roteiro de Procedimentos','276817'})
	aAdd(Self:aLinks, {ROTEIRO, "41", 'ICMS/ES - Importa��o - Roteiro de Procedimentos','215582'})
	aAdd(Self:aLinks, {ROTEIRO, "42", 'ICMS/MT - Importa��o - Roteiro de Procedimentos','223052'})
	aAdd(Self:aLinks, {ROTEIRO, "43", 'ICMS/SP - Importa��o - Roteiro de Procedimentos','157775'})
	aAdd(Self:aLinks, {ROTEIRO, "44", 'ICMS/GO - Importa��o - Roteiro de Procedimentos','220026'})
	aAdd(Self:aLinks, {ROTEIRO, "45", 'ICMS/PR - Importa��o - Roteiro de Procedimentos','215795'})
	aAdd(Self:aLinks, {ROTEIRO, "46", 'PIS/PASEP - Importa��o e COFINS - Importa��o - Roteiro de Procedimentos','120027'})
	aAdd(Self:aLinks, {ROTEIRO, "47", 'Importa��o de bens - Contabiliza��o - Roteiro de Procedimentos','244000'})
	aAdd(Self:aLinks, {ROTEIRO, "48", 'PIS/PASEP, COFINS, IPI, CIDE, e IR - PADIS - Programa de Apoio ao Desenvolvimento Tecnol�gico da Ind�stria de Semicondutores - Roteiro de Procedimentos','160850'})
	aAdd(Self:aLinks, {ROTEIRO, "49", 'ICMS/MG - Importa��o - Roteiro de Procedimentos','216927'})
	aAdd(Self:aLinks, {ROTEIRO, "50", 'PIS/PASEP e COFINS - Biodiesel - Regime diferenciado - Roteiro de Procedimentos','128827'})
	aAdd(Self:aLinks, {ROTEIRO, "51", 'ICMS/PR - Exporta��o direta e indireta - Roteiro de Procedimentos','215438'})
	aAdd(Self:aLinks, {ROTEIRO, "52", 'PIS/PASEP e COFINS - RECAP - Roteiro de Procedimentos','142412'})
	aAdd(Self:aLinks, {ROTEIRO, "53", 'Regime Aduaneiro Especial de Tr�nsito Aduaneiro - Roteiro de Procedimentos','270402'})
	aAdd(Self:aLinks, {ROTEIRO, "54", 'ICMS/BA - Importa��o - Roteiro de Procedimentos','216518'})
	aAdd(Self:aLinks, {ROTEIRO, "55", 'ICMS/BA - Exporta��o - Roteiro de Procedimentos','215054'})
	aAdd(Self:aLinks, {ROTEIRO, "56", 'Ex-tarif�rios - Roteiro de Procedimentos','256693'})
	aAdd(Self:aLinks, {ROTEIRO, "57", 'ICMS/RS - Importa��o - Roteiro de Procedimentos','216020'})
	aAdd(Self:aLinks, {ROTEIRO, "58", 'PIS/PASEP, COFINS, IPI e II - REPORTO - Roteiro de Procedimentos','127080'})
	aAdd(Self:aLinks, {ROTEIRO, "59", 'ICMS/SP - Regime Aduaneiro Especial de Dep�sito Afian�ado - DAF - Roteiro de Procedimentos','199701'})
	aAdd(Self:aLinks, {ROTEIRO, "60", 'Importa��o indireta - Roteiro de Procedimentos','250762'})
	aAdd(Self:aLinks, {ROTEIRO, "61", 'PIS/PASEP, COFINS, PIS/PASEP-Importa��o e COFINS-Importa��o - Importa��o por conta e ordem de terceiro - Roteiro de Procedimentos','129100'})
	aAdd(Self:aLinks, {ROTEIRO, "62", 'PIS/PASEP e COFINS - �reas de Livre Com�rcio - Roteiro de Procedimentos','207949'})
	aAdd(Self:aLinks, {ROTEIRO, "63", 'ICMS/RJ - Importa��o - Roteiro de Procedimentos','216899'})
	aAdd(Self:aLinks, {ROTEIRO, "64", 'PIS/PASEP-Importa��o e COFINS-Importa��o - Pr�-formas para envasamento de �gua, refrigerante e outros produtos - Regime Aduaneiro Especial - Roteiro de Procedimentos','138218'})
	aAdd(Self:aLinks, {ROTEIRO, "65", 'PIS/Pasep e COFINS - Regime de Entrega de Embalagens no Mercado Interno em Raz�o da Comercializa��o a Empresa Sediada no Exterior (Remicex) � Suspens�o  - Roteiro de Procedimentos','208515'})
	aAdd(Self:aLinks, {ROTEIRO, "66", 'PIS/PASEP e COFINS - Biodiesel - Roteiro de Procedimentos','201136'})
	aAdd(Self:aLinks, {ROTEIRO, "67", 'Devolu��o de mercadoria importada - Coment�rios','277133'})
	aAdd(Self:aLinks, {ROTEIRO, "68", 'Sistema de pagamento em moeda local - Coment�rios','259057'})
	aAdd(Self:aLinks, {ROTEIRO, "69", 'Importa��o de amostras - Coment�rios','257578'})
	aAdd(Self:aLinks, {ROTEIRO, "70", 'Importa��o de ve�culos usados - Coment�rios','256895'})
	aAdd(Self:aLinks, {ROTEIRO, "71", 'Plano Brasil Maior - Medidas aplicadas ao com�rcio exterior - Coment�rios','254897'})
	aAdd(Self:aLinks, {ROTEIRO, "72", 'PIS/PASEP e COFINS - Opera��es "back to back" � Incid�ncia � Coment�rios','252076'})
	aAdd(Self:aLinks, {ROTEIRO, "73", 'Licenciamento n�o autom�tico - Restri��o � entrada de produtos - Com�rcio entre Brasil e Argentina - Coment�rios','249297'})

Return Nil

*------------------------------------------------------*
Method LoadRelacao(nMod, cOwner) Class EasyComexDataQA
*------------------------------------------------------*
	Do Case
		Case nMod == 29//EEC
			Self:RelRoteiro("01") // 'Exporta��o - Roteiro de Procedimentos') //'284390' 
			Self:RelRoteiro("04") // 'RADAR - Roteiro de Procedimentos') //'248698' 
			Self:RelRoteiro("07") // 'ICMS/SP - Exporta��o - Roteiro de Procedimentos') //'198919' 
			Self:RelRoteiro("09") // 'Regime Especial de Reintegra��o de Valores Tribut�rios para as Empresas Exportadoras (REINTEGRA) - Roteiro de Procedimentos') //'258278' 
			Self:RelRoteiro("10") // 'Remessa Expressa (Courier) - Roteiro de Procedimentos') //'212240' 
			Self:RelRoteiro("11") // 'Registro de Exporta��o (RE) - Roteiro de Procedimentos') //'278207' 
			Self:RelRoteiro("14") // 'ICMS/SP - Regime Especial Simplificado de Exporta��o - Roteiro de Procedimentos') //'125777' 
			Self:RelRoteiro("16") // 'ICMS/BA - Exporta��o - Roteiro de Procedimentos') //'215054' 
			Self:RelRoteiro("17") // 'Classifica��o fiscal de mercadorias - Roteiro de Procedimentos') //'251293' 
			Self:RelRoteiro("19") // 'Procedimentos especiais de fiscaliza��o aduaneira - Roteiro de Procedimentos') //'261305' 
			Self:RelRoteiro("20") // 'Processo Administrativo de Consulta - Roteiro de Procedimentos') //'160726' 
			Self:RelRoteiro("21") // 'INCOTERMS 2010 - Roteiro de Procedimentos') //'249804' 
			Self:RelRoteiro("23") // 'ICMS/RS - Exporta��o direta e indireta - Roteiro de Procedimentos - Roteiro de Procedimentos') //'215111' 
			Self:RelRoteiro("24") // 'Modalidades de Pagamento Internacional - Roteiro de Procedimentos') //'251810' 
			Self:RelRoteiro("25") // 'ICMS/RO - Exporta��o - Roteiro de Procedimentos') //'196340' 
			Self:RelRoteiro("26") // 'ICMS/PE - Exporta��o - Roteiro de Procedimentos') //'193943' 
			Self:RelRoteiro("27") // 'ICMS/ES - Exporta��o - Roteiro de Procedimentos') //'214631' 
			Self:RelRoteiro("28") // 'ICMS/MS - Exporta��es - Regime Especial de Controle e Fiscaliza��o - Roteiro de Procedimentos') //'161597' 
			Self:RelRoteiro("29") // 'ICMS/RJ - Exporta��o - Roteiro de Procedimentos') //'214632' 
			Self:RelRoteiro("30") // 'ICMS/MT - Exporta��o direta e indireta - Roteiro de Procedimentos') //'220856' 
			Self:RelRoteiro("31") // 'ICMS/MG - Exporta��o direta e indireta - Roteiro de Procedimentos') //'108543' 
			Self:RelRoteiro("32") // 'ICMS/GO - Exporta��o direta e indireta - Roteiro de Procedimentos') //'218917' 
			Self:RelRoteiro("33") // 'SGPC - Sistema Global de Prefer�ncias Comerciais - Coment�rios') //'277390' 
			Self:RelRoteiro("34") // 'Despachante Aduaneiro - Procedimentos para Registro - Coment�rios') //'269420' 
			Self:RelRoteiro("35") // 'SGP - Sistema Geral de Prefer�ncias - Coment�rios') //'267707' 
			Self:RelRoteiro("37") // 'Financiamentos � exporta��o - Coment�rios') //'256960' 
			Self:RelRoteiro("39") // 'Empresa Comercial Exportadora - Trading Company - Diferen�as � Coment�rios') //'243642' 
			Self:RelRoteiro("71") // 'Plano Brasil Maior - Medidas aplicadas ao com�rcio exterior - Coment�rios') //'254897' 
			Self:RelRoteiro("72") // 'PIS/PASEP e COFINS - Opera��es "back to back" � Incid�ncia � Coment�rios') //'252076' 
		
		Case nMod == 17//EIC
			Self:RelRoteiro("04") // 'RADAR - Roteiro de Procedimentos') //'248698' 
			Self:RelRoteiro("05") // 'Importa��o de Material Usado - Roteiro de Procedimentos') //'269017' 
			Self:RelRoteiro("08") // 'Exame de similaridade - Roteiro de Procedimentos') //'257629' 
			Self:RelRoteiro("10") // 'Remessa Expressa (Courier) - Roteiro de Procedimentos') //'212240' 
			Self:RelRoteiro("12") // 'Medidas Antidumping - Roteiro de Procedimentos') //'276403' 
			Self:RelRoteiro("13") // 'ICMS/SP - Drawback - Tratamento Fiscal - Roteiro de Procedimentos') //'202780' 
			Self:RelRoteiro("15") // 'Regime Aduaneiro Especial de Tr�nsito Aduaneiro - Roteiro de Procedimentos') //'270402' 
			Self:RelRoteiro("17") // 'Classifica��o fiscal de mercadorias - Roteiro de Procedimentos') //'251293' 
			Self:RelRoteiro("19") // 'Procedimentos especiais de fiscaliza��o aduaneira - Roteiro de Procedimentos') //'261305' 
			Self:RelRoteiro("20") // 'Processo Administrativo de Consulta - Roteiro de Procedimentos') //'160726' 
			Self:RelRoteiro("21") // 'INCOTERMS 2010 - Roteiro de Procedimentos') //'249804' 
			Self:RelRoteiro("22") // 'ICMS/SP - Encomenda A�rea Internacional - Empresa de Courier - Roteiro de Procedimentos') //'202323' 
			Self:RelRoteiro("23") // 'ICMS/RS - Exporta��o direta e indireta - Roteiro de Procedimentos - Roteiro de Procedimentos') //'215111' 
			Self:RelRoteiro("24") // 'Modalidades de Pagamento Internacional - Roteiro de Procedimentos') //'251810' 
			Self:RelRoteiro("33") // 'SGPC - Sistema Global de Prefer�ncias Comerciais - Coment�rios') //'277390' 
			Self:RelRoteiro("34") // 'Despachante Aduaneiro - Procedimentos para Registro - Coment�rios') //'269420' 
			Self:RelRoteiro("35") // 'SGP - Sistema Geral de Prefer�ncias - Coment�rios') //'267707' 
			Self:RelRoteiro("38") // 'Lista de Exce��o � TEC - Coment�rios') //'256300' 
			Self:RelRoteiro("39") // 'Empresa Comercial Exportadora - Trading Company - Diferen�as � Coment�rios') //'243642' 
			Self:RelRoteiro("40") // 'ICMS/Nacional - Produtos importados - Al�quota de 4% nas opera��es interestaduais - Roteiro de Procedimentos') //'276817' 
			Self:RelRoteiro("41") // 'ICMS/ES - Importa��o - Roteiro de Procedimentos') //'215582' 
			Self:RelRoteiro("42") // 'ICMS/MT - Importa��o - Roteiro de Procedimentos') //'223052' 
			Self:RelRoteiro("43") // 'ICMS/SP - Importa��o - Roteiro de Procedimentos') //'157775' 
			Self:RelRoteiro("44") // 'ICMS/GO - Importa��o - Roteiro de Procedimentos') //'220026' 
			Self:RelRoteiro("45") // 'ICMS/PR - Importa��o - Roteiro de Procedimentos') //'215795' 
			Self:RelRoteiro("46") // 'PIS/PASEP - Importa��o e COFINS - Importa��o - Roteiro de Procedimentos') //'120027' 
			Self:RelRoteiro("47") // 'Importa��o de bens - Contabiliza��o - Roteiro de Procedimentos') //'244000' 
			Self:RelRoteiro("48") // 'PIS/PASEP) // COFINS) // IPI) // CIDE) // e IR - PADIS - Programa de Apoio ao Desenvolvimento Tecnol�gico da Ind�stria de Semicondutores - Roteiro de Procedimentos') //'160850' 
			Self:RelRoteiro("49") // 'ICMS/MG - Importa��o - Roteiro de Procedimentos') //'216927' 
			Self:RelRoteiro("50") // 'PIS/PASEP e COFINS - Biodiesel - Regime diferenciado - Roteiro de Procedimentos') //'128827' 
			Self:RelRoteiro("51") // 'ICMS/PR - Exporta��o direta e indireta - Roteiro de Procedimentos') //'215438' 
			Self:RelRoteiro("52") // 'PIS/PASEP e COFINS - RECAP - Roteiro de Procedimentos') //'142412' 
			Self:RelRoteiro("53") // 'Regime Aduaneiro Especial de Tr�nsito Aduaneiro - Roteiro de Procedimentos') //'270402' 
			Self:RelRoteiro("54") // 'ICMS/BA - Importa��o - Roteiro de Procedimentos') //'216518' 
			Self:RelRoteiro("55") // 'ICMS/BA - Exporta��o - Roteiro de Procedimentos') //'215054' 
			Self:RelRoteiro("56") // 'Ex-tarif�rios - Roteiro de Procedimentos') //'256693' 
			Self:RelRoteiro("57") // 'ICMS/RS - Importa��o - Roteiro de Procedimentos') //'216020' 
			Self:RelRoteiro("58") // 'PIS/PASEP) // COFINS) // IPI e II - REPORTO - Roteiro de Procedimentos') //'127080' 
			Self:RelRoteiro("59") // 'ICMS/SP - Regime Aduaneiro Especial de Dep�sito Afian�ado - DAF - Roteiro de Procedimentos') //'199701' 
			Self:RelRoteiro("60") // 'Importa��o indireta - Roteiro de Procedimentos') //'250762' 
			Self:RelRoteiro("61") // 'PIS/PASEP) // COFINS) // PIS/PASEP-Importa��o e COFINS-Importa��o - Importa��o por conta e ordem de terceiro - Roteiro de Procedimentos') //'129100' 
			Self:RelRoteiro("62") // 'PIS/PASEP e COFINS - �reas de Livre Com�rcio - Roteiro de Procedimentos') //'207949' 
			Self:RelRoteiro("63") // 'ICMS/RJ - Importa��o - Roteiro de Procedimentos') //'216899' 
			Self:RelRoteiro("64") // 'PIS/PASEP-Importa��o e COFINS-Importa��o - Pr�-formas para envasamento de �gua) // refrigerante e outros produtos - Regime Aduaneiro Especial - Roteiro de Procedimentos') //'138218' 
			Self:RelRoteiro("65") // 'PIS/Pasep e COFINS - Regime de Entrega de Embalagens no Mercado Interno em Raz�o da Comercializa��o a Empresa Sediada no Exterior (Remicex) � Suspens�o  - Roteiro de Procedimentos') //'208515' 
			Self:RelRoteiro("66") // 'PIS/PASEP e COFINS - Biodiesel - Roteiro de Procedimentos') //'201136' 
			Self:RelRoteiro("67") // 'Devolu��o de mercadoria importada - Coment�rios') //'277133' 
			Self:RelRoteiro("68") // 'Sistema de pagamento em moeda local - Coment�rios') //'259057' 
			Self:RelRoteiro("69") // 'Importa��o de amostras - Coment�rios') //'257578' 
			Self:RelRoteiro("70") // 'Importa��o de ve�culos usados - Coment�rios') //'256895' 
			Self:RelRoteiro("71") // 'Plano Brasil Maior - Medidas aplicadas ao com�rcio exterior - Coment�rios') //'254897' 
			Self:RelRoteiro("72") // 'PIS/PASEP e COFINS - Opera��es "back to back" � Incid�ncia � Coment�rios') //'252076' 
			Self:RelRoteiro("73") // 'Licenciamento n�o autom�tico - Restri��o � entrada de produtos - Com�rcio entre Brasil e Argentina - Coment�rios') //'249297' 
		
		Case nMod == 30//EFF
			Self:RelRoteiro("21") // 'INCOTERMS 2010 - Roteiro de Procedimentos') //'249804' 
			Self:RelRoteiro("24") // 'Modalidades de Pagamento Internacional - Roteiro de Procedimentos') //'251810' 
			Self:RelRoteiro("33") // 'SGPC - Sistema Global de Prefer�ncias Comerciais - Coment�rios') //'277390' 
			Self:RelRoteiro("34") // 'Despachante Aduaneiro - Procedimentos para Registro - Coment�rios') //'269420' 
			Self:RelRoteiro("35") // 'SGP - Sistema Geral de Prefer�ncias - Coment�rios') //'267707' 
			Self:RelRoteiro("36") // 'SISCOSERV - Sistema Integrado de Com�rcio Exterior de Servi�os - Coment�rios') //'266986' 
			Self:RelRoteiro("37") // 'Financiamentos � exporta��o - Coment�rios') //'256960' 
			Self:RelRoteiro("39") // 'Empresa Comercial Exportadora - Trading Company - Diferen�as � Coment�rios') //'243642' 
			Self:RelRoteiro("47") // 'Importa��o de bens - Contabiliza��o - Roteiro de Procedimentos') //'244000' 
			Self:RelRoteiro("60") // 'Importa��o indireta - Roteiro de Procedimentos') //'250762' 
			Self:RelRoteiro("67") // 'Devolu��o de mercadoria importada - Coment�rios') //'277133' 
			Self:RelRoteiro("68") // 'Sistema de pagamento em moeda local - Coment�rios') //'259057' 
			Self:RelRoteiro("69") // 'Importa��o de amostras - Coment�rios') //'257578' 
			Self:RelRoteiro("71") // 'Plano Brasil Maior - Medidas aplicadas ao com�rcio exterior - Coment�rios') //'254897' 
			
		
		Case nMod == 50//EDC
			Self:RelRoteiro("03")
			Self:LoadRelacao(17)
			Self:LoadRelacao(29)
		
		Case nMod == 85//ESS
			Self:RelRoteiro("02")
			Self:RelRoteiro("36")
			//Self:LoadRelacao(30)
			
	EndCase

Return Nil