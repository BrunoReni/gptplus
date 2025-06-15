-- Procedure creation 
CREATE PROCEDURE CTB304_## (
    @IN_FILIAL Char( 'CQ3_FILIAL' ) , 
    @IN_DATA Char( 08 ) , 
    @IN_MOEDA Char( 'CQ3_MOEDA' ) , 
    @IN_TPSALD Char( 'CQ3_TPSALD' ) , 
    @IN_VALOR Float , 
    @IN_CONTA Char( 'CQ3_CONTA' ) , 
    @IN_CUSTO Char( 'CQ3_CCUSTO' ) , 
    @IN_DC Char( 01 ) ) AS
 
-- Declaration of variables
DECLARE @cAux Char( 03 )
DECLARE @cFil_CQ3 Char( 'CQ3_FILIAL' )
DECLARE @cLp Char( 001 )
DECLARE @iRecno Integer
DECLARE @nDebito Float
DECLARE @nCredit Float
DECLARE @nCont Integer
DECLARE @cLastDay Char( 08 )
DECLARE @cFil_CQ2 Char( 'CQ2_MOEDA' )
DECLARE @cStatus Char( 01 )
DECLARE @cSldBase Char( 01 )
BEGIN
   SELECT @cAux  = 'CQ3' 
   EXEC XFILIAL_## @cAux , @IN_FILIAL , @cFil_CQ3 output 
   SELECT @iRecno  = null 
   SELECT @cLp  = 'N' 
   SELECT @nDebito  = 0 
   SELECT @nCredit  = 0 
   SELECT @cStatus  = '1' 
   SELECT @cSldBase  = 'S' 
   SELECT @iRecno  = MIN ( R_E_C_N_O_ )
      FROM CQ3### 
      WHERE CQ3_FILIAL  = @cFil_CQ3  and CQ3_CONTA  = @IN_CONTA  and CQ3_CCUSTO  = @IN_CUSTO  and CQ3_DATA  = @IN_DATA  and CQ3_MOEDA  = @IN_MOEDA 
      and CQ3_TPSALD  = @IN_TPSALD  and CQ3_LP  = 'N'  and D_E_L_E_T_  = ' ' 
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
         FROM CQ3### 
      SELECT @iRecno  = @iRecno  + 1 
      INSERT INTO CQ3### (CQ3_FILIAL , CQ3_CONTA , CQ3_CCUSTO , CQ3_DATA , CQ3_MOEDA , CQ3_TPSALD , CQ3_LP , CQ3_DEBITO , 
      CQ3_CREDIT , CQ3_STATUS , CQ3_SLBASE , R_E_C_N_O_ ) 
      VALUES (@cFil_CQ3 , @IN_CONTA , @IN_CUSTO , @IN_DATA , @IN_MOEDA , @IN_TPSALD , @cLp , @nDebito , @nCredit , @cStatus , 
      @cSldBase , @iRecno )
   END 
   ELSE 
   BEGIN 
      IF @IN_DC  = 'D' 
      BEGIN 
         UPDATE CQ3### 
            SET CQ3_DEBITO  = CQ3_DEBITO  + ROUND ( @IN_VALOR , 2 )
         WHERE R_E_C_N_O_  = @iRecno 
      END 
      ELSE 
      BEGIN 
         UPDATE CQ3### 
            SET CQ3_CREDIT  = CQ3_CREDIT  + ROUND ( @IN_VALOR , 2 )
         WHERE R_E_C_N_O_  = @iRecno 
      END 
   END 
   EXEC LASTDAY_## @IN_DATA , @cLastDay output 
   SELECT @cAux  = 'CQ2' 
   EXEC XFILIAL_## @cAux , @IN_FILIAL , @cFil_CQ2 output 
   SELECT @iRecno  = null 
   SELECT @cLp  = 'N' 
   SELECT @nDebito  = 0 
   SELECT @nCredit  = 0 
   SELECT @cStatus  = '1' 
   SELECT @cSldBase  = 'S' 
   SELECT @iRecno  = MIN ( R_E_C_N_O_ )
     FROM CQ2### 
     WHERE CQ2_FILIAL  = @cFil_CQ2  and CQ2_CONTA  = @IN_CONTA  and CQ2_CCUSTO  = @IN_CUSTO  and CQ2_DATA  = @cLastDay  and CQ2_MOEDA  = @IN_MOEDA 
    and CQ2_TPSALD  = @IN_TPSALD  and CQ2_LP  = 'N'  and D_E_L_E_T_  = ' ' 
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
         FROM CQ2### 
      SELECT @iRecno  = @iRecno  + 1 
      INSERT INTO CQ2### (CQ2_FILIAL , CQ2_CONTA , CQ2_CCUSTO , CQ2_DATA , CQ2_MOEDA , CQ2_TPSALD , CQ2_LP , CQ2_DEBITO , 
      CQ2_CREDIT , CQ2_STATUS , CQ2_SLBASE , R_E_C_N_O_ ) 
      VALUES (@cFil_CQ2 , @IN_CONTA , @IN_CUSTO , @cLastDay , @IN_MOEDA , @IN_TPSALD , @cLp , @nDebito , @nCredit , @cStatus , 
      @cSldBase , @iRecno )
   END 
   ELSE 
   BEGIN 
      IF @IN_DC  = 'D' 
      BEGIN 
         UPDATE CQ2### 
            SET CQ2_DEBITO  = CQ2_DEBITO  + ROUND ( @IN_VALOR , 2 )
         WHERE R_E_C_N_O_  = @iRecno 
      END 
      ELSE 
      BEGIN 
         UPDATE CQ2### 
            SET CQ2_CREDIT  = CQ2_CREDIT  + ROUND ( @IN_VALOR , 2 )
         WHERE R_E_C_N_O_  = @iRecno 
      END 
   END 
END 
