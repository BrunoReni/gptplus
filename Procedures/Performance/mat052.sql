Create Procedure MAT052_##
(
 @IN_FILIALCOR    char('B1_FILIAL'),
 @IN_CODIGO       char('B1_COD'),
 @IN_TRANSACTION  char(01),
 @OUT_RESULTADO   char(01) OutPut
)
as
/* ---------------------------------------------------------------------------------------------------------------------
    Versão      -  <v> Protheus P12 </v>
    Programa    -  <s> CriaTRT </s>
    Descricao   -  <d> Cria registro no arquivo de saldo em estoque a ser utilizado na procedure MAT007 </d>
    Assinatura  -  <a> 008 </a>
    Entrada     -  <ri> @IN_FILIALCOR - Filial corrente
                        @IN_CODIGO    - Codigo do produto </ri>
    Saida       :  <ro> @OUT_RESULTADO - Retorno de processamento </ro>
    Responsavel :  <r> Marcelo Pimentel </r>
    Data        :  <dt> 06.12.2007 </dt>
--------------------------------------------------------------------------------------------------------------------- */

Begin
  select @OUT_RESULTADO = '0'
  ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
  insert into TRT### ( TRB_FILIAL    , TRB_COD )
              values ( @IN_FILIALCOR , @IN_CODIGO )
  ##CHECK_TRANSACTION_COMMIT
  select @OUT_RESULTADO = '1'
End
