Create procedure CTB033_##
( 
   @IN_FILIAL    Char('CTI_FILIAL'),
   @IN_CONTA     Char('CTI_CONTA'),
   @IN_CUSTO     Char('CTI_CUSTO'),
   @IN_ITEM      Char('CTI_ITEM'),
   @IN_CLVL      Char('CTI_CLVL'),
   @IN_MOEDA     Char('CTI_MOEDA'),
   @IN_DATA      Char(08),
   @IN_TPSALDO   Char('CTI_TPSALD'),
   @IN_SLBASE    Char('CTI_SLBASE'),
   @IN_DTLP      Char('CTI_DTLP'),
   @IN_LP        Char('CTI_LP'),
   @IN_STATUS    Char('CTI_STATUS'),
   @IN_DEBITO    Float,
   @IN_CREDIT    Float,
   @IN_ATUDEB    Float,
   @IN_ATUCRD    Float,
   @IN_LPDEB     Float,
   @IN_LPCRD     Float,
   @IN_ANTDEB    Float,
   @IN_ANTCRD    Float,
   @IN_SLCOMP    Char('CTI_SLCOMP'),
   @IN_RECNO     Integer
 )
as

/* ------------------------------------------------------------------------------------
    Vers�o          - <v>  Protheus P11 </v>
    Assinatura      - <a>  001 </a>
    Fonte Microsiga - <s>  CTBA190.PRW </s>
    Procedure       -      Reprocessamento SigaCTB
    Descricao       - <d>  Insert no CTI </d>
    Funcao do Siga  -      
    Entrada         - <ri> @IN_FILIAL       - Filial Corrente
                           @IN_CONTA        - Conta
                           @IN_CUSTO        - C Custo
                           @IN_ITEM         - Item
                           @IN_CLVL         - CLVL
                           @IN_MOEDA        - Moeda
                           @IN_DATA         - Data
                           @IN_TPSALDO      - Tipo de Saldo
                           @IN_SLBASE       - Saldo base
                           @IN_DTLP         - Data LP
                           @IN_LP           - LP
                           @IN_STATUS       - Status
                           @IN_DEBITO       - movito a debito
                           @IN_CREDIT       - movito a credito
                           @IN_ATUDEB       - Saldo atual a debito
                           @IN_ATUCRD       - Saldo atual a credito
                           @IN_LPDEB        - lp a debito
                           @IN_LPCRD        - lp a credito
                           @IN_ANTDEB       - sl ant a Debito
                           @IN_ANTCRD       - sl ant a Debito
                           @IN_SLCOMP       - Flag de sld composto
                           @IN_RECNO        - nro do recno </ri>
    Saida           - <o>   </ro
    Responsavel :     <r>  Alice Yaeko Yamamoto	</r>
    Data        :     28/11/2003
-------------------------------------------------------------------------------------- */

Declare @nDEBITO    Float
Declare @nCREDIT    Float
Declare @nATUDEB    Float
Declare @nATUCRD    Float
Declare @nANTDEB    Float
Declare @nANTCRD    Float
Declare @nLPDEB     Float
Declare @nLPCRD     Float
Declare @iRecno     integer
   
begin
   
   select @iRecno   = @IN_RECNO
   select @nDEBITO  =  Round(@IN_DEBITO, 2)
   select @nCREDIT  =  Round(@IN_CREDIT, 2)
   select @nATUDEB  =  Round(@IN_ATUDEB, 2)
   select @nATUCRD  =  Round(@IN_ATUCRD, 2)
   select @nANTDEB  =  Round(@IN_ANTDEB, 2)
   select @nANTCRD  =  Round(@IN_ANTCRD, 2)
   select @nLPDEB   =  Round(@IN_LPDEB, 2)
   select @nLPCRD   =  Round(@IN_LPCRD, 2)
    
   ##TRATARECNO @iRecno\
   Insert into CTI### 
         ( CTI_FILIAL,  CTI_CONTA,   CTI_CUSTO,   CTI_ITEM,   CTI_CLVL,
           CTI_MOEDA,   CTI_DATA,    CTI_TPSALD,  CTI_SLBASE, CTI_DTLP,
           CTI_LP,      CTI_STATUS,  CTI_DEBITO,  CTI_CREDIT, CTI_ATUDEB,
           CTI_ATUCRD,  CTI_LPDEB,   CTI_LPCRD,   CTI_ANTDEB, CTI_ANTCRD,
           CTI_SLCOMP,  R_E_C_N_O_ )
   values( @IN_FILIAL,  @IN_CONTA,   @IN_CUSTO,   @IN_ITEM,   @IN_CLVL,
           @IN_MOEDA,   @IN_DATA,    @IN_TPSALDO, @IN_SLBASE, @IN_DTLP,
           @IN_LP,      @IN_STATUS,  @nDEBITO,    @nCREDIT,   @nATUDEB,
           @nATUCRD,    @nLPDEB,     @nLPCRD,     @nANTDEB,   @nANTCRD,
           @IN_SLCOMP,  @iRecno )
   ##FIMTRATARECNO
end
