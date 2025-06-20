create procedure M330INC2CP_##
(
 @IN_FILIALCOR  char('B1_FILIAL')
)
as
/* ---------------------------------------------------------------------------------------------------------------------
    Programa    :   <s> M330InC2CP </s>
    -----------------------------------------------------------------------------------------------------------------    
    Assinatura  :   <a> 001 </a>
    -----------------------------------------------------------------------------------------------------------------    
    Descricao   :   <d> Atualiza partes do custo em partes no SC2 </d>
    -----------------------------------------------------------------------------------------------------------------
    Entrada     :  <ri> @IN_FILIALCOR  - Filial corrente </ri>                   
    -----------------------------------------------------------------------------------------------------------------
    Saida       :  <ro> </ro>
    -----------------------------------------------------------------------------------------------------------------
    Vers�o      :   <v> Protheus P12 </v>
    -----------------------------------------------------------------------------------------------------------------
    Observa��es :   <o>   </o>
    -----------------------------------------------------------------------------------------------------------------
    Responsavel :   <r> Ricardo Gon�alves </r>
    -----------------------------------------------------------------------------------------------------------------
    Data        :  <dt> 18/07/2002 </dt>
    -----------------------------------------------------------------------------------------------------------------
    Obs.: N�o remova os tags acima. Os tags s�o a base para a gera��o autom�tica, de documenta��o, pelo Parse.
--------------------------------------------------------------------------------------------------------------------- */

/* ---------------------------------------------------------------------------------------------------------------------
   Variaveis internas (Declare abaixo todas as vari�veis utilizadas na procedure)
--------------------------------------------------------------------------------------------------------------------- */
declare @nRec         integer
--<*> ----- Fim da Declara��o de vari�veis internas -------------------------------------------------------------- <*>--

begin
  select @nRec = 0
end
