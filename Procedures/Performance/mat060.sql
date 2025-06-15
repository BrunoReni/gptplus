CREATE PROCEDURE MAT060_##
(
   @IN_SB2OUTR2    Char(3),
   @OUT_RESULTADO  char(01) OutPut
)
as
/* ------------------------------------------------------------------------------
    Programa    -  <s> A330GRVTRB() </s>
    Versão      -  <v> Protheus P12 </v>
    Descricao   -  <d> Recalculo do custo medio - Validacao da Procedure Instalada </d>
    Assinatura  -  <a> 010 </a>
    Entrada     -  <ri>
                   @IN_SB2OUTR2     - Filial Corrente
                   </ri>
    Responsavel :  <r> Squad Entradas </r>
    Data        :  <dt> 18/05/2023 </dt>
    <o> Uso         :  MATA330</o>

    Estrutura de chamadas
    ========= == ========

    0.MAT060 - Validacao da Procedure Instalada

------------------------------------------------------------------------------------------------------------------------ */


declare @cIN_SB2OUTR2 char(03)

begin

   /* -------------------------------------------------------------------------
    Evitando Parameter Sniffing
   ------------------------------------------------------------------------- */
   select @cIN_SB2OUTR2 = @IN_SB2OUTR2

   If @cIN_SB2OUTR2 <> #SB2OUTR2# begin
      /* Procedure instalada incorretamente - reinstalar */
      select @OUT_RESULTADO = '2'
   End Else begin
      select @OUT_RESULTADO = '1'
   End

end
