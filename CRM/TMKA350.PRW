#INCLUDE "TMKA350.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "FONT.CH"
#INCLUDE "TMKDEF.CH"

/*
旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
�																						 �
�   BOTOES DA SUPERIOR     								aCfgBtn - Array	   			     �
�																						 �
�	01 - Copiar                                             01                           � 
�	02 - Colar                                              02                           � 
�	03 - Calculadora...                                     03                           � 
�	04 - Agenda...                                          04                           � 
�	05 - Gerenciador de Impressao...                        05                           � 
�	06 - Help de Programa...                                06                           � 
�   07 - Limpa o Atendimento                                07                           � 
�	08 - Cancela o Atendimento								08							 �
�	09 - Marketing Ativo									09							 �
�	10 - Envio de Tarefa									10							 �
�	11 - Script da Campanha                                 11                           � 
�	12 - Alteracao de Entidades                             12                           � 
�	13 - Historico das ligacoes                             13                           � 
�	14 - Situacao Financeira                                14                           � 
�	15 - Cadastro de Contatos                               15                           � 
�	16 - Banco de Conhecimento                              16                           � 
�	17 - OK                                                 17                           � 
�	18 - CANCELA                                            18                           �  
쳐컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑
�																						 �
�   BOTOES DA LATERAL 																	 �
�																						 �
�	01 - Encerramento										19							 �
�	02 - Chamado Tecnico									20							 �
�	03 - Ligacoes Pendentes									21							 �	
�	04 - Cadastro do Produto                                22              	         � 
�	05-  Cadastro de Concorrentes                           23                           �    
�	06 - Cadastro de Acessorios								24							 �
�	07 - Condicoes de Pagamento								25					 		 �
�	08 - Vendedor                                           26                           � 
�	09 - Pedido                                             27                           � 
�	10 - Rastreamento                                       28                           � 
�	11 - Lotes                                              29                           � 
�   12 - Sub-Lotes                                          30                           � 
�   13 - Vendas Lojas                                       31                           � 
�   14 - Bonus                                              32                           � 
�	15 - Consulta TEF                                       33                           � 
�																						 �
읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
*/

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튡rograma  쿟MKA350   튍utor  쿌rmando M. Tessaroli� Data �  14/10/03   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     쿐xecuta a tela do atendimento de Telecobranca               볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       � AP8                                                        볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튍nalista  � Data/Bops/Ver 쿘anutencao Efetuada                      	  볍�
굇勁袴袴袴袴曲袴袴袴袴佶袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇쿑ernando  |14/12/06| 9.12 쿍ops 115431 Alterado a array aRotina  para  낢�
굇�        	 �        |      쿬ria豫o do menu funcional            	      낢�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Function TMKA350()

Local cTipoAte	:= TkGetTipoAte()		// Folders do atendimento
Local lRet		:= .F.					// Variavel de retorno logico

Local aCores3    := {	{"(EMPTY(ACF->ACF_CCANC) .AND. VAL(ACF->ACF_STATUS) == 1)",	"BR_AZUL"		},;		// Atendimento
   						{"(EMPTY(ACF->ACF_CCANC) .AND. VAL(ACF->ACF_STATUS) == 2)",	"BR_VERDE"		},;		// Cobranca
   						{"(EMPTY(ACF->ACF_CCANC) .AND. VAL(ACF->ACF_STATUS) == 3)",	"BR_VERMELHO"	},;		// Encerrado
   						{"(!EMPTY(ACF->ACF_CCANC))",								"BR_CINZA"		}} 		// Cancelado

Private cCadastro := STR0001 //"Atendimento"
Private aRotina   := {}

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿙ao permite a abertura simultanea para o modelo MDI�
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
If !ExcProcess("TMK" + __cUserId)
	Help("  ",1,"TMKPROMDI")
	Return(.F.)
Endif

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//쿑az o tratamento para garantir a exclusividade na rotina de atualizacao do SK1�
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
ExcProcess("TMKSK1")

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿞e o USUARIO nao estiver cadastrado em OPERADORES e nao tiver    �
//퀅m Grupo de Atendimento (SU0) associado ou se o Operador nao 	�
//퀃iver acesso a rotina de Telecobranca ou Todas - nao entra nessa �
//퀁otina                                                           �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
If !TMKOPERADOR()
	Help("  ",1,"OPERADOR")
	Return(lRet)
Else     
	If	VAL(TkGetTipoAte()) == TELEVENDAS		.OR.;
		VAL(TkGetTipoAte()) == TELEMARKETING	.OR.;
		VAL(TkGetTipoAte()) == TMKTLV
		Help("  ",1,"TK280ACTLC")
		Return(lRet)
	Endif
EndIf	

// Verifica se o Operador possui regra de selecao e de negociacao.
If Empty(TkPosto(TkOperador(),"U0_REGSEL")) .OR. Empty(TkPosto(TkOperador(),"U0_REGNEG"))
	Help("  ",1,"TK280REGRA")
	Return(lRet)
Endif

// Verifica se o Operador realiza atendimento RECEPTIVO
If TkPosto(TkOperador(),"U0_BOUND") == "2"		// Ativa
	Help("  ",1,"TK280ATEND")
	Return(lRet)
Endif


//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//쿗impa o array com os precos da ultima tabela de preco usada - �
//쿎aso haja atualizacao da tabela de preco por outro Remote     �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
MaReleTabPrc()


// Abre somente o atendimento de Telecobranca
TkGetTipoAte("3")

aRotina	:= MenuDef()
MBrowse(,,,,"ACF",,,,,,aCores3)

// Restaura as condicoes normais
TkGetTipoAte(cTipoAte)

Return(.T.)


/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑un뇙o    |MenuDef	� Autor � Fernando Amorim       � Data �11/12/06  낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇙o � Funcao de defini豫o do aRotina                             낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿝etorno   � aRotina   retorna a array com lista de aRotina             낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿢so       � SIGATMK                                                    낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
Static Function MenuDef() 

Local aRotina:= {	{ STR0002  ,"AxPesqui"        ,0 ,1 , , .F. },;		//"Pesquisar"
					{ STR0003  ,"TK271CallCenter" ,0 ,2 , , .T. },;		//"Visualizar"
					{ STR0004  ,"TK271CallCenter" ,0 ,3 , , .T. },;		//"Incluir"
			   		{ STR0005  ,"TK271CallCenter" ,0 ,4 , , .T. },;		//"Alterar"
					{ STR0006  ,"TK271Legenda"	  ,0 ,2 , , .T. } }		//"Legenda"

				

							                                                     				
Return(ARotina)



