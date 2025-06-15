-- Procedure creation 
CREATE PROCEDURE CTB309_## (
    @IN_FILIAL Char( 'CT2_FILIAL' ) , 
    @IN_CT2_DATA Char( 8 ) , 
    @IN_CT2_LOTE Char( 'CT2_LOTE' ) , 
    @IN_CT2_SBLOTE Char( 'CT2_SBLOTE' ) , 
    @IN_CT2_DOC Char( 'CT2_LOTE' ) , 
    @IN_CT2_MOEDLC Char( 'CT2_MOEDLC' ) , 
    @IN_TPSALDO Char( 'CT2_TPSALD' ) , 
    @IN_CT2_VALOR Float , 
    @IN_CT2_DC Char( 01 ),
    @IN_MV_SOMA Char(01)) AS
 
-- Declaration of variables
DECLARE @cAux Char( 03 )
DECLARE @cFilial_CTC Char( 'CT2_FILIAL' )
DECLARE @iRecno Integer
DECLARE @iRecnoNew Integer
DECLARE @nCTC_DEBITO Float
DECLARE @nCTC_CREDIT Float
DECLARE @nCTC_DEBITOX Float
DECLARE @nCTC_CREDITX Float
DECLARE @nCTC_DIGX Float
DECLARE @nCTC_DIG Float
DECLARE @cMVSOMA Char( 01 )

BEGIN
   SELECT @cMVSOMA  = '1'--@IN_MV_SOMA 
   EXEC XFILIAL_## 'CTC' , @IN_FILIAL , @cFilial_CTC output  
   
   ##UNIQUEKEY_START
   select @iRecno = COALESCE(Min(R_E_C_N_O_), 0)
   from CTC###
   Where CTC_FILIAL = @cFilial_CTC
   and CTC_DATA   = @IN_CT2_DATA
   and CTC_LOTE   = @IN_CT2_LOTE
   and CTC_SBLOTE = @IN_CT2_SBLOTE
   and CTC_DOC    = @IN_CT2_DOC
   and CTC_MOEDA  = @IN_CT2_MOEDLC
   and CTC_TPSALD = @IN_TPSALDO
   and D_E_L_E_T_ = ' '  
   ##UNIQUEKEY_END	     
   
   SELECT @nCTC_DEBITOX  = 0 
   
   SELECT @nCTC_CREDITX  = 0 
   
   SELECT @nCTC_DIGX  = 0 

   IF @iRecno  = 0 
   BEGIN 
      
      IF @IN_CT2_DC IN ( '1' , '3'  ) 
      BEGIN 
         SELECT @nCTC_DEBITOX  = ROUND ( @IN_CT2_VALOR , 2 )
      END 
      IF @IN_CT2_DC IN ( '2' , '3'  ) 
      BEGIN 
         SELECT @nCTC_CREDITX  = ROUND ( @IN_CT2_VALOR , 2 )
      END 
      IF @IN_CT2_DC  = '3' 
      BEGIN 
         IF @cMVSOMA  = '1' 
         BEGIN 
            SELECT @nCTC_DIGX  = ROUND ( @IN_CT2_VALOR , 2 )
         END 
         ELSE 
         BEGIN 
            SELECT @nCTC_DIGX  = ROUND (  (2  * @IN_CT2_VALOR ) , 2 )
         END 
      END 
      ELSE 
      BEGIN 
         SELECT @nCTC_DIGX  = ROUND ( @IN_CT2_VALOR , 2 )
      END 
   END 
   ELSE 
   BEGIN 
      SELECT @nCTC_DIG  = CTC_DIG , @nCTC_DEBITO  = CTC_DEBITO , @nCTC_CREDIT  = CTC_CREDIT 
        FROM CTC### 
        WHERE R_E_C_N_O_  = @iRecno 
      IF @IN_CT2_DC  = '1' 
      BEGIN 
         SELECT @nCTC_DEBITOX  = ROUND ( @nCTC_DEBITO  + @IN_CT2_VALOR , 2 )
         SELECT @nCTC_CREDITX  = ROUND ( @nCTC_CREDIT , 2 )
      END 
      IF @IN_CT2_DC  = '2' 
      BEGIN 
         SELECT @nCTC_CREDITX  = ROUND ( @nCTC_CREDIT  + @IN_CT2_VALOR , 2 )
         SELECT @nCTC_DEBITOX  = ROUND ( @nCTC_DEBITO , 2 )
      END 
      IF @IN_CT2_DC  = '3' 
      BEGIN 
         SELECT @nCTC_DEBITOX  = ROUND ( @nCTC_DEBITO  + @IN_CT2_VALOR , 2 )
         SELECT @nCTC_CREDITX  = ROUND ( @nCTC_CREDIT  + @IN_CT2_VALOR , 2 )
         IF @cMVSOMA  = '1' 
         BEGIN 
            SELECT @nCTC_DIGX  = ROUND (  (@nCTC_DIG  + @IN_CT2_VALOR ) , 2 )
         END 
         ELSE 
         BEGIN 
            SELECT @nCTC_DIGX  = ROUND ( @nCTC_DIG  +  (2  * @IN_CT2_VALOR ) , 2 )
         END 
      END 
      ELSE 
      BEGIN 
         SELECT @nCTC_DIGX  = ROUND ( @nCTC_DIG  + @IN_CT2_VALOR , 2 )
      END 
   END 
   
   IF @iRecno  = 0
   BEGIN   
      SELECT @iRecno  = COALESCE(Max(R_E_C_N_O_), 0)
        FROM CTC### 
      SELECT @iRecno  = @iRecno  + 1 
      IF  (@iRecno is null  or @iRecno  = 0 ) 
      BEGIN 
         SELECT @iRecno  = 1 
      END 
         ##TRATARECNO @iRecno\
         INSERT INTO CTC### (CTC_FILIAL , CTC_MOEDA , CTC_TPSALD , CTC_DATA , CTC_LOTE , CTC_SBLOTE , CTC_DOC , CTC_STATUS , 
         CTC_DEBITO , CTC_CREDIT , CTC_DIG , R_E_C_N_O_ ) 
         VALUES (@cFilial_CTC , @IN_CT2_MOEDLC , @IN_TPSALDO , @IN_CT2_DATA , @IN_CT2_LOTE , @IN_CT2_SBLOTE , @IN_CT2_DOC , 
         '1' , 0 , 0 , 0 , @iRecno )
         ##FIMTRATARECNO 
   END 
   
   UPDATE CTC### 
         SET CTC_DEBITO  = CTC_DEBITO + @nCTC_DEBITOX , CTC_CREDIT  = CTC_CREDIT + @nCTC_CREDITX , CTC_DIG  = CTC_DIG + @nCTC_DIGX 
   WHERE R_E_C_N_O_  = @iRecno 
END 