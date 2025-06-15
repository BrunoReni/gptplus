-- Procedure creation 
CREATE PROCEDURE CTB302_## (
   @IN_FILIAL Char( 'CQ7_FILIAL' ) , 
   @IN_DATA Char( 08 ) , 
   @IN_MOEDA Char( 002 ) , 
   @IN_TPSALD Char( 001 ) , 
   @IN_VALOR Float , 
   @IN_CONTA Char( 'CQ7_CONTA' ) , 
   @IN_CUSTO Char( 'CQ7_CCUSTO' ) , 
   @IN_ITEM Char( 'CQ7_ITEM' ) , 
   @IN_CLVL Char( 'CQ7_CLVL' ) , 
   @IN_DC Char( 01 ) ) AS
-- Declaration of variables
DECLARE @cAux Char( 03 )
DECLARE @cFil_CQ7 Char( 'CQ7_FILIAL' )
DECLARE @cLp Char( 001 )
DECLARE @iRecno Integer
DECLARE @nDebito Float
DECLARE @nCredit Float
DECLARE @nCont Integer
DECLARE @cLastDay Char( 08 )
DECLARE @cFil_CQ6 Char( 'CQ6_FILIAL' )
DECLARE @cStatus Char( 01 )
DECLARE @cSldBase Char( 01 )
BEGIN
   SELECT @cAux  = 'CQ7' 
   EXEC XFILIAL_## @cAux , @IN_FILIAL , @cFil_CQ7 output 
   SELECT @iRecno  = null 
   SELECT @cLp  = 'N' 
   SELECT @nDebito  = 0 
   SELECT @nCredit  = 0 
   SELECT @cStatus  = '1' 
   SELECT @cSldBase  = 'S' 
   SELECT @iRecno  = MIN ( R_E_C_N_O_ )
      FROM CQ7### 
      WHERE CQ7_FILIAL  = @cFil_CQ7  and CQ7_CONTA  = @IN_CONTA  and CQ7_CCUSTO  = @IN_CUSTO  and CQ7_ITEM  = @IN_ITEM  and CQ7_CLVL  = @IN_CLVL 
      and CQ7_DATA  = @IN_DATA  and CQ7_MOEDA  = @IN_MOEDA  and CQ7_TPSALD  = @IN_TPSALD  and CQ7_LP  = 'N'  and D_E_L_E_T_  = ' ' 
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
        FROM CQ7### 
      SELECT @iRecno  = @iRecno  + 1 
      INSERT INTO CQ7### (CQ7_FILIAL , CQ7_CONTA , CQ7_CCUSTO , CQ7_ITEM , CQ7_CLVL , CQ7_DATA , CQ7_MOEDA , CQ7_TPSALD , 
      CQ7_LP , CQ7_DEBITO , CQ7_CREDIT , CQ7_STATUS , CQ7_SLBASE , R_E_C_N_O_ ) 
      VALUES (@cFil_CQ7 , @IN_CONTA , @IN_CUSTO , @IN_ITEM , @IN_CLVL , @IN_DATA , @IN_MOEDA , @IN_TPSALD , @cLp , @nDebito , 
      @nCredit , @cStatus , @cSldBase , @iRecno )
   END 
   ELSE 
   BEGIN 
      IF @IN_DC  = 'D' 
      BEGIN 
         UPDATE CQ7### 
            SET CQ7_DEBITO  = CQ7_DEBITO  + ROUND ( @IN_VALOR , 2 )
         WHERE R_E_C_N_O_  = @iRecno 
      END 
      ELSE 
      BEGIN 
         UPDATE CQ7### 
            SET CQ7_CREDIT  = CQ7_CREDIT  + ROUND ( @IN_VALOR , 2 )
         WHERE R_E_C_N_O_  = @iRecno 
      END 
   END 
   EXEC LASTDAY_## @IN_DATA , @cLastDay output 
   SELECT @cAux  = 'CQ6' 
   EXEC XFILIAL_## @cAux , @IN_FILIAL , @cFil_CQ6 output 
   SELECT @iRecno  = null 
   SELECT @cLp  = 'N' 
   SELECT @nDebito  = 0 
   SELECT @nCredit  = 0 
   SELECT @cStatus  = '1' 
   SELECT @cSldBase  = 'S' 
   SELECT @iRecno  = MIN ( R_E_C_N_O_ )
      FROM CQ6### 
      WHERE CQ6_FILIAL  = @cFil_CQ7  and CQ6_CONTA  = @IN_CONTA  and CQ6_CCUSTO  = @IN_CUSTO  and CQ6_ITEM  = @IN_ITEM  and CQ6_CLVL  = @IN_CLVL 
      and CQ6_DATA  = @cLastDay  and CQ6_MOEDA  = @IN_MOEDA  and CQ6_TPSALD  = @IN_TPSALD  and CQ6_LP  = 'N'  and D_E_L_E_T_  = ' ' 
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
         FROM CQ7### 
      SELECT @iRecno  = @iRecno  + 1 
      INSERT INTO CQ6### (CQ6_FILIAL , CQ6_CONTA , CQ6_CCUSTO , CQ6_ITEM , CQ6_CLVL , CQ6_DATA , CQ6_MOEDA , CQ6_TPSALD , 
      CQ6_LP , CQ6_DEBITO , CQ6_CREDIT , CQ6_STATUS , CQ6_SLBASE , R_E_C_N_O_ ) 
      VALUES (@cFil_CQ6 , @IN_CONTA , @IN_CUSTO , @IN_ITEM , @IN_CLVL , @cLastDay , @IN_MOEDA , @IN_TPSALD , @cLp , @nDebito , 
      @nCredit , @cStatus , @cSldBase , @iRecno )
   END 
   ELSE 
   BEGIN 
      IF @IN_DC  = 'D' 
      BEGIN 
         UPDATE CQ6### 
            SET CQ6_DEBITO  = CQ6_DEBITO  + ROUND ( @IN_VALOR , 2 )
         WHERE R_E_C_N_O_  = @iRecno 
      END 
      ELSE 
      BEGIN 
         UPDATE CQ6### 
            SET CQ6_CREDIT  = CQ6_CREDIT  + ROUND ( @IN_VALOR , 2 )
         WHERE R_E_C_N_O_  = @iRecno 
      END 
   END 
END 
