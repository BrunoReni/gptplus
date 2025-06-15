-- Procedure creation 
CREATE PROCEDURE CTB305_## (
    @IN_FILIAL Char( 008 ) , 
    @IN_DATA Char( 08 ) , 
    @IN_MOEDA Char( 002 ) , 
    @IN_TPSALD Char( 001 ) , 
    @IN_VALOR Float , 
    @IN_CONTA Char( 020 ) , 
    @IN_DC Char( 01 ) ) AS
 
-- Declaration of variables
DECLARE @cAux Char( 03 )
DECLARE @cFil_CQ1 Char( 008 )
DECLARE @cLp Char( 001 )
DECLARE @iRecno Integer
DECLARE @nDebito Float
DECLARE @nCredit Float
DECLARE @nCont Integer
DECLARE @cLastDay Char( 08 )
DECLARE @cFil_CQ0 Char( 008 )
DECLARE @cStatus Char( 01 )
DECLARE @cSldBase Char( 01 )
BEGIN
   SELECT @cAux  = 'CQ1' 
   EXEC XFILIAL_## @cAux , @IN_FILIAL , @cFil_CQ1 output 
   SELECT @iRecno  = null 
   SELECT @cLp  = 'N' 
   SELECT @nDebito  = 0 
   SELECT @nCredit  = 0 
   SELECT @cStatus  = '1' 
   SELECT @cSldBase  = 'S' 
   SELECT @iRecno  = MIN ( R_E_C_N_O_ )
     FROM CQ1### 
     WHERE CQ1_FILIAL  = @cFil_CQ1  and CQ1_CONTA  = @IN_CONTA  and CQ1_DATA  = @IN_DATA  and CQ1_MOEDA  = @IN_MOEDA  and CQ1_TPSALD  = @IN_TPSALD 
    and CQ1_LP  = 'N'  and D_E_L_E_T_  = ' ' 
   IF @iRecno is null 
   BEGIN 
      IF @IN_DC  = 'D' 
      BEGIN 
         SELECT @nDebito  = ROUND ( @IN_VALOR , 2 )
         SELECT @nCredit  = 0 
      END 
      ELSE 
      BEGIN 
         SELECT @nCredit  = ROUND ( @IN_VALOR , 2 )
         SELECT @nDebito  = 0 
      END 
      SELECT @iRecno  = COALESCE ( MAX ( R_E_C_N_O_ ), 0 )
        FROM CQ1### 
      SELECT @iRecno  = @iRecno  + 1 
      INSERT INTO CQ1### (CQ1_FILIAL , CQ1_CONTA , CQ1_DATA , CQ1_MOEDA , CQ1_TPSALD , CQ1_LP , CQ1_DEBITO , CQ1_CREDIT , 
      CQ1_STATUS , CQ1_SLBASE , R_E_C_N_O_ ) 
      VALUES (@cFil_CQ1 , @IN_CONTA , @IN_DATA , @IN_MOEDA , @IN_TPSALD , @cLp , @nDebito , @nCredit , @cStatus , @cSldBase , 
      @iRecno )
   END 
   ELSE 
   BEGIN 
      IF @IN_DC  = 'D' 
      BEGIN 
         UPDATE CQ1### 
            SET CQ1_DEBITO  = CQ1_DEBITO  + ROUND ( @IN_VALOR , 2 )
         WHERE R_E_C_N_O_  = @iRecno 
      END 
      ELSE 
      BEGIN 
         UPDATE CQ1### 
            SET CQ1_CREDIT  = CQ1_CREDIT  + ROUND ( @IN_VALOR , 2 )
         WHERE R_E_C_N_O_  = @iRecno 
      END 
   END 
   EXEC LASTDAY_## @IN_DATA , @cLastDay output 
   SELECT @cAux  = 'CQ0' 
   EXEC XFILIAL_## @cAux , @IN_FILIAL , @cFil_CQ0 output 
   SELECT @iRecno  = null 
   SELECT @cLp  = 'N' 
   SELECT @nDebito  = 0 
   SELECT @nCredit  = 0 
   SELECT @cStatus  = '1' 
   SELECT @cSldBase  = 'S' 
   SELECT @iRecno  = MIN ( R_E_C_N_O_ )
     FROM CQ0### 
     WHERE CQ0_FILIAL  = @cFil_CQ1  and CQ0_CONTA  = @IN_CONTA  and CQ0_DATA  = @cLastDay  and CQ0_MOEDA  = @IN_MOEDA  and CQ0_TPSALD  = @IN_TPSALD 
    and CQ0_LP  = 'N'  and D_E_L_E_T_  = ' ' 
   IF @iRecno is null 
   BEGIN 
      IF @IN_DC  = 'D' 
      BEGIN 
         SELECT @nDebito  = ROUND ( @IN_VALOR , 2 )
         SELECT @nCredit  = 0 
      END 
      ELSE 
      BEGIN 
         SELECT @nCredit  = ROUND ( @IN_VALOR , 2 )
         SELECT @nDebito  = 0 
      END 
      SELECT @iRecno  = COALESCE ( MAX ( R_E_C_N_O_ ), 0 )
         FROM CQ0### 
      SELECT @iRecno  = @iRecno  + 1 
      INSERT INTO CQ0### (CQ0_FILIAL , CQ0_CONTA , CQ0_DATA , CQ0_MOEDA , CQ0_TPSALD , CQ0_LP , CQ0_DEBITO , CQ0_CREDIT , 
      CQ0_STATUS , CQ0_SLBASE , R_E_C_N_O_ ) 
      VALUES (@cFil_CQ1 , @IN_CONTA , @cLastDay , @IN_MOEDA , @IN_TPSALD , @cLp , @nDebito , @nCredit , @cStatus , @cSldBase , 
      @iRecno )
   END 
   ELSE 
   BEGIN 
      IF @IN_DC  = 'D' 
      BEGIN 
         UPDATE CQ0### 
            SET CQ0_DEBITO  = CQ0_DEBITO  + ROUND ( @IN_VALOR , 2 )
         WHERE R_E_C_N_O_  = @iRecno 
      END 
      ELSE 
      BEGIN 
         UPDATE CQ0### 
            SET CQ0_CREDIT  = CQ0_CREDIT  + ROUND ( @IN_VALOR , 2 )
         WHERE R_E_C_N_O_  = @iRecno 
      END 
   END 
END 
