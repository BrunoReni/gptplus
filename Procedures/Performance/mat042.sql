create procedure MAT042_##
(
 @IN_FILIALCOR  char('B1_FILIAL'),
 @IN_TIPO       char(01),
 @IN_MV_PAR01   char(08),
 @IN_MV_PAR14   integer,
 @IN_RECNO      Integer,
 @IN_MV_ULMES   char(08),
 @OUT_RESULTADO char(01) output,
 @OUT_ATUNIV    char(01) output
)

as
/* ---------------------------------------------------------------------------------------------------------------------
    Versão      :   <v> Protheus P12 </v>
    -----------------------------------------------------------------------------------------------------------------    
    Programa    :   <s> A330Period </s>
    -----------------------------------------------------------------------------------------------------------------    
    Descricao   :   <d> Verifica se a remessa ocorreu em outro periodo </d>
    -----------------------------------------------------------------------------------------------------------------
    Assinatura  :   <a> 008 </a>
    -----------------------------------------------------------------------------------------------------------------
    Entrada     :  <ri> @IN_FILIALCOR - Filial corrente 
                        @IN_TIPO      - Tipo de Beneficiamento
                        @IN_MV_PAR01  - Data Limite para recalculo
                        @IN_MV_PAR14  - Método de Apropriação
                        @IN_MV_ULMES  - Data do último fechamento do estoque + 1 dia
                        @IN_RECNO     - Recno do movimento para obtenção de dados </ri>                   
    -----------------------------------------------------------------------------------------------------------------
    Saida       :  <ro> @OUT_RESULTADO - Retorno de processamento </ro>
    -----------------------------------------------------------------------------------------------------------------
    Versão      :   <v> Advanced Protheus </v>
    -----------------------------------------------------------------------------------------------------------------
    Observações :   <o>   </o>
    -----------------------------------------------------------------------------------------------------------------
    Responsavel :   <r> Ricardo Gonçalves </r>
    -----------------------------------------------------------------------------------------------------------------
    Data        :  <dt> 13/06/2002 </dt>
    -----------------------------------------------------------------------------------------------------------------
    Obs.: Não remova os tags acima. Os tags são a base para a geração, automática, de documentação.
--------------------------------------------------------------------------------------------------------------------- */

/* ---------------------------------------------------------------------------------------------------------------------
   Declaração de variáveis para cursor (Declare abaixo todas as variáveis utilidas no select do cursor)
--------------------------------------------------------------------------------------------------------------------- */

--<*> ----- Fim da Declaração de variáveis para cursor ----------------------------------------------------------- <*>--


/* ---------------------------------------------------------------------------------------------------------------------
   Variaveis internas (Declare abaixo todas as variáveis utilizadas na procedure)
--------------------------------------------------------------------------------------------------------------------- */
Declare @cFil_SB6    char('B6_FILIAL')
Declare @cFil_SF2    char('F2_FILIAL')
Declare @cD1_COD     char('D1_COD')
Declare @cD1_LOCAL   char('D1_LOCAL')
Declare @cD1_FORNECE char('D1_FORNECE')
Declare @cD1_LOJA    char('D1_LOJA') 
Declare @cD1_IDENTB6 char('D1_IDENTB6')
Declare @dD1_DTDIGIT char('D1_DTDIGIT')
Declare @cD1_NFORI   char('D1_NFORI')
Declare @cD1_SERIORI char('D1_SERIORI')
Declare @dB6_EMISSAO char('B6_EMISSAO')
Declare @cB6_LOCAL   char('B6_LOCAL')
Declare @dF2_EMISSAO char('F2_EMISSAO')
Declare @cD2_COD     char('D2_COD')
Declare @cD2_LOCAL   char('D2_LOCAL')
Declare @cD2_CLIENTE char('D2_CLIENTE')
Declare @cD2_LOJA    char('D2_LOJA')
Declare @cD2_IDENTB6 char('D2_IDENTB6')
Declare @dD2_EMISSAO char('D2_EMISSAO')
Declare @cAux        Varchar(3)
--<*> ----- Fim da Declaração de variáveis internas -------------------------------------------------------------- <*>--

Declare @nCount integer
begin

   select @OUT_RESULTADO = '0'
   select @OUT_ATUNIV = '0' 

   /* ------------------------------------------------------------------------------------------------------------------
       Recupera filiais
   ------------------------------------------------------------------------------------------------------------------ */
   select @cAux = 'SB6'
   exec XFILIAL_## @cAux, @IN_FILIALCOR, @cFil_SB6 OutPut
   select @cAux = 'SF2'
   exec XFILIAL_## @cAux, @IN_FILIALCOR, @cFil_SF2 OutPut

   /* ------------------------------------------------------------------------------------------------------------------
      Obtendo dados para posicionamento do arquivo de saldos em poder de terceiros
   ------------------------------------------------------------------------------------------------------------------ */
   select @cD1_COD = D1_COD, @cD1_LOCAL = D1_LOCAL, @cD1_FORNECE = D1_FORNECE, @cD1_LOJA = D1_LOJA, @cD1_IDENTB6 = D1_IDENTB6,
          @dD1_DTDIGIT = D1_DTDIGIT, @cD1_NFORI = D1_NFORI, @cD1_SERIORI = D1_SERIORI
     from SD1### (nolock)
    where R_E_C_N_O_ = @IN_RECNO

   If @IN_TIPO = 'D' begin
      select @dB6_EMISSAO = min(substring(B6_EMISSAO,1,8)), @cB6_LOCAL = B6_LOCAL
      from SB6### (nolock)
      where B6_FILIAL = @cFil_SB6
      and B6_PRODUTO  = @cD1_COD
      and B6_CLIFOR   = @cD1_FORNECE
      and B6_LOJA     = @cD1_LOJA
      and B6_IDENT    = @cD1_IDENTB6
      and B6_PODER3   = 'R'
      and D_E_L_E_T_  = ' '
      GROUP BY B6_LOCAL

      if ((@IN_MV_PAR14 = 2) and (@dB6_EMISSAO >= @IN_MV_ULMES) and (@dB6_EMISSAO <= @IN_MV_PAR01)) or
         ((@IN_MV_PAR14 = 3) and (@dB6_EMISSAO = @dD1_DTDIGIT))
         select @OUT_RESULTADO = '1'

      if @OUT_RESULTADO = '1' and @cD1_LOCAL <> @cB6_LOCAL
         select @OUT_ATUNIV = '1'

   end else begin
      if @IN_TIPO = 'V' begin
         select @dF2_EMISSAO = min(substring(F2_EMISSAO,1,8))
         from SF2### (nolock)
         where F2_FILIAL = @cFil_SF2
         and F2_DOC      = @cD1_NFORI
         and F2_SERIE    = @cD1_SERIORI
         and D_E_L_E_T_  = ' '

         if ((@IN_MV_PAR14 = 2) and (@dF2_EMISSAO >= @IN_MV_ULMES) and (@dF2_EMISSAO <= @IN_MV_PAR01)) or
            ((@IN_MV_PAR14 = 3) and (@dF2_EMISSAO = @dD1_DTDIGIT))
               select @OUT_RESULTADO = '1'
   
      end else begin
         select @cD2_COD = D2_COD, @cD2_LOCAL = D2_LOCAL, @cD2_CLIENTE = D2_CLIENTE, @cD2_LOJA = D2_LOJA,
         @cD2_IDENTB6 = D2_IDENTB6, @dD2_EMISSAO = D2_EMISSAO
         from SD2### (nolock)
         where R_E_C_N_O_ = @IN_RECNO

         select @dB6_EMISSAO = min(substring(B6_EMISSAO,1,8))
         from SB6### (nolock)
         where B6_FILIAL = @cFil_SB6
         and B6_PRODUTO  = @cD2_COD
         and B6_CLIFOR   = @cD2_CLIENTE
         and B6_LOJA     = @cD2_LOJA
         and B6_IDENT    = @cD2_IDENTB6
         and B6_ESTOQUE  = 'S'
         and B6_PODER3   = 'D'
         and B6_LOCAL    <> @cD2_LOCAL
         and D_E_L_E_T_  = ' '
      
         if ((@IN_MV_PAR14 = 2) and (@dB6_EMISSAO >= @IN_MV_ULMES) and (@dB6_EMISSAO <= @IN_MV_PAR01)) or
            ((@IN_MV_PAR14 = 3) and (@dB6_EMISSAO = @dD2_EMISSAO)) begin
               select @OUT_RESULTADO = '1'
               select @OUT_ATUNIV = '1'
         end
      end
   end       
end
